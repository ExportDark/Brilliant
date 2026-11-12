import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('Si el anfitrión cierra la sala, los demás ven "El anfitrión cerró la sala", sin '
      'un resultado de una partida que no se jugó', (tester) async {
    final salas = SalasFalsas()..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
    await abrirMultijugador(tester, salas);
    await tester.enterText(campoCodigo, 'k7m4qx');
    await tocar(tester, botonUnirse);

    salas.vista = vistaDePrueba(
      yo: 'beto',
      anfitrion: 'ana',
      version: 4,
      estado: 'terminada',
      resultado: {'motivo': 'sala_cerrada', 'ganadores': [], 'ranking': []},
    );
    await pasarSegundos(tester, 1);

    expect(find.text('El anfitrión cerró la sala.'), findsOneWidget);
    expect(find.text('Nadie ganó'), findsNothing);
    expect(find.byKey(const ValueKey('resultado')), findsNothing);
    await tocar(tester, find.byKey(const ValueKey('boton-volver')));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets('El anfitrión que cierra la sala vuelve directo a "Elige un mapa"', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());
    salas.alRendirse = null; // el servidor contesta 204

    await tocar(tester, find.byKey(const ValueKey('boton-salir')));

    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets('La flecha de atrás en el lobby sale de la sala y vuelve en un solo paso', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());
    salas.alRendirse = null;

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(salas.llamadas, contains('rendirse'));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
