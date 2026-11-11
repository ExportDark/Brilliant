import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';
import '../cuenta/servidores/ayudantes_servidores.dart';

void main() {
  group('La lista de servidores se abre sin desbordarse', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      final medidas = '${tamano.width.toInt()}×${tamano.height.toInt()}';

      testWidgets('con 6 servidores de nombres largos, en $nombre ($medidas)', (tester) async {
        await abrirConVariosServidores(
          tester,
          tamano: tamano,
          nombres: [
            'LA-COMPUTADORA-DEL-CUARTO-DE-ARRIBA',
            'ORION',
            'VEGA',
            'SIRIO-DE-LA-OFICINA-GRANDE',
            'ALTAIR',
            'RIGEL',
          ],
        );
        expect(tester.takeException(), isNull, reason: 'iniciar sesión');

        await tocar(tester, enlaceCrearCuenta);
        expect(tester.takeException(), isNull, reason: 'crear cuenta');
      });
    }
  });
}
