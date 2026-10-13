import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: la indicación acompaña cada paso del turno', (tester) async {
    await abrirPartida(tester);
    expect(find.text('Tira los dados.'), findsOneWidget);

    await tocar(tester, botonTirar);
    expect(
      find.text('Elige el dado ancla: el otro se pone junto a una casilla con ese número.'),
      findsOneWidget,
    );

    await tocar(tester, dadoEn(0));
    expect(
      find.text('Pon el 3 junto a un 4 (arriba, abajo, izquierda o derecha).'),
      findsOneWidget,
    );
  });
}
