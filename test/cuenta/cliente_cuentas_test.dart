import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';

/// Un cliente que habla con un servidor que siempre contesta [estado] y
/// [cuerpo], y que anota el último pedido en [ultimo].
({ClienteCuentas cuentas, List<http.Request> pedidos}) _contestando(
  int estado, [
  Map<String, Object?>? cuerpo,
]) {
  final pedidos = <http.Request>[];
  final mock = MockClient((pedido) async {
    pedidos.add(pedido);
    return http.Response.bytes(
      cuerpo == null ? const [] : utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json'},
    );
  });
  return (cuentas: ClienteCuentas(mock, Uri.parse('https://servidor.test/')), pedidos: pedidos);
}

void main() {
  group('ClienteCuentas', () {
    test('crearCuenta manda usuario y contraseña dos veces, en JSON, a /auth/users/', () async {
      final (:cuentas, :pedidos) = _contestando(201, {'username': 'ana', 'id': 1});

      await cuentas.crearCuenta(usuario: 'ana', contrasena: 'gema-73-x', repetida: 'gema-73-x');

      final pedido = pedidos.single;
      expect(pedido.method, 'POST');
      expect(pedido.url.toString(), 'https://servidor.test/auth/users/');
      expect(pedido.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(pedido.body), {
        'username': 'ana',
        'password': 'gema-73-x',
        're_password': 'gema-73-x',
      });
      expect(pedido.headers.containsKey('Authorization'), isFalse);
    });

    test('entrar devuelve el token de la sesión nueva', () async {
      final (:cuentas, :pedidos) = _contestando(200, {'token': 'abc123', 'expiry': '2026-11-09'});

      final token = await cuentas.entrar(usuario: 'ana', contrasena: 'gema-73-x');

      expect(token, 'abc123');
      expect(pedidos.single.url.path, '/auth/token/login/');
      expect(jsonDecode(pedidos.single.body), {'username': 'ana', 'password': 'gema-73-x'});
    });

    test('quienSoy manda el token en el header Authorization y devuelve el usuario', () async {
      final (:cuentas, :pedidos) = _contestando(200, {'username': 'ana', 'id': 1});

      expect(await cuentas.quienSoy('abc123'), 'ana');
      expect(pedidos.single.method, 'GET');
      expect(pedidos.single.headers['Authorization'], 'Token abc123');
    });

    test('salir manda el token a /auth/token/logout/', () async {
      final (:cuentas, :pedidos) = _contestando(204);

      await cuentas.salir('abc123');

      expect(pedidos.single.method, 'POST');
      expect(pedidos.single.url.path, '/auth/token/logout/');
      expect(pedidos.single.headers['Authorization'], 'Token abc123');
    });

    test('borrarCuenta manda el token y la contraseña actual con DELETE', () async {
      final (:cuentas, :pedidos) = _contestando(204);

      await cuentas.borrarCuenta(token: 'abc123', contrasena: 'gema-73-x');

      expect(pedidos.single.method, 'DELETE');
      expect(pedidos.single.url.path, '/auth/users/me/');
      expect(pedidos.single.headers['Authorization'], 'Token abc123');
      expect(jsonDecode(pedidos.single.body), {'current_password': 'gema-73-x'});
    });

    test('un 400 se convierte en ErrorDeCuenta, con los mensajes de cada campo', () async {
      final (:cuentas, pedidos: _) = _contestando(400, {
        'username': ['Ya existe un usuario con este nombre.'],
        'password': ['Esta contraseña es demasiado común.', 'Esta contraseña es completamente numérica.'],
      });

      final error = await _errorDe(() => cuentas.crearCuenta(usuario: 'ana', contrasena: 'x', repetida: 'x'));

      expect(error.de('username'), 'Ya existe un usuario con este nombre.');
      expect(error.porCampo['password'], hasLength(2));
      expect(error.generales, isEmpty);
    });

    test('los errores que no son de un campo van en "generales", con sus acentos', () async {
      final (:cuentas, pedidos: _) = _contestando(400, {
        'non_field_errors': ['No puede iniciar sesión con las credenciales proporcionadas.'],
      });

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'mala'));

      expect(error.generales, ['No puede iniciar sesión con las credenciales proporcionadas.']);
    });

    test('demasiados intentos (429) también es un ErrorDeCuenta, con el mensaje del servidor', () async {
      final (:cuentas, pedidos: _) = _contestando(429, {'detail': 'Solicitud fue regulada.'});

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'mala'));

      expect(error.generales, ['Solicitud fue regulada.']);
    });

    test('un 401 es SesionVencida', () async {
      final (:cuentas, pedidos: _) = _contestando(401, {'detail': 'Token inválido.'});

      expect(() => cuentas.quienSoy('vencido'), throwsA(isA<SesionVencida>()));
    });

    test('un error del servidor (500) es un ErrorDeCuenta con un mensaje propio', () async {
      final (:cuentas, pedidos: _) = _contestando(500);

      final error = await _errorDe(() => cuentas.quienSoy('abc'));

      expect(error.generales.single, contains('El servidor tuvo un problema'));
    });

    test('si no se puede hablar con el servidor, es SinConexion', () async {
      final cuentas = ClienteCuentas(
        MockClient((pedido) async => throw http.ClientException('sin red', pedido.url)),
        Uri.parse('https://servidor.test/'),
      );

      expect(() => cuentas.entrar(usuario: 'ana', contrasena: 'x'), throwsA(isA<SinConexion>()));
    });
  });
}

Future<ErrorDeCuenta> _errorDe(Future<void> Function() pedido) async {
  try {
    await pedido();
  } on ErrorDeCuenta catch (error) {
    return error;
  }
  fail('Se esperaba un ErrorDeCuenta');
}
