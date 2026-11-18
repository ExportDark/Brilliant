import 'package:brilliant/ui/pantallas/multijugador/tablero_chico.dart';
import 'package:brilliant/ui/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

Finder chicoDe(String usuario) => find.byKey(ValueKey('tablero-chico-$usuario'));

TableroChico tableroChicoDe(WidgetTester tester, String usuario) =>
    tester.widget<TableroChico>(chicoDe(usuario));

const iniciales = ['A3', 'B6', 'C4', 'E1', 'E7', 'F5'];

Future<void> abrirConTableros(WidgetTester tester) async {
  final salas = SalasFalsas();
  await abrirMultijugador(tester, salas);
  await crearSala(
    tester,
    salas,
    vistaDePrueba(
      estado: 'jugando',
      ronda: 3,
      dados: const [1, 3],
      segundosRestantes: 40,
      tablero: const {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2},
      jugadores: [
        jugadorJson('ana', anfitrion: true, ocupadas: [...iniciales, 'D1']),
        jugadorJson('beto', ocupadas: [...iniciales, 'D1', 'D7'], ultima: 'D7'),
        jugadorJson('carla', estado: 'se_rindio', ocupadas: iniciales),
      ],
    ),
  );
}

void main() {
  testWidgets('En el marcador, cada jugador tiene su tablero chico con las casillas que ocupó '
      'y la de la última ronda', (tester) async {
    await abrirConTableros(tester);

    for (final usuario in ['ana', 'beto', 'carla']) {
      expect(chicoDe(usuario), findsOneWidget, reason: usuario);
    }
    final beto = tableroChicoDe(tester, 'beto');
    expect(beto.ocupadas, {...iniciales, 'D1', 'D7'});
    expect(beto.ultima, 'D7');
    expect(tableroChicoDe(tester, 'ana').ultima, isNull);
    // Para lectores de pantalla, cuántas lleva.
    expect(find.bySemanticsLabel('Tablero de beto: 8 de 49 casillas ocupadas'), findsOneWidget);
  });

  testWidgets('El de quien se fue se ve apagado', (tester) async {
    await abrirConTableros(tester);

    expect(tableroChicoDe(tester, 'carla').apagado, isTrue);
    expect(tableroChicoDe(tester, 'beto').apagado, isFalse);
  });

  testWidgets('El tablero chico nunca dibuja un número', (tester) async {
    await abrirConTableros(tester);

    expect(find.descendant(of: chicoDe('beto'), matching: find.byType(Text)), findsNothing);
  });

  testWidgets('La casilla de la última ronda lleva el aro amarillo; sin última, no hay aro', (
    tester,
  ) async {
    await abrirConTableros(tester);

    RenderObject dibujoDe(String usuario) => tester.renderObject(
      find.descendant(of: chicoDe(usuario), matching: find.byType(CustomPaint)),
    );
    // Algún rectángulo dibujado con el trazo amarillo de ficha.
    final aro = paints
      ..something((metodo, argumentos) {
        if (metodo != #drawRRect) return false;
        final pintura = argumentos[1] as Paint;
        // Por su valor ARGB: el color de un Paint pierde precisión al guardarse.
        return pintura.color.toARGB32() == Paleta.ficha.toARGB32() &&
            pintura.style == PaintingStyle.stroke;
      });
    expect(dibujoDe('beto'), aro);
    expect(dibujoDe('ana'), isNot(aro));
  });
}
