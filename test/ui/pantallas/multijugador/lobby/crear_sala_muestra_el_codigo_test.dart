import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/ui/pantallas/multijugador/pantalla_multijugador.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('"Elige un mapa" tiene el botón para jugar con otros, y lleva a crear o unirse', (
    tester,
  ) async {
    await abrirApp(tester, salas: SalasFalsas());

    await tocar(tester, botonMultijugador);

    expect(find.byType(PantallaMultijugador), findsOneWidget);
    expect(botonCrearSala, findsOneWidget);
    expect(campoCodigo, findsOneWidget);
    expect(botonUnirse, findsOneWidget);
  });

  testWidgets('Crear sala: entra al lobby y muestra el código para invitar', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(tester, salas, vistaDePrueba(codigo: 'K7M4QX'));

    expect(salas.llamadas, ['crear']);
    expect(find.byKey(const ValueKey('codigo-de-sala')), findsOneWidget);
    // Una ficha por letra.
    final letras = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const ValueKey('codigo-de-sala')),
            matching: find.byType(Text),
          ),
        )
        .map((texto) => texto.data)
        .join();
    expect(letras, 'K7M4QX');
    expect(find.textContaining('Jugadores (2/6)'), findsOneWidget);
    expect(find.byKey(const ValueKey('jugador-ana')), findsOneWidget);
  });

  testWidgets('el anfitrión se ve marcado y a sí mismo con "tú"', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await crearSala(tester, salas, vistaDePrueba());

    expect(find.text('ana (tú, anfitrión)'), findsOneWidget);
    expect(find.text('beto'), findsOneWidget);
  });

  testWidgets('sin conexión al crear: avisa y se queda donde estaba', (tester) async {
    final salas = SalasFalsas()..sinConexion = true;
    await abrirMultijugador(tester, salas);

    await crearSala(tester, salas, vistaDePrueba());

    expect(errorDeSala, findsOneWidget);
    expect(find.text('Sin conexión. Intenta de nuevo.'), findsOneWidget);
    expect(botonCrearSala, findsOneWidget);
  });
}
