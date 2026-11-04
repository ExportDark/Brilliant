import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/cliente_http_io.dart';
import 'package:brilliant/cuenta/reglas_de_cuenta.dart';

/// Estas pruebas hablan con el servidor de cuentas de verdad, por HTTPS. No
/// corren con el `flutter test` de siempre: hay que levantar el servidor
/// (`servidor\iniciar.bat`) y pedirlas con
/// `flutter test --dart-define=CON_SERVIDOR=true test/cuenta/contra_el_servidor_test.dart`.
const _conServidor = bool.fromEnvironment('CON_SERVIDOR');
const _sinServidor = 'Necesita el servidor de cuentas corriendo y --dart-define=CON_SERVIDOR=true';

final _servidor = Uri.parse('https://localhost:8443/');

ClienteCuentas _cuentas() => ClienteCuentas(
      clienteQueSoloConfiaEn(File('assets/certificados/brilliant_ca.pem').readAsBytesSync()),
      _servidor,
    );

/// El error con que el servidor rechazó [pedido].
Future<ErrorDeCuenta> _errorDe(Future<Object?> pedido) async {
  try {
    await pedido;
  } on ErrorDeCuenta catch (error) {
    return error;
  }
  fail('El servidor no rechazó el pedido');
}

void main() {
  test(
    'ClienteCuentas contra el servidor de verdad: crear la cuenta, entrar, quién soy, salir y '
    'borrarla, por HTTPS con la autoridad local',
    () async {
      final cuentas = _cuentas();
      final usuario = 'prueba${DateTime.now().millisecondsSinceEpoch}';
      const contrasena = 'gema-brillante-73';

      await cuentas.crearCuenta(usuario: usuario, contrasena: contrasena, repetida: contrasena);
      final token = await cuentas.entrar(usuario: usuario, contrasena: contrasena);
      expect(await cuentas.quienSoy(token), usuario);

      await cuentas.salir(token);
      await expectLater(cuentas.quienSoy(token), throwsA(isA<SesionVencida>()));

      final otroToken = await cuentas.entrar(usuario: usuario, contrasena: contrasena);
      await expectLater(
        cuentas.borrarCuenta(token: otroToken, contrasena: 'no-es-la-buena-1'),
        throwsA(isA<ErrorDeCuenta>()),
      );
      await cuentas.borrarCuenta(token: otroToken, contrasena: contrasena);
      await expectLater(
        cuentas.entrar(usuario: usuario, contrasena: contrasena),
        throwsA(isA<ErrorDeCuenta>()),
      );
    },
    skip: _conServidor ? false : _sinServidor,
  );

  test(
    'Un cliente que confía en las autoridades del sistema, y no en la de Brilliant, no se conecta',
    () async {
      final cuentas = ClienteCuentas(IOClient(HttpClient()), _servidor);

      await expectLater(cuentas.quienSoy('cualquiera'), throwsA(isA<SinConexion>()));
    },
    skip: _conServidor ? false : _sinServidor,
  );

  test(
    'Las reglas de las cuentas contra el servidor de verdad: los mismos mensajes que la app, '
    'sin distinguir mayúsculas, la contraseña con espacios y una sola sesión activa',
    () async {
      final cuentas = _cuentas();
      // Cada cuenta nueva cuenta para el límite de 10 por hora: aquí van 3.
      final usuario = 'regla${DateTime.now().millisecondsSinceEpoch}';
      const contrasena = '  gema brillante 73  ';

      final raro = await _errorDe(
        cuentas.crearCuenta(usuario: 'аna', contrasena: contrasena, repetida: contrasena),
      );
      expect(raro.porCampo['username'], [usuarioConCaracteresRaros]);

      await cuentas.crearCuenta(usuario: usuario, contrasena: contrasena, repetida: contrasena);
      final repetido = await _errorDe(cuentas.crearCuenta(
        usuario: usuario.toUpperCase(),
        contrasena: contrasena,
        repetida: contrasena,
      ));
      expect(repetido.porCampo['username'], ['Ya existe un usuario con este nombre.']);

      // Con otras mayúsculas y la contraseña con sus espacios.
      final token = await cuentas.entrar(usuario: usuario.toUpperCase(), contrasena: contrasena);
      expect(await cuentas.quienSoy(token), usuario);

      final otroAparato = await _errorDe(cuentas.entrar(usuario: usuario, contrasena: contrasena));
      expect(otroAparato.generales.single, contains('otro aparato'));

      await cuentas.borrarCuenta(token: token, contrasena: contrasena);
    },
    skip: _conServidor ? false : _sinServidor,
  );
}
