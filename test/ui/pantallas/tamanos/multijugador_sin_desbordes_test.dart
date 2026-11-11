import 'package:flutter_test/flutter_test.dart';

import '../../../multijugador/ayudantes_salas.dart';
import '../ayudantes_pantallas.dart';

final _nombres = [
  'ana',
  'beto_con_un_nombre_muy_largo',
  'carla.perez-2',
  'dario',
  'elena',
  'fernando_el_ultimo',
];

void main() {
  group('Las pantallas del multijugador se abren sin desbordarse', () {
    for (final MapEntry(key: nombre, value: tamano) in tamanosDePantalla.entries) {
      final medidas = '${tamano.width.toInt()}×${tamano.height.toInt()}';

      testWidgets('lobby con 6 jugadores y la preparación, en $nombre ($medidas)', (tester) async {
        final salas = SalasFalsas();
        await abrirMultijugador(tester, salas, tamano: tamano);
        expect(tester.takeException(), isNull, reason: 'crear o unirse');

        await crearSala(
          tester,
          salas,
          vistaDePrueba(
            jugadores: [
              jugadorJson(_nombres[0], anfitrion: true),
              for (final n in _nombres.skip(1)) jugadorJson(n),
            ],
          ),
        );
        expect(tester.takeException(), isNull, reason: 'el lobby');

        salas.vista = vistaDePrueba(version: 2, estado: 'preparando', segundosRestantes: 60);
        await pasarSegundos(tester, 1);
        expect(tester.takeException(), isNull, reason: 'repartir mis números');

        salas.vista = vistaDePrueba(
          version: 3,
          estado: 'preparando',
          preparado: true,
          segundosRestantes: 41,
          jugadores: [
            jugadorJson(_nombres[0], anfitrion: true, listo: true),
            for (final n in _nombres.skip(1)) jugadorJson(n),
          ],
        );
        await pasarSegundos(tester, 1);
        expect(tester.takeException(), isNull, reason: 'esperar a los demás');
      });

      testWidgets('la partida con panel de zonas y el resultado, en $nombre ($medidas)', (tester) async {
        final salas = SalasFalsas();
        await abrirMultijugador(tester, salas, tamano: tamano);

        await crearSala(
          tester,
          salas,
          vistaDePrueba(
            estado: 'jugando',
            ronda: 7,
            dados: const [1, 3],
            segundosRestantes: 40,
            tablero: const {'E1': 1, 'A3': 3, 'D1': 3},
            jugadores: [
              jugadorJson(_nombres[0], anfitrion: true, puntos: 12),
              for (final n in _nombres.skip(1)) jugadorJson(n, puntos: 4, listo: true),
            ],
            zonas: [
              zonaJson(
                id: 4,
                tipo: 'azul',
                color: 'azul',
                casillas: ['C1', 'C2', 'D2', 'D3'],
                puestos: [
                  {'usuario': _nombres[1], 'puesto': 1, 'ronda': 12},
                  {'usuario': _nombres[5], 'puesto': 2, 'ronda': 15},
                ],
                puntosSiguiente: 3,
              ),
              zonaJson(
                id: 10,
                tipo: 'gris',
                color: 'gris',
                casillas: ['D1', 'D7'],
                puestos: [
                  {'usuario': _nombres[0], 'puesto': 1, 'ronda': 3},
                  {'usuario': _nombres[1], 'puesto': 1, 'ronda': 3},
                  {'usuario': _nombres[2], 'puesto': 3, 'ronda': 6},
                ],
                agotada: true,
                puntosSiguiente: 0,
              ),
            ],
          ),
        );
        expect(tester.takeException(), isNull, reason: 'la partida');

        salas.vista = vistaDePrueba(
          version: 9,
          estado: 'terminada',
          resultado: {
            'motivo': 'tablero_lleno',
            'ganadores': [_nombres[0]],
            'ranking': [
              for (final (i, n) in _nombres.indexed)
                {'usuario': n, 'estado': i == 5 ? 'se_rindio' : 'activo', 'puntos': 20 - i, 'primeros': 1},
            ],
          },
        );
        await pasarSegundos(tester, 1);
        expect(tester.takeException(), isNull, reason: 'el resultado');
      });
    }
  });
}
