import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: solo se resalta el número exacto que sacó el dado ancla', (
    tester,
  ) async {
    await abrirPartida(tester);

    // Dado ancla 4: de los 6 números iniciales, solo el 4 de C1.
    await tirarYElegirAncla(tester, 0);

    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.numeroResaltado), {'C1'});
  });
}
