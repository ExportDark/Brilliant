import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final aviso = find.byKey(const ValueKey('aviso-de-conexion'));

void main() {
  testWidgets('Si el servidor no contesta: a los 3 segundos "reconectando", a los 10 "perdida"', (
    tester,
  ) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));
    expect(aviso, findsNothing);

    salas.sinConexion = true;
    ahora = ahora.add(const Duration(seconds: 2));
    await pasarSegundos(tester, 1);
    expect(aviso, findsNothing, reason: 'un corte breve no avisa');

    ahora = ahora.add(const Duration(seconds: 1));
    await pasarSegundos(tester, 1);
    expect(find.text('Reconectando con el servidor…'), findsOneWidget);

    ahora = ahora.add(const Duration(seconds: 7));
    await pasarSegundos(tester, 1);
    expect(
      find.text('Se perdió la conexión. Si no vuelve, quedas fuera de la partida.'),
      findsOneWidget,
    );
  });

  testWidgets('Sin conexión se sigue viendo el tablero que se tenía', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));

    salas.sinConexion = true;
    ahora = ahora.add(const Duration(seconds: 12));
    await pasarSegundos(tester, 1);

    expect(aviso, findsOneWidget);
    expect(celdasDibujadasDonde(tester, (c) => c.celda.valor != null), hasLength(6));
    expect(find.byKey(const ValueKey('ronda-y-tiempo')), findsOneWidget);
  });

  testWidgets('Al volver la conexión el aviso desaparece', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    var ahora = DateTime(2026, 11, 10, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));
    salas.sinConexion = true;
    ahora = ahora.add(const Duration(seconds: 5));
    await pasarSegundos(tester, 1);
    expect(aviso, findsOneWidget);

    salas.sinConexion = false;
    await pasarSegundos(tester, 1);

    expect(aviso, findsNothing);
  });

  testWidgets('Si el servidor se reinició, la sala ya no existe: lo dice y se puede volver', (
    tester,
  ) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'sala_no_existe',
      mensaje: 'No hay ninguna sala con ese código.',
      estadoHttp: 404,
    );

    await pasarSegundos(tester, 1);

    expect(find.byKey(const ValueKey('fin-de-la-sala')), findsOneWidget);
    expect(
      find.text('La sala ya no existe: el servidor se reinició o la cerró.'),
      findsOneWidget,
    );
    await tocar(tester, find.byKey(const ValueKey('boton-volver')));
    expect(find.text('Elige un mapa'), findsOneWidget);
  });

  testWidgets('Si el servidor dice que ya no estoy en la sala, se sale sin romperse', (tester) async {
    final salas = SalasFalsas()..vista = partidaEnJuego();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, partidaEnJuego());
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'no_eres_parte',
      mensaje: 'No estás en esta sala.',
      estadoHttp: 403,
    );

    await pasarSegundos(tester, 1);

    expect(find.text('Ya no estás en la sala.'), findsOneWidget);
  });
}
