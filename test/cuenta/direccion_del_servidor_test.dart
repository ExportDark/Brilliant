import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/direccion_del_servidor.dart';

void main() {
  group('direccionDesdeTexto', () {
    test('con solo la IP, usa HTTPS y el puerto del servidor', () {
      expect(direccionDesdeTexto('192.168.137.252').toString(), 'https://192.168.137.252:8443/');
    });

    test('respeta el puerto si se escribe', () {
      expect(direccionDesdeTexto('192.168.137.252:9000').toString(), 'https://192.168.137.252:9000/');
    });

    test('acepta la dirección completa, y los espacios de los extremos', () {
      expect(
        direccionDesdeTexto('  https://192.168.137.252:8443/  ').toString(),
        'https://192.168.137.252:8443/',
      );
      expect(direccionDesdeTexto('localhost').toString(), 'https://localhost:8443/');
    });

    test('rechaza lo que no es una dirección', () {
      expect(direccionDesdeTexto(''), isNull);
      expect(direccionDesdeTexto('   '), isNull);
      expect(direccionDesdeTexto('mi pc'), isNull);
    });

    test('rechaza http: con el servidor solo se habla por HTTPS', () {
      expect(direccionDesdeTexto('http://192.168.137.252:8443'), isNull);
    });
  });

  group('textoDeDireccion', () {
    test('con el puerto de siempre, muestra solo la IP', () {
      expect(textoDeDireccion(Uri.parse('https://192.168.137.252:8443/')), '192.168.137.252');
    });

    test('con otro puerto, lo muestra', () {
      expect(textoDeDireccion(Uri.parse('https://192.168.137.252:9000/')), '192.168.137.252:9000');
    });

    test('de ida y vuelta da la misma dirección', () {
      final direccion = Uri.parse('https://10.22.13.30:8443/');
      expect(direccionDesdeTexto(textoDeDireccion(direccion)), direccion);
    });
  });
}
