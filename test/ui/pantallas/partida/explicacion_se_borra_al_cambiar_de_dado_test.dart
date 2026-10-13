import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: al cambiar de dado ancla, la explicación anterior desaparece', (
    tester,
  ) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);
    await tocar(tester, casillaTocable('C2'));
    expect(explicacion, findsOneWidget);

    await tocar(tester, dadoEn(1));

    expect(explicacion, findsNothing);
  });
}
