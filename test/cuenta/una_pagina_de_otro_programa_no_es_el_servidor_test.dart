import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ClienteCuentas clienteQueContesta(
  int estado,
  String cuerpo, {
  String tipo = 'text/html',
}) => ClienteCuentas(
  MockClient(
    (_) async => http.Response(cuerpo, estado, headers: {'content-type': tipo}),
  ),
  Uri.parse('https://servidor.test:8443/'),
);

/// Solo cuenta como "servidor disponible" una respuesta de Brilliant (JSON). Antes, una
/// página de otro programa (por ejemplo, el 400 en HTML que da Django con una dirección
/// que no conoce) contaba como que el servidor estaba, y todo pedido fallaba igual.
void main() {
  test('Una página HTML con un 400 no es el servidor', () async {
    final cliente = clienteQueContesta(
      400,
      '<html><body>Bad Request</body></html>',
    );

    expect(cliente.probarConexion(), throwsA(isA<SinConexion>()));
  });

  test('El 401 en JSON de Brilliant (sin token) sí es el servidor', () async {
    final cliente = clienteQueContesta(
      401,
      '{"detail": "Las credenciales de autenticación no se proveyeron."}',
      tipo: 'application/json',
    );

    await cliente.probarConexion();
  });

  test(
    'El 429 en JSON de Brilliant (demasiados intentos) también es el servidor',
    () async {
      final cliente = clienteQueContesta(
        429,
        '{"detail": "Solicitud fue regulada (throttled)."}',
        tipo: 'application/json',
      );

      await cliente.probarConexion();
    },
  );
}
