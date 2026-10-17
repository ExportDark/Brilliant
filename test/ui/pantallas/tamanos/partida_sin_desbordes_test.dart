import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('PantallaPartida: no se desborda ni en su estado más alto', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      testWidgets('en $nombre (${tamano.width.toInt()}×${tamano.height.toInt()})', (tester) async {
        await abrirPartida(tester, tamano: tamano);

        // Con dados, dado ancla elegido y la explicación de C2 a la vista. En
        // pantallas bajas los dados quedan abajo: se hace scroll antes de tocar.
        await tester.ensureVisible(botonTirar);
        await tocar(tester, botonTirar);
        await tester.ensureVisible(dadoEn(0));
        await tocar(tester, dadoEn(0));
        await tester.ensureVisible(casillaTocable('C2'));
        await tocar(tester, casillaTocable('C2'));

        expect(explicacion, findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
