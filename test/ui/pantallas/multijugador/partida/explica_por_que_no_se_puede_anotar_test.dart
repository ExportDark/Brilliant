import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

const _iniciales = {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2};

/// Una ronda del mapa 2, con las reglas de la app, en la que hay una casilla pegada al
/// número del ancla que la regla de su zona rechaza. Se busca en vez de escribirla a
/// mano, y las jugadas legales salen de las mismas reglas, como las manda el servidor.
({VistaDeSala vista, String bloqueada}) _rondaConUnaCasillaBloqueada() {
  final mapa = mapas.firstWhere((m) => m.nivel == 2);
  final tablero = Tablero.desdeMapa(mapa).conValores({
    for (final MapEntry(:key, :value) in _iniciales.entries) Posicion.desdeNotacion(key): value,
  });
  List<String> legales(int ancla, int valor) => [
        for (final celda in tablero.celdas)
          if (evaluarJugada(tablero, celda.posicion, ancla: ancla, valor: valor) is JugadaValida)
            celda.posicion.notacion,
      ];

  for (final ancla in _iniciales.values) {
    for (var valor = 1; valor <= 6; valor++) {
      if (valor == ancla || legales(ancla, valor).isEmpty) continue;
      for (final celda in tablero.celdas) {
        final resultado = evaluarJugada(tablero, celda.posicion, ancla: ancla, valor: valor);
        if (resultado is! ReglaRota) continue;
        return (
          bloqueada: celda.posicion.notacion,
          vista: vistaDePrueba(
            estado: 'jugando',
            ronda: 1,
            dados: [ancla, valor],
            segundosRestantes: 60,
            tablero: _iniciales,
            jugadas: [
              {'ancla': ancla, 'valor': valor, 'casillas': legales(ancla, valor)},
              {'ancla': valor, 'valor': ancla, 'casillas': legales(valor, ancla)},
            ],
          ),
        );
      }
    }
  }
  fail('No hay ninguna casilla que la regla bloquee con estas iniciales');
}

void main() {
  testWidgets('En línea, la casilla que la regla bloquea se ve apagada, y al tocarla se explica '
      'la regla sin mandar nada; la explicación se va sola', (tester) async {
    final (:vista, :bloqueada) = _rondaConUnaCasillaBloqueada();
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vista);
    await tocar(tester, find.byKey(const ValueKey('dado-0')));

    expect(celdaEn(tester, bloqueada).iluminacion, Iluminacion.bloqueada);

    await tocar(tester, casillaTocable(bloqueada));

    expect(salas.llamadas.where((l) => l.startsWith('jugar')), isEmpty);
    expect(find.byKey(const ValueKey('explicacion')), findsOneWidget);
    expect(find.textContaining('Zona '), findsOneWidget);
    expect(celdaEn(tester, bloqueada).marcada, isTrue);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('explicacion')), findsNothing);
    expect(celdaEn(tester, bloqueada).marcada, isFalse);
  });

  testWidgets('En línea, una casilla iluminada sigue anotando y borra la explicación', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    await tocar(tester, find.byKey(const ValueKey('dado-0')));
    await tocar(tester, casillaTocable('G7'));
    expect(find.byKey(const ValueKey('explicacion')), findsOneWidget);

    await tocar(tester, casillaTocable('D1'));

    expect(salas.llamadas, contains('jugar 1 1 D1'));
    expect(find.byKey(const ValueKey('explicacion')), findsNothing);
  });

  testWidgets('Con la ronda nueva, la explicación de la anterior desaparece', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    await tocar(tester, find.byKey(const ValueKey('dado-0')));
    await tocar(tester, casillaTocable('G7'));

    salas.vista = vistaDePrueba(
      version: 8,
      estado: 'jugando',
      ronda: 2,
      dados: const [2, 5],
      segundosRestantes: 60,
      tablero: _iniciales,
    );
    await pasarSegundos(tester, 1);

    expect(find.byKey(const ValueKey('explicacion')), findsNothing);
  });
}
