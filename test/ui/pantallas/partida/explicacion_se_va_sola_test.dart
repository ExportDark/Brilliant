import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: la explicación se va sola a los 4 segundos y vuelve la '
      'indicación de siempre', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);
    await tocar(tester, casillaTocable('C2'));
    expect(explicacion, findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(explicacion, findsOneWidget, reason: 'a los 3 s sigue');

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(explicacion, findsNothing);
    expect(find.textContaining('Pon el 3 en una casilla iluminada'), findsOneWidget);
  });
}
