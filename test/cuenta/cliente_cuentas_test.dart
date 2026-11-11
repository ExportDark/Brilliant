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

    test('demasiados intentos (429) es un ErrorDeCuenta en español, con los segundos que dijo el '
        'servidor', () async {
      final (:cuentas, pedidos: _) = _contestando(429, {
        'detail': 'Solicitud fue regulada (throttled). Se espera que esté disponible en 37 segundos.',
      });

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'mala'));

      expect(error.generales, ['Demasiados intentos seguidos. Espera 37 segundos e intenta de nuevo.']);
    });

    test('demasiados intentos (429) sin segundos en el mensaje dice "un momento"', () async {
      final (:cuentas, pedidos: _) = _contestando(429, {'detail': 'Solicitud fue regulada.'});

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'mala'));

      expect(error.generales, ['Demasiados intentos seguidos. Espera un momento e intenta de nuevo.']);
    });

    test('probarConexion: un servidor que limita los intentos (429) está ahí', () async {
      final (:cuentas, pedidos: _) = _contestando(429, {'detail': 'Solicitud fue regulada.'});

      await cuentas.probarConexion();
    });

    test('la cuenta activa en otro aparato (409) es un ErrorDeCuenta con el mensaje', () async {
      final (:cuentas, pedidos: _) = _contestando(409, {
        'non_field_errors': ['Esta cuenta ya tiene la sesión iniciada en otro aparato.'],
      });

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'buena'));

      expect(error.generales, ['Esta cuenta ya tiene la sesión iniciada en otro aparato.']);
    });

    test('los mensajes de knox, en "error", también se ven', () async {
      final (:cuentas, pedidos: _) = _contestando(403, {
        'error': 'Maximum amount of tokens allowed per user exceeded.',
      });

      final error = await _errorDe(() => cuentas.entrar(usuario: 'ana', contrasena: 'buena'));

      expect(error.generales, ['Maximum amount of tokens allowed per user exceeded.']);
      expect(error.porCampo, isEmpty);
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

    test('al cambiar la dirección del servidor, los pedidos van a la nueva', () async {
      final (:cuentas, :pedidos) = _contestando(200, {'username': 'ana'});

      cuentas.servidor = Uri.parse('https://192.168.137.252:8443/');
      await cuentas.quienSoy('abc123');

      expect(pedidos.single.url.toString(), 'https://192.168.137.252:8443/auth/users/me/');
    });

    test('probarConexion da por bueno el 401 de quién soy sin token: el servidor está ahí', () async {
      final (:cuentas, :pedidos) = _contestando(401, {'detail': 'Sin credenciales.'});

      await cuentas.probarConexion();

      expect(pedidos.single.headers.containsKey('Authorization'), isFalse);
    });

    test('probarConexion en otra dirección no cambia la del servidor', () async {
      final (:cuentas, :pedidos) = _contestando(401, {'detail': 'Sin credenciales.'});
      final antes = cuentas.servidor;

      await cuentas.probarConexion(en: Uri.parse('https://192.168.137.252:8443/'));

      expect(pedidos.single.url.toString(), 'https://192.168.137.252:8443/auth/users/me/');
      expect(cuentas.servidor, antes);
    });

    test('si no se puede hablar con el servidor, es SinConexion', () async {
      final cuentas = ClienteCuentas(
        MockClient((pedido) async => throw http.ClientException('sin red', pedido.url)),
        Uri.parse('https://servidor.test/'),
      );

      expect(() => cuentas.entrar(usuario: 'ana', contrasena: 'x'), throwsA(isA<SinConexion>()));
    });

    group('con una conexión inactiva que el servidor ya cerró', () {
      /// Un servidor cuya primera conexión ya se cerró: el primer intento falla
      /// como falla `HttpClient` al reusarla, y el siguiente llega.
      ({ClienteCuentas cuentas, List<http.Request> intentos}) conUnaConexionMuerta() {
        final intentos = <http.Request>[];
        final mock = MockClient((pedido) async {
          intentos.add(pedido);
          if (intentos.length == 1) {
            throw http.ClientException('Connection closed before full header was received');
          }
          return http.Response('', 204);
        });
        return (cuentas: ClienteCuentas(mock, Uri.parse('https://servidor.test/')), intentos: intentos);
      }

      test('cerrar sesión se reintenta una vez, con el mismo token', () async {
        final (:cuentas, :intentos) = conUnaConexionMuerta();

        await cuentas.salir('abc123');

        expect(intentos, hasLength(2));
        expect(intentos.last.headers['Authorization'], 'Token abc123');
        expect(intentos.last.url.path, '/auth/token/logout/');
      });

      test('revisar quién soy también', () async {
        final (:cuentas, :intentos) = conUnaConexionMuerta();

        await cuentas.quienSoy('abc123').catchError((_) => '');

        expect(intentos, hasLength(2));
      });

      test('si el segundo intento también falla, es SinConexion', () async {
        var intentos = 0;
        final cuentas = ClienteCuentas(
          MockClient((pedido) async {
            intentos++;
            throw http.ClientException('sin red', pedido.url);
          }),
          Uri.parse('https://servidor.test/'),
        );

        await expectLater(cuentas.salir('abc123'), throwsA(isA<SinConexion>()));
        expect(intentos, 2);
      });

      test('crear la cuenta y borrarla no se reintentan solos: podrían repetirse', () async {
        final (:cuentas, :intentos) = conUnaConexionMuerta();
        await expectLater(
          cuentas.crearCuenta(usuario: 'ana', contrasena: 'x', repetida: 'x'),
          throwsA(isA<SinConexion>()),
        );
        expect(intentos, hasLength(1));

        final otras = conUnaConexionMuerta();
        await expectLater(
          otras.cuentas.borrarCuenta(token: 't', contrasena: 'x'),
          throwsA(isA<SinConexion>()),
        );
        expect(otras.intentos, hasLength(1));
      });

      test('un tiempo agotado no se reintenta: el pedido pudo haber llegado', () async {
        var intentos = 0;
        final cuentas = ClienteCuentas(
          MockClient((pedido) async {
            intentos++;
            await Future<void>.delayed(const Duration(seconds: 5));
            return http.Response('', 204);
          }),
          Uri.parse('https://servidor.test/'),
        );

        await expectLater(
          cuentas.probarConexion(espera: const Duration(milliseconds: 20)),
          throwsA(isA<SinConexion>()),
        );
        expect(intentos, 1);
      });
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
