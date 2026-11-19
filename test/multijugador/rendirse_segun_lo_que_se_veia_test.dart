import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/multijugador/sala_bloc.dart';
import 'package:brilliant/multijugador/sala_event.dart';
import 'package:brilliant/multijugador/sala_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_salas.dart';

/// Rendirse lleva el estado de la sala que el jugador estaba viendo al pedirlo. Si la sala
/// ya pasó a otro (la partida empezó mientras salía del lobby, o terminó con el diálogo
/// abierto), no se manda nada: lo que pidió ya no es lo que pasaría.
void main() {
  late SalasFalsas salas;
  late SalaBloc bloc;

  setUp(() {
    salas = SalasFalsas();
    bloc = SalaBloc(salas, intervalo: null);
  });
  tearDown(() => bloc.close());

  Future<void> mandar(SalaEvent evento) async {
    bloc.add(evento);
    await pumpEventQueue();
  }

  Future<void> entrar(VistaDeSala vista) async {
    salas.vista = vista;
    await mandar(const SalaCreada());
  }

  int rendiciones() => salas.llamadas.where((l) => l == 'rendirse').length;

  test(
    'Salir del lobby cuando la partida ya empezó no rinde a nadie',
    () async {
      await entrar(vistaDePrueba(estado: 'preparando', segundosRestantes: 60));

      await mandar(const Rendirse(desde: EstadoDeSala.esperando));

      expect(rendiciones(), 0);
      expect(bloc.state.fin, FinDeSala.ninguno);
    },
  );

  test('Un "sí" con la partida ya terminada no manda nada', () async {
    await entrar(
      vistaDePrueba(
        estado: 'terminada',
        resultado: {
          'motivo': 'tablero_lleno',
          'ganadores': ['ana'],
          'ranking': [],
        },
      ),
    );

    await mandar(const Rendirse(desde: EstadoDeSala.jugando));

    expect(rendiciones(), 0);
    expect(bloc.state.fin, FinDeSala.ninguno);
  });

  test(
    'Rendirse en la partida sale, aunque la partida de los demás siga',
    () async {
      await entrar(partidaEnJuego());
      salas.alRendirse = vistaDePrueba(
        version: 8,
        estado: 'jugando',
        ronda: 1,
        dados: const [1, 3],
        miEstado: 'se_rindio',
      );

      await mandar(const Rendirse(desde: EstadoDeSala.jugando));

      expect(rendiciones(), 1);
      expect(bloc.state.fin, FinDeSala.teFuiste);
    },
  );

  test('Si el servidor rechaza la rendición con un error, igual sale: dejar de preguntar es '
      'irse', () async {
    await entrar(partidaEnJuego());
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'error_del_servidor',
      mensaje: 'El servidor tuvo un problema. Intenta de nuevo.',
      estadoHttp: 500,
    );

    await mandar(const Rendirse(desde: EstadoDeSala.jugando));

    expect(bloc.state.fin, FinDeSala.teFuiste);
    expect(bloc.state.error, isNull);
  });

  test('Dos "Rendirse" seguidos mandan uno solo', () async {
    await entrar(partidaEnJuego());

    bloc
      ..add(const Rendirse(desde: EstadoDeSala.jugando))
      ..add(const Rendirse(desde: EstadoDeSala.jugando));
    await pumpEventQueue();

    expect(rendiciones(), 1);
  });
}
