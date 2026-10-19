import 'package:flutter_test/flutter_test.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: la indicación acompaña cada paso del turno', (tester) async {
    await abrirPartida(tester);
    expect(find.text('Tira los dados.'), findsOneWidget);

    await tocar(tester, botonTirar);
    expect(
      find.text('Toca un dado para usarlo de ancla: el otro va junto a una casilla con ese número.'),
      findsOneWidget,
    );

    await tocar(tester, dadoEn(0));
    expect(
      find.text('Pon el 3 en una casilla iluminada, junto a un\u00A04.'),
      findsOneWidget,
    );
  });
}
