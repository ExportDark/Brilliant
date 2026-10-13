import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: tocar una casilla ocupada no hace nada', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 0);

    // C1 ya tiene el 4: ni siquiera responde al toque.
    expect(casillaTocable('C1'), findsNothing);
    await tocar(tester, dibujoDe('C1'));

    expect(explicacion, findsNothing);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(celdaEn(tester, 'C1').celda.valor, 4);
  });
}
