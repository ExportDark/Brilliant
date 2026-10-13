import 'package:flutter_test/flutter_test.dart';

import '../../../juego/ayudantes.dart';
import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: sin jugada, "Pasar turno" ocupa el lugar de "Tirar dados"', (
    tester,
  ) async {
    await abrirPartida(tester, tablero: soloCabeElSeisEnE5(), caras: [2, 3]);

    await tocar(tester, botonTirar);

    expect(botonPasar, findsOneWidget);
    expect(botonTirar, findsNothing);
    expect(
      find.text('No hay jugada con ningún dado como ancla: pasa el turno.'),
      findsOneWidget,
    );
  });
}
