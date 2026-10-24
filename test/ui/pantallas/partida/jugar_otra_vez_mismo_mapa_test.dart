import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPartida: "Jugar otra vez" vuelve a preparar el mismo mapa', (tester) async {
    // El Nivel 4 con las 49 casillas llenas: la partida ya terminó.
    final vacio = Tablero.desdeMapa(nivel4);
    final lleno = vacio.conValores({for (final celda in vacio.celdas) celda.posicion: 1});
    await abrirPartida(tester, mapa: nivel4, tablero: lleno);
    expect(find.text('¡Tablero completo!'), findsOneWidget);

    await tocar(tester, find.widgetWithText(FilledButton, 'Jugar otra vez'));

    expect(find.byType(PantallaPreparacion), findsOneWidget);
    expect(find.text('Nivel 4'), findsOneWidget);
    expect(celdaEn(tester, 'A1').celda.color, ColorZona.naranja);
    expect(
      celdasDibujadasDonde(tester, (CeldaWidget celda) => celda.celda.esInicial),
      nivel4.casillasIniciales.toSet(),
    );
  });
}
