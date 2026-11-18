import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/ui/animacion/iris.dart';
import 'package:brilliant/ui/widgets/piezas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../multijugador/ayudantes_salas.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Abre el multijugador y entra a una sala que está en [vista].
Future<SalasFalsas> enSala(WidgetTester tester, VistaDeSala vista) async {
  final salas = SalasFalsas();
  await abrirSalaSola(tester, salas);
  await crearSala(tester, salas, vista);
  await tester.pumpAndSettle();
  return salas;
}

/// Que el servidor falso pase a contestar [vista] (o lo mismo de antes), y que la app le
/// pregunte. No deja que se asiente: así se ve lo que se mueve.
Future<void> preguntar(
  WidgetTester tester,
  SalasFalsas salas, [
  VistaDeSala? vista,
]) async {
  if (vista != null) salas.vista = vista;
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

const miTablero = {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2};

/// La ronda 2, con los dados (2, 5).
VistaDeSala ronda2({int version = 20}) => vistaDePrueba(
  version: version,
  estado: 'jugando',
  ronda: 2,
  dados: const [2, 5],
  segundosRestantes: 60,
  tablero: const {...miTablero, 'D1': 3},
  jugadas: const [
    {
      'ancla': 2,
      'valor': 5,
      'casillas': ['D2'],
    },
    {
      'ancla': 5,
      'valor': 2,
      'casillas': ['F4'],
    },
  ],
);

VistaDeSala terminada({int version = 30, String motivo = 'tablero_lleno'}) =>
    vistaDePrueba(
      version: version,
      estado: 'terminada',
      resultado: {
        'motivo': motivo,
        'ganadores': motivo == 'sala_cerrada' ? <String>[] : ['ana'],
        'ranking': [],
      },
    );

void main() {
  group('El iris al empezar', () {
    testWidgets('después de repartir y esperar a los demás', (tester) async {
      final salas = await enSala(
        tester,
        vistaDePrueba(
          estado: 'preparando',
          preparado: true,
          segundosRestantes: 30,
        ),
      );
      expect(irisPintando(tester), isFalse);

      await preguntar(tester, salas, partidaEnJuego(version: 9));
      await tester.pump(const Duration(milliseconds: 100));
      expect(irisPintando(tester), isTrue);

      await tester.pumpAndSettle();
      expect(irisPintando(tester), isFalse);
      expect(rondaYTiempo(tester), startsWith('Ronda 1'));
      expectQuieto(tester);
    });

    testWidgets(
      'directo desde el reparto, si el tiempo se acabó antes de tocar "Inicio"',
      (tester) async {
        final salas = await enSala(
          tester,
          vistaDePrueba(estado: 'preparando', segundosRestantes: 3),
        );
        expect(
          find.byKey(const ValueKey('preparacion-en-linea')),
          findsOneWidget,
        );

        await preguntar(tester, salas, partidaEnJuego(version: 9));
        await tester.pump(const Duration(milliseconds: 100));
        expect(irisPintando(tester), isTrue);
        await tester.pumpAndSettle();
        expect(irisPintando(tester), isFalse);
      },
    );

    testWidgets(
      'y no se vuelve a jugar con cada pregunta de la misma partida',
      (tester) async {
        final salas = await enSala(tester, partidaEnJuego());
        await preguntar(tester, salas);
        await tester.pump(const Duration(milliseconds: 100));
        expect(irisPintando(tester), isFalse);
        await preguntar(tester, salas, partidaEnJuego(version: 6));
        await tester.pump(const Duration(milliseconds: 100));
        expect(irisPintando(tester), isFalse);
      },
    );
  });

  testWidgets('Los dados saltan con cada ronda nueva, no con cada pregunta', (
    tester,
  ) async {
    final salas = await enSala(tester, partidaEnJuego());

    // La misma ronda: el servidor contesta que nada cambió, o que otro anotó.
    await preguntar(tester, salas);
    await tester.pump(const Duration(milliseconds: 150));
    expect(alturaDelDado(tester, 0), 0);
    await preguntar(tester, salas, partidaEnJuego(version: 6));
    await tester.pump(const Duration(milliseconds: 150));
    expect(alturaDelDado(tester, 0), 0);
    await tester.pumpAndSettle();

    // Ronda nueva: saltan.
    await preguntar(tester, salas, ronda2());
    await tester.pump(const Duration(milliseconds: 150));
    expect(alturaDelDado(tester, 0), greaterThan(5));
    expect(alturaDelDado(tester, 1), greaterThan(5));
    await tester.pumpAndSettle();
    expectNadaSeMueve(tester);
  });

  testWidgets('Mi jugada aceptada aparece con polvo una sola vez: las preguntas que siguen '
      'no la vuelven a festejar', (tester) async {
    final salas = await enSala(tester, partidaEnJuego());
    await tocar(tester, dadoEn(0)); // el ancla es el 1: el 3 va en D1
    salas.vista = partidaEnJuego(
      version: 6,
      accion: 'coloco',
      tablero: const {...miTablero, 'D1': 3},
    );

    await tester.tap(casillaTocable('D1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(polvoEnElTablero(tester), isTrue);
    expect(escalaDelNumero(tester, 'D1'), lessThan(1));
    await tester.pumpAndSettle();
    expect(polvoEnElTablero(tester), isFalse);

    for (final vista in [
      null,
      partidaEnJuego(
        version: 7,
        accion: 'coloco',
        tablero: const {...miTablero, 'D1': 3},
      ),
    ]) {
      await preguntar(tester, salas, vista);
      await tester.pump(const Duration(milliseconds: 60));
      expect(polvoEnElTablero(tester), isFalse);
      expect(escalaDelNumero(tester, 'D1'), 1);
    }
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('Al terminar, el iris se cierra sobre el trofeo del resultado', (
    tester,
  ) async {
    final salas = await enSala(tester, partidaEnJuego());

    await preguntar(tester, salas, terminada());
    await tester.pump(const Duration(milliseconds: 550));
    final pintor =
        tester.widget<CustomPaint>(irisJugandose).painter! as TintaConHueco;
    final trofeo = tester.getCenter(find.byType(Insignia));
    final area = tester.getTopLeft(find.byType(Iris).first);
    expect((pintor.centro - (trofeo - area)).distance, lessThan(1));
    expect(pintor.radio, 52);

    await tester.pumpAndSettle();
    expect(irisPintando(tester), isFalse);
    // Las preguntas ya no siguen, y nada vuelve a moverse.
    expectNadaSeMueve(tester);
    expectQuieto(tester);
  });

  testWidgets('Si el anfitrión cierra la sala, no hay iris: no hubo partida', (
    tester,
  ) async {
    final salas = SalasFalsas()
      ..vista = vistaDePrueba(yo: 'beto', anfitrion: 'ana');
    await abrirSalaSola(tester, salas);
    await tester.enterText(campoCodigo, 'k7m4qx');
    await tocar(tester, botonUnirse);

    await preguntar(
      tester,
      salas,
      vistaDePrueba(
        yo: 'beto',
        anfitrion: 'ana',
        version: 4,
        estado: 'terminada',
        resultado: {'motivo': 'sala_cerrada', 'ganadores': [], 'ranking': []},
      ),
    );
    for (final espera in [100, 300, 300]) {
      await tester.pump(Duration(milliseconds: espera));
      expect(irisPintando(tester), isFalse);
    }
    expect(find.text('El anfitrión cerró la sala.'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
