import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/cliente_http_io.dart';

/// Estas pruebas hablan con el servidor de cuentas de verdad, por HTTPS. No
/// corren con el `flutter test` de siempre: hay que levantar el servidor
/// (`servidor\iniciar.bat`) y pedirlas con
/// `flutter test --dart-define=CON_SERVIDOR=true test/cuenta/contra_el_servidor_test.dart`.
const _conServidor = bool.fromEnvironment('CON_SERVIDOR');
const _sinServidor = 'Necesita el servidor de cuentas corriendo y --dart-define=CON_SERVIDOR=true';

final _servidor = Uri.parse('https://localhost:8443/');

void main() {
  test(
    'ClienteCuentas contra el servidor de verdad: crear la cuenta, entrar, quién soy, salir y '
    'borrarla, por HTTPS con la autoridad local',
    () async {
      final certificado = File('assets/certificados/brilliant_ca.pem').readAsBytesSync();
      final cuentas = ClienteCuentas(clienteQueSoloConfiaEn(certificado), _servidor);
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
}
