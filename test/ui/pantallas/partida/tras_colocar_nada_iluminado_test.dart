import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: al anotar, se apaga toda la iluminación del turno', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);

    await tocar(tester, casillaTocable('B1'));

    expect(
      celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.iluminacion != Iluminacion.normal),
      isEmpty,
    );
    expect(celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.numeroResaltado), isEmpty);
  });
}
