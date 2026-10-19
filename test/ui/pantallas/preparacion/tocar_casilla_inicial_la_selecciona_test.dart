import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: tocar una casilla inicial la selecciona', (tester) async {
    await abrirPreparacion(tester);

    await tocar(tester, casillaTocable('E4'));

    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.seleccionada), {'E4'});
  });
}
