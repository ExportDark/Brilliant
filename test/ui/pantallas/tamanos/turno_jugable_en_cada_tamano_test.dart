import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('PantallaPartida: se puede jugar un turno entero', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      testWidgets('en $nombre (${tamano.width.toInt()}×${tamano.height.toInt()})', (tester) async {
        await abrirPartida(tester, tamano: tamano);

        // En pantallas bajas, los botones pueden quedar abajo: se hace scroll.
        await tester.ensureVisible(botonTirar);
        await tocar(tester, botonTirar);
        await tester.ensureVisible(dadoEn(0));
        await tocar(tester, dadoEn(0));
        await tester.ensureVisible(casillaTocable('B1'));
        await tocar(tester, casillaTocable('B1'));

        expect(celdaEn(tester, 'B1').celda.valor, 3);
        expect(find.text('Turno 2'), findsOneWidget);
      });
    }
  });
}
