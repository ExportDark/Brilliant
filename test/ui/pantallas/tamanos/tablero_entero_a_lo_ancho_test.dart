import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  group('PantallaPartida: las 49 casillas caben a lo ancho de la pantalla', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      testWidgets('en $nombre (${tamano.width.toInt()}×${tamano.height.toInt()})', (tester) async {
        await abrirPartida(tester, tamano: tamano);

        final casillas = find.byType(CeldaWidget);
        expect(casillas, findsNWidgets(49));
        for (final casilla in casillas.evaluate()) {
          final notacion = (casilla.widget as CeldaWidget).celda.posicion.notacion;
          expect(
            cabeALoAncho(tester, find.byWidget(casilla.widget)),
            isTrue,
            reason: 'la casilla $notacion se sale de la pantalla',
          );
        }
      });
    }
  });
}
