import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/widgets/recuadro_de_aviso.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: la explicación va en la línea de arriba del tablero, sin '
      'recuadro, y la casilla tocada lleva un aro hasta que se va', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);

    await tocar(tester, casillaTocable('C2'));

    expect(find.textContaining('Zona azul — Todos iguales'), findsOneWidget);
    expect(find.byType(RecuadroDeAviso), findsNothing);
    expect(celdaEn(tester, 'C2').marcada, isTrue);
    expect(celdaEn(tester, 'C3').marcada, isFalse);
    // La indicación de siempre no está mientras tanto: la explicación ocupa su lugar.
    expect(find.textContaining('Pon el 3 en una casilla iluminada'), findsNothing);

    await tocar(tester, dadoEn(1));

    expect(celdaEn(tester, 'C2').marcada, isFalse);
  });
}
