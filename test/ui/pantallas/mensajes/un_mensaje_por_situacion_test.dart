import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/multijugador/sala_bloc.dart';
import 'package:brilliant/ui/pantallas/multijugador/textos_multijugador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cuenta/ayudantes_cuenta.dart';
import '../../../multijugador/ayudantes_salas.dart';
import '../ayudantes_pantallas.dart';
import '../cuenta/servidores/ayudantes_servidores.dart';

/// Una situación, un mensaje: lo que ya dice una parte de la pantalla no se repite en otra.
void main() {
  testWidgets('Sin servidor, en "Iniciar sesión" lo dice solo el indicador', (
    tester,
  ) async {
    await abrirApp(
      tester,
      servidor: ServidorFalso()..apagado = true,
      conSesion: false,
      buscador: BuscadorFalso(),
    );

    expect(
      indicadorDelServidor(tester),
      'Sin servidor · No contesta. Toca para buscar otro.',
    );
    expect(find.byKey(const ValueKey('falta-servidor')), findsNothing);
    expect(find.textContaining('No hay servidor'), findsNothing);
  });

  testWidgets(
    'Donde no se puede buscar (la web), el indicador dice qué hacer',
    (tester) async {
      await abrirApp(
        tester,
        servidor: ServidorFalso()..apagado = true,
        conSesion: false,
      );

      expect(
        indicadorDelServidor(tester),
        'Sin servidor · No contesta. Toca para cambiar la dirección.',
      );
    },
  );

  testWidgets('Con varios servidores, la lista dice "Elige un servidor:"', (
    tester,
  ) async {
    await abrirConVariosServidores(tester);

    expect(find.text('Elige un servidor:'), findsOneWidget);
    expect(
      find.textContaining('Hay varios servidores en tu red'),
      findsNothing,
    );
  });

  testWidgets('El código vacío se dice bajo el campo, y se va al escribir', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);

    await tocar(tester, botonUnirse);
    expect(find.text('Escribe el código'), findsOneWidget);
    expect(find.byKey(const ValueKey('error-de-sala')), findsNothing);
    expect(salas.llamadas.where((l) => l.startsWith('unirse')), isEmpty);

    await tester.enterText(campoCodigo, 'K');
    await tester.pump();
    expect(find.text('Escribe el código'), findsNothing);
  });

  testWidgets('La conexión perdida: "Se perdió la conexión."', (tester) async {
    final salas = SalasFalsas();
    DateTime ahora = DateTime(2026, 11, 19, 12);
    await abrirSalaSola(tester, salas, ahora: () => ahora);
    await crearSala(tester, salas, partidaEnJuego());
    salas.sinConexion = true;
    ahora = ahora.add(Duration(seconds: SalaBloc.segundosParaPerder + 1));
    await pasarSegundos(tester, 1);

    expect(find.text('Se perdió la conexión.'), findsOneWidget);
  });

  testWidgets('La sala que ya no existe: "La sala ya no existe."', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirSalaSola(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'sala_no_existe',
      mensaje: 'No hay ninguna sala con ese código.',
      estadoHttp: 404,
    );
    await pasarSegundos(tester, 1);

    expect(find.text('La sala ya no existe.'), findsOneWidget);
  });

  test('Un motivo de fin que la app no conoce no se muestra como código', () {
    expect(motivoDelFin('motivo_nuevo'), 'La partida terminó.');
  });
}
