import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('PantallaPreparacion: se abre sin desbordarse', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      testWidgets('en $nombre (${tamano.width.toInt()}×${tamano.height.toInt()})', (tester) async {
        await abrirPreparacion(tester, tamano: tamano);

        // Si algo no cabe, Flutter avisa con un error de desborde.
        expect(tester.takeException(), isNull);
      });
    }
  });
}
