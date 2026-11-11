import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

final botonInicio = find.widgetWithText(FilledButton, 'Inicio');

int repartosMandados(SalasFalsas salas) =>
    salas.llamadas.where((l) => l.startsWith('preparar')).length;

void main() {
  testWidgets('Si el servidor rechaza el reparto, se puede cambiar y volver a mandar sin '
      'empezar de cero (antes la pantalla quedaba bloqueada)', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(estado: 'preparando'));
    await tocar(tester, find.text('Aleatorio'));
    salas.errorEnElProximo = const ErrorDeSala(
      codigo: 'preparacion_invalida',
      mensaje: 'El 3 no cabe en E1.',
      estadoHttp: 400,
    );
    await tocar(tester, botonInicio);
    expect(find.text('El 3 no cabe en E1.'), findsOneWidget);
    expect(repartosMandados(salas), 1);

    // Se revuelve otra vez y se vuelve a mandar; ahora el servidor lo acepta.
    await tocar(tester, find.text('Aleatorio'));
    salas.vista = vistaDePrueba(estado: 'preparando', version: 3, preparado: true);
    await tocar(tester, botonInicio);

    expect(repartosMandados(salas), 2);
    expect(find.byKey(const ValueKey('esperando-la-preparacion')), findsOneWidget);
  });

  testWidgets('Si el reparto no llegó por falta de conexión, se vuelve a mandar tal cual', (
    tester,
  ) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba(estado: 'preparando'));
    await tocar(tester, find.text('Aleatorio'));

    salas.sinConexion = true;
    await tocar(tester, botonInicio);
    expect(find.textContaining('No se pudo conectar'), findsOneWidget);
    expect(habilitado(tester, botonInicio), isTrue);

    salas.sinConexion = false;
    salas.vista = vistaDePrueba(estado: 'preparando', version: 3, preparado: true);
    await tocar(tester, botonInicio);

    expect(find.byKey(const ValueKey('esperando-la-preparacion')), findsOneWidget);
  });
}
