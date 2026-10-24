import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('PantallaEleccionDeMapa: se abre sin desbordarse y las 4 tarjetas caben a lo ancho', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      testWidgets('en $nombre (${tamano.width.toInt()}×${tamano.height.toInt()})', (tester) async {
        await abrirApp(tester, tamano: tamano);

        // Si algo no cabe, Flutter avisa con un error de desborde.
        expect(tester.takeException(), isNull);
        for (final mapa in mapas) {
          expect(cabeALoAncho(tester, tarjetaDe(mapa)), isTrue, reason: mapa.nombre);
        }
      });
    }
  });
}
