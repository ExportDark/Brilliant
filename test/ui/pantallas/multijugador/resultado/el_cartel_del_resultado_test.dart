import 'package:brilliant/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

/// Abre el resultado de una partida que ganaron [ganadores] (yo soy "ana").
Future<void> abrirResultado(WidgetTester tester, List<String> ganadores, String motivo) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(
    tester,
    salas,
    vistaDePrueba(
      estado: 'terminada',
      resultado: {'motivo': motivo, 'ganadores': ganadores, 'ranking': []},
    ),
  );
}

Color colorDelCartel(WidgetTester tester) {
  final cartel = tester.widget<Container>(find.byKey(const ValueKey('cartel-del-resultado')));
  return (cartel.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('Si ganaste, el cartel del resultado es amarillo, como las fichas', (tester) async {
    await abrirResultado(tester, ['ana'], 'tablero_lleno');

    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(colorDelCartel(tester), Paleta.ficha);
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });

  testWidgets('Si ganó otro, el cartel es de cartón y lleva el trofeo', (tester) async {
    await abrirResultado(tester, ['beto'], 'sin_jugadas');

    expect(find.text('Ganó beto'), findsOneWidget);
    expect(colorDelCartel(tester), Paleta.cartonClaro);
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });

  testWidgets('Si nadie ganó, lleva una bandera en vez del trofeo', (tester) async {
    await abrirResultado(tester, [], 'todos_se_fueron');

    expect(find.text('Nadie ganó'), findsOneWidget);
    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
  });
}
