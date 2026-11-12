import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/multijugador/sala_bloc.dart';
import 'package:brilliant/multijugador/sala_event.dart';
import 'package:brilliant/multijugador/sala_state.dart';

import 'ayudantes_salas.dart';

void main() {
  late SalasFalsas salas;
  late DateTime ahora;
  late SalaBloc bloc;

  setUp(() {
    salas = SalasFalsas();
    ahora = DateTime(2026, 11, 10, 12);
    // Sin preguntar solo: los tests mandan Preguntar cuando quieren.
    bloc = SalaBloc(salas, intervalo: null, ahora: () => ahora);
  });

  tearDown(() => bloc.close());

  Future<void> mandar(SalaEvent evento) async {
    bloc.add(evento);
    await pumpEventQueue();
  }

  /// Entra a una sala: el servidor contesta [vista].
  Future<void> entrar([VistaDeSala? vista]) async {
    salas.vista = vista ?? vistaDePrueba();
    await mandar(const SalaCreada());
  }

  group('SalaBloc: crear y unirse', () {
    test('al empezar no hay sala', () {
      expect(bloc.state.vista, isNull);
      expect(bloc.state.enSala, isFalse);
      expect(bloc.state.ocupado, isFalse);
    });

    test('crear una sala entra a ella como anfitrión', () async {
      await entrar();

      expect(salas.llamadas, ['crear']);
      expect(bloc.state.vista!.codigo, 'K7M4QX');
      expect(bloc.state.vista!.soyElAnfitrion, isTrue);
      expect(bloc.state.enSala, isTrue);
      expect(bloc.state.ocupado, isFalse);
    });

    test('mientras llega la respuesta, el estado dice que está ocupado', () async {
      salas.vista = vistaDePrueba();
      final estados = <bool>[];
      final suscripcion = bloc.stream.listen((s) => estados.add(s.ocupado));

      await mandar(const SalaCreada());
      await suscripcion.cancel();

      expect(estados, [true, false]);
    });

    test('unirse con un código lo manda en mayúsculas y sin espacios', () async {
      salas.vista = vistaDePrueba(yo: 'beto');

      await mandar(const UnirseConCodigo('  k7m4qx '));

      expect(salas.llamadas, ['unirse K7M4QX']);
      expect(bloc.state.vista!.yo.usuario, 'beto');
    });

    for (final vacio in ['', '   ']) {
      test('unirse con el código vacío ("$vacio") avisa sin molestar al servidor', () async {
        await mandar(UnirseConCodigo(vacio));

        expect(salas.llamadas, isEmpty);
        expect(bloc.state.error, 'Escribe el código de la sala.');
      });
    }

    test('unirse a una sala que no existe avisa, y no es "la sala desapareció"', () async {
      salas.vista = vistaDePrueba();
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'sala_no_existe',
        mensaje: 'No hay ninguna sala con ese código.',
        estadoHttp: 404,
      );

      await mandar(const UnirseConCodigo('ZZZZZZ'));

      expect(bloc.state.error, 'No hay ninguna sala con ese código.');
      expect(bloc.state.fin, FinDeSala.ninguno);
      expect(bloc.state.vista, isNull);
    });

    for (final (codigo, mensaje) in [
      ('sala_llena', 'La sala ya tiene 6 jugadores.'),
      ('ya_empezo', 'La partida ya empezó o terminó.'),
      ('ya_estas_en_una_sala', 'Ya estás en otra sala.'),
    ]) {
      test('si el servidor dice $codigo, se muestra su mensaje y se sigue fuera', () async {
        salas.vista = vistaDePrueba();
        salas.errorEnElProximo = ErrorDeSala(codigo: codigo, mensaje: mensaje, estadoHttp: 409);

        await mandar(const UnirseConCodigo('K7M4QX'));

        expect(bloc.state.error, mensaje);
        expect(bloc.state.vista, isNull);
        expect(bloc.state.ocupado, isFalse);
      });
    }

    test('sin conexión al crear, avisa y se puede intentar de nuevo', () async {
      salas.vista = vistaDePrueba();
      salas.sinConexion = true;

      await mandar(const SalaCreada());

      expect(bloc.state.error, contains('No se pudo conectar'));
      expect(bloc.state.vista, isNull);
      expect(bloc.state.ocupado, isFalse);

      salas.sinConexion = false;
      await mandar(const SalaCreada());
      expect(bloc.state.vista, isNotNull);
      expect(bloc.state.error, isNull);
    });

    test('descartar el error lo quita', () async {
      await mandar(const UnirseConCodigo(''));

      await mandar(const ErrorDescartado());

      expect(bloc.state.error, isNull);
    });
  });

  group('SalaBloc: pedidos sin estar en una sala se ignoran', () {
    for (final (nombre, evento) in <(String, SalaEvent)>[
      ('elegir mapa', const MapaElegido(3)),
      ('empezar', const PartidaEmpezada()),
      ('preparar', const PreparacionEnviada({'E1': 1})),
      ('jugar', const JugadaEnviada(dadoAncla: 1, casilla: 'D1')),
      ('pasar', const RondaPasada()),
      ('rendirse', const Rendirse()),
      ('preguntar', const Preguntar()),
    ]) {
      test(nombre, () async {
        await mandar(evento);

        expect(salas.llamadas, isEmpty);
        expect(bloc.state.error, isNull);
        expect(bloc.state.vista, isNull);
      });
    }
  });

  group('SalaBloc: el lobby', () {
    test('el anfitrión elige el mapa y empieza', () async {
      await entrar();
      salas.vista = vistaDePrueba(version: 2);
      await mandar(const MapaElegido(3));
      salas.vista = vistaDePrueba(version: 3, estado: 'preparando');
      await mandar(const PartidaEmpezada());

      expect(salas.llamadas, ['crear', 'mapa 3', 'empezar']);
      expect(bloc.state.vista!.estado, EstadoDeSala.preparando);
    });

    test('empezar con un solo jugador muestra el mensaje del servidor', () async {
      await entrar();
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'pocos_jugadores',
        mensaje: 'Hacen falta al menos 2 jugadores para empezar.',
        estadoHttp: 409,
      );

      await mandar(const PartidaEmpezada());

      expect(bloc.state.error, 'Hacen falta al menos 2 jugadores para empezar.');
      expect(bloc.state.vista!.estado, EstadoDeSala.esperando);
    });

    test('salir del lobby (el servidor contesta 204) deja de estar en la sala, por su cuenta',
        () async {
      await entrar();
      salas.alRendirse = null;

      await mandar(const Rendirse());

      expect(bloc.state.fin, FinDeSala.teFuiste);
      expect(bloc.state.enSala, isFalse);
    });

    test('si el anfitrión cerró la sala, se ve como sala cerrada, no como resultado', () async {
      await entrar(vistaDePrueba(yo: 'beto', anfitrion: 'ana'));
      salas.vista = vistaDePrueba(
        yo: 'beto',
        anfitrion: 'ana',
        version: 4,
        estado: 'terminada',
        resultado: {'motivo': 'sala_cerrada', 'ganadores': [], 'ranking': []},
      );

      await mandar(const Preguntar());

      expect(bloc.state.fin, FinDeSala.cerrada);
      expect(bloc.state.enSala, isFalse);
    });

    test('crear o unirse estando ya en una sala (un doble toque) no manda nada', () async {
      await entrar();
      final antes = salas.llamadas.length;

      await mandar(const SalaCreada());
      await mandar(const UnirseConCodigo('K7M4QX'));

      expect(salas.llamadas.length, antes);
      expect(bloc.state.error, isNull);
    });
  });

  group('SalaBloc: preguntar cada segundo', () {
    test('si no cambió (el servidor contesta lo mismo), la sala queda igual', () async {
      await entrar(vistaDePrueba(version: 4));
      final antes = bloc.state.vista;

      await mandar(const Preguntar());

      expect(salas.llamadas.last, 'estado 4'); // pregunta con la versión que tiene
      expect(bloc.state.vista, same(antes));
      expect(bloc.state.conexion, Conexion.conectada);
    });

    test('si cambió, se guarda la sala nueva', () async {
      await entrar(vistaDePrueba(version: 4));
      salas.vista = vistaDePrueba(version: 5, estado: 'preparando');

      await mandar(const Preguntar());

      expect(bloc.state.vista!.version, 5);
      expect(bloc.state.vista!.estado, EstadoDeSala.preparando);
    });

    test('lo que anotó otro (más puntos, más jugadores) llega con la sala nueva', () async {
      await entrar(vistaDePrueba(version: 4));
      salas.vista = vistaDePrueba(
        version: 5,
        jugadores: [
          jugadorJson('ana', anfitrion: true),
          jugadorJson('beto', puntos: 3),
          jugadorJson('carla'),
        ],
      );

      await mandar(const Preguntar());

      expect(bloc.state.vista!.jugadores, hasLength(3));
      expect(bloc.state.vista!.jugadores[1].puntos, 3);
    });

    test('al terminar la partida deja de preguntar solo', () async {
      final preguntas = <String>[];
      final conReloj = SalaBloc(
        salas,
        intervalo: const Duration(milliseconds: 5),
        ahora: () => ahora,
      );
      addTearDown(conReloj.close);
      salas.vista = vistaDePrueba(version: 1);
      conReloj.add(const SalaCreada());
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(salas.preguntas, greaterThan(0));

      salas.vista = vistaDePrueba(
        version: 2,
        estado: 'terminada',
        resultado: {'motivo': 'tablero_lleno', 'ganadores': ['ana'], 'ranking': []},
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final alTerminar = salas.preguntas;
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(salas.preguntas, alTerminar);
      expect(conReloj.state.vista!.estado, EstadoDeSala.terminada);
      preguntas.clear();
    });

    test('si el servidor tarda, las preguntas no se acumulan', () async {
      final soltar = Completer<void>();
      final conReloj = SalaBloc(
        salas,
        intervalo: const Duration(milliseconds: 5),
        ahora: () => ahora,
      );
      addTearDown(conReloj.close);
      salas.vista = vistaDePrueba(version: 1);
      conReloj.add(const SalaCreada());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      salas.llamadas.clear();
      salas.esperaAntesDeContestar = soltar.future;

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Una pregunta en curso, y como mucho una esperando su turno.
      expect(salas.preguntas, lessThanOrEqualTo(2));
      soltar.complete();
    });

    test('al cerrar el bloc se deja de preguntar', () async {
      final conReloj = SalaBloc(
        salas,
        intervalo: const Duration(milliseconds: 5),
        ahora: () => ahora,
      );
      salas.vista = vistaDePrueba(version: 1);
      conReloj.add(const SalaCreada());
      await Future<void>.delayed(const Duration(milliseconds: 30));

      await conReloj.close();
      final alCerrar = salas.preguntas;
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(salas.preguntas, alCerrar);
    });
  });

  group('SalaBloc: desconexión', () {
    test('una respuesta que no llega: a los 3 segundos reconectando, a los 10 perdida', () async {
      await entrar();
      salas.sinConexion = true;

      ahora = ahora.add(const Duration(seconds: 2));
      await mandar(const Preguntar());
      expect(bloc.state.conexion, Conexion.conectada, reason: 'un corte breve no cuenta');

      ahora = ahora.add(const Duration(seconds: 1));
      await mandar(const Preguntar());
      expect(bloc.state.conexion, Conexion.reconectando);

      ahora = ahora.add(const Duration(seconds: 6));
      await mandar(const Preguntar());
      expect(bloc.state.conexion, Conexion.reconectando, reason: '9 segundos todavía no');

      ahora = ahora.add(const Duration(seconds: 1));
      await mandar(const Preguntar());
      expect(bloc.state.conexion, Conexion.perdida);
    });

    test('mientras no hay conexión se conserva la sala que se tenía', () async {
      await entrar(partidaEnJuego());
      salas.sinConexion = true;
      ahora = ahora.add(const Duration(seconds: 12));

      await mandar(const Preguntar());

      expect(bloc.state.conexion, Conexion.perdida);
      expect(bloc.state.vista!.ronda, 1);
      expect(bloc.state.vista!.yo.tablero, isNotEmpty);
      expect(bloc.state.fin, FinDeSala.ninguno, reason: 'aún no se sabe si el servidor nos sacó');
    });

    test('al volver la conexión se vuelve a conectada y se ve lo que pasó', () async {
      await entrar(partidaEnJuego(version: 5));
      salas.sinConexion = true;
      ahora = ahora.add(const Duration(seconds: 12));
      await mandar(const Preguntar());
      expect(bloc.state.conexion, Conexion.perdida);

      // El servidor ya nos había dado por desconectados.
      salas.sinConexion = false;
      salas.vista = vistaDePrueba(
        version: 9,
        estado: 'jugando',
        ronda: 4,
        miEstado: 'desconectado',
        dados: const [2, 2],
      );
      await mandar(const Preguntar());

      expect(bloc.state.conexion, Conexion.conectada);
      expect(bloc.state.vista!.yo.estado, 'desconectado');
      expect(bloc.state.vista!.yo.puedeJugar, isFalse);
      expect(bloc.state.vista!.ronda, 4);
    });

    test('un corte corto que se recupera nunca llega a mostrar "reconectando"', () async {
      await entrar();
      salas.sinConexion = true;
      ahora = ahora.add(const Duration(seconds: 2));
      await mandar(const Preguntar());
      salas.sinConexion = false;
      ahora = ahora.add(const Duration(seconds: 1));
      await mandar(const Preguntar());

      ahora = ahora.add(const Duration(seconds: 2));
      salas.sinConexion = true;
      await mandar(const Preguntar());

      expect(bloc.state.conexion, Conexion.conectada);
    });

    test('si el servidor se reinició la sala ya no existe: se termina sin romperse', () async {
      await entrar(partidaEnJuego());
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'sala_no_existe',
        mensaje: 'No hay ninguna sala con ese código.',
        estadoHttp: 404,
      );

      await mandar(const Preguntar());

      expect(bloc.state.fin, FinDeSala.desaparecio);
      expect(bloc.state.enSala, isFalse);
      // Ya no pregunta ni acepta pedidos.
      final llamadas = salas.llamadas.length;
      await mandar(const Preguntar());
      await mandar(const JugadaEnviada(dadoAncla: 1, casilla: 'D1'));
      expect(salas.llamadas, hasLength(llamadas));
    });

    test('si el servidor dice que ya no estamos en la sala, se termina', () async {
      await entrar(partidaEnJuego());
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'no_eres_parte',
        mensaje: 'No estás en esta sala.',
        estadoHttp: 403,
      );

      await mandar(const Preguntar());

      expect(bloc.state.fin, FinDeSala.saliste);
    });

    test('si la sesión venció mientras se jugaba, se deja la sala', () async {
      await entrar(partidaEnJuego());
      salas.sesionVencida = true;

      await mandar(const Preguntar());

      expect(bloc.state.fin, FinDeSala.saliste);
    });

    test('rendirse sin conexión también deja la sala: el servidor lo dará por desconectado', () async {
      await entrar(partidaEnJuego());
      salas.sinConexion = true;

      await mandar(const Rendirse());

      expect(bloc.state.fin, FinDeSala.teFuiste);
      expect(bloc.state.ocupado, isFalse);
    });
  });

  group('SalaBloc: la preparación', () {
    test('mandar el reparto guarda la sala que devuelve', () async {
      await entrar(vistaDePrueba(estado: 'preparando', version: 2));
      salas.vista = vistaDePrueba(estado: 'preparando', version: 3, preparado: true);

      await mandar(const PreparacionEnviada({'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2}));

      expect(salas.llamadas.last, 'preparar 6');
      expect(bloc.state.vista!.yo.preparado, isTrue);
    });

    test('un reparto que el servidor rechaza muestra su mensaje', () async {
      await entrar(vistaDePrueba(estado: 'preparando'));
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'preparacion_invalida',
        mensaje: 'El 3 no cabe en E1.',
        estadoHttp: 400,
      );

      await mandar(const PreparacionEnviada({'E1': 3}));

      expect(bloc.state.error, 'El 3 no cabe en E1.');
    });
  });

  group('SalaBloc: jugar', () {
    test('una jugada manda la ronda que se estaba viendo, el dado ancla y la casilla', () async {
      await entrar(partidaEnJuego());
      salas.vista = partidaEnJuego(version: 6, accion: 'coloco');

      await mandar(const JugadaEnviada(dadoAncla: 1, casilla: 'D1'));

      expect(salas.llamadas.last, 'jugar 1 1 D1');
      expect(bloc.state.vista!.yo.accion, 'coloco');
    });

    test('pasar manda la ronda', () async {
      await entrar(partidaEnJuego());

      await mandar(const RondaPasada());

      expect(salas.llamadas.last, 'pasar 1');
    });

    for (final (motivo, mensaje) in [
      ('ocupada', 'Esa casilla ya tiene un número.'),
      ('sin_vecino', 'Tiene que quedar pegada a una casilla con el número del dado ancla.'),
      ('regla_rota', 'La regla de esa zona no permite ese número.'),
    ]) {
      test('una jugada inválida por "$motivo" dice qué pasó, y el turno sigue', () async {
        await entrar(partidaEnJuego());
        salas.errorEnElProximo = ErrorDeSala(
          codigo: 'jugada_invalida',
          mensaje: 'Ahí no se puede anotar.',
          estadoHttp: 400,
          motivo: motivo,
        );

        await mandar(const JugadaEnviada(dadoAncla: 1, casilla: 'G7'));

        expect(bloc.state.error, mensaje);
        expect(bloc.state.vista!.yo.accion, 'pendiente');
        expect(bloc.state.ocupado, isFalse);
      });
    }

    test('un doble toque (ya_jugaste) no muestra ningún error', () async {
      await entrar(partidaEnJuego());
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'ya_jugaste',
        mensaje: 'Ya jugaste esta ronda.',
        estadoHttp: 409,
      );

      await mandar(const JugadaEnviada(dadoAncla: 1, casilla: 'D1'));

      expect(bloc.state.error, isNull);
      expect(bloc.state.ocupado, isFalse);
    });

    test('si la ronda ya cambió, avisa que mire la tirada nueva', () async {
      await entrar(partidaEnJuego());
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'ronda_incorrecta',
        mensaje: 'Esa ronda ya pasó.',
        estadoHttp: 409,
      );

      await mandar(const JugadaEnviada(dadoAncla: 1, casilla: 'D1'));

      expect(bloc.state.error, 'La ronda ya cambió. Mira la tirada nueva.');
    });

    test('dos toques seguidos se atienden de a uno, en orden', () async {
      await entrar(partidaEnJuego());
      final orden = <String>[];
      salas.alActuar = orden.add;

      bloc.add(const JugadaEnviada(dadoAncla: 1, casilla: 'D1'));
      bloc.add(const RondaPasada());
      await pumpEventQueue();

      expect(orden, ['jugar 1 1 D1', 'pasar 1']);
    });
  });

  group('SalaBloc: rendirse y el final', () {
    test('rendirse en la partida muestra el resultado', () async {
      await entrar(partidaEnJuego());
      salas.alRendirse = vistaDePrueba(
        version: 8,
        estado: 'terminada',
        yo: 'ana',
        miEstado: 'se_rindio',
        resultado: {
          'motivo': 'ultimo_jugador',
          'ganadores': ['beto'],
          'ranking': [
            {'usuario': 'beto', 'estado': 'activo', 'puntos': 0, 'primeros': 0},
            {'usuario': 'ana', 'estado': 'se_rindio', 'puntos': 0, 'primeros': 0},
          ],
        },
      );

      await mandar(const Rendirse());

      expect(bloc.state.vista!.estado, EstadoDeSala.terminada);
      expect(bloc.state.vista!.resultado!.ganadores, ['beto']);
      expect(bloc.state.fin, FinDeSala.ninguno, reason: 'se queda para ver el resultado');
    });

    test('nada se manda después de que la sala terminó', () async {
      await entrar(partidaEnJuego());
      salas.errorEnElProximo = const ErrorDeSala(
        codigo: 'no_eres_parte',
        mensaje: 'No estás en esta sala.',
        estadoHttp: 403,
      );
      await mandar(const Preguntar());
      final llamadas = salas.llamadas.length;

      await mandar(const PartidaEmpezada());
      await mandar(const Rendirse());

      expect(salas.llamadas, hasLength(llamadas));
    });
  });
}
