import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import 'ayudantes_salas.dart';

void main() {
  group('VistaDeSala.desdeJson', () {
    test('lee todo lo que manda el servidor', () {
      final vista = VistaDeSala.desdeJson(vistaJson(
        codigo: 'AB23CD',
        version: 12,
        estado: 'jugando',
        nivel: 3,
        ronda: 4,
        dados: [2, 5],
        segundosRestantes: 41.5,
        tablero: {'E1': 1},
        jugadas: [
          {'ancla': 2, 'valor': 5, 'casillas': ['D1', 'F1']},
        ],
        jugadores: [
          jugadorJson('ana', anfitrion: true, puntos: 7, primeros: 1, zonas: [3]),
          jugadorJson('beto', listo: true, estado: 'desconectado'),
        ],
        zonas: [
          zonaJson(
            id: 3,
            tipo: 'azul',
            color: 'azul',
            puestos: [
              {'usuario': 'ana', 'puesto': 1, 'ronda': 3},
            ],
            puntosSiguiente: 5,
          ),
        ],
      ));

      expect(vista.codigo, 'AB23CD');
      expect(vista.version, 12);
      expect(vista.estado, EstadoDeSala.jugando);
      expect(vista.nivel, 3);
      expect(vista.ronda, 4);
      expect(vista.dados, [2, 5]);
      expect(vista.segundosRestantes, 41.5);
      expect(vista.soyElAnfitrion, isTrue);
      expect(vista.yo.tablero, {'E1': 1});
      expect(vista.yo.jugadas.single.casillas, ['D1', 'F1']);
      expect(vista.yo.puedeJugar, isTrue);
      expect(vista.jugadores.map((j) => (j.usuario, j.puntos, j.activo)), [
        ('ana', 7, true),
        ('beto', 0, false),
      ]);
      expect(vista.zonas.single.puestos.single.usuario, 'ana');
      expect(vista.zonas.single.puntosSiguiente, 5);
      expect(vista.resultado, isNull);
    });

    test('el resultado de una partida terminada', () {
      final vista = VistaDeSala.desdeJson(vistaJson(
        estado: 'terminada',
        resultado: {
          'motivo': 'ultimo_jugador',
          'ganadores': ['ana'],
          'ranking': [
            {'usuario': 'ana', 'estado': 'activo', 'puntos': 6, 'primeros': 1},
            {'usuario': 'beto', 'estado': 'se_rindio', 'puntos': 9, 'primeros': 2},
          ],
        },
      ));

      expect(vista.resultado!.motivo, 'ultimo_jugador');
      expect(vista.resultado!.ganadores, ['ana']);
      expect(vista.resultado!.ranking.map((f) => f.usuario), ['ana', 'beto']);
    });

    test('fuera de la partida no hay dados ni tiempo', () {
      final vista = VistaDeSala.desdeJson(vistaJson());

      expect(vista.dados, isNull);
      expect(vista.segundosRestantes, isNull);
    });

    test('un estado de sala que no existe es un error, no un valor por defecto', () {
      expect(
        () => VistaDeSala.desdeJson(vistaJson(estado: 'volando')),
        throwsA(isA<FormatException>()),
      );
    });

    test('un JSON incompleto lanza, no deja campos en null en silencio', () {
      final incompleto = vistaJson()..remove('jugadores');

      expect(() => VistaDeSala.desdeJson(incompleto), throwsA(anything));
    });
  });

  group('MiVista.puedeJugar', () {
    test('solo si está activo, no ha jugado y tiene dónde anotar', () {
      expect(partidaEnJuego().yo.puedeJugar, isTrue);
      expect(partidaEnJuego(accion: 'coloco').yo.puedeJugar, isFalse);
      expect(partidaEnJuego(accion: 'paso').yo.puedeJugar, isFalse);
      expect(partidaEnJuego(jugadas: const []).yo.puedeJugar, isFalse);
      expect(
        partidaEnJuego(jugadas: const [
          {'ancla': 1, 'valor': 3, 'casillas': <String>[]},
        ]).yo.puedeJugar,
        isFalse,
      );
    });

    test('quien quedó fuera no puede jugar aunque el servidor mande jugadas', () {
      final fuera = vistaDePrueba(
        estado: 'jugando',
        ronda: 1,
        dados: const [1, 3],
        miEstado: 'desconectado',
        jugadas: const [
          {'ancla': 1, 'valor': 3, 'casillas': ['D1']},
        ],
      );

      expect(fuera.yo.activo, isFalse);
      expect(fuera.yo.puedeJugar, isFalse);
    });
  });
}
