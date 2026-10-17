// Ayudantes compartidos por los tests de pantallas. No termina en
// `_test.dart`, así que `flutter test` no lo corre: solo lo importan los tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

import '../../juego/ayudantes.dart';

/// Los tamaños de pantalla en los que se prueba que todo quepa, en píxeles
/// lógicos (los que usa Flutter, no los físicos del aparato).
const tamanosDePantalla = {
  'celular chico': Size(320, 568),
  'celular': Size(360, 640),
  'celular grande': Size(412, 915),
  'tablet': Size(768, 1024),
  'escritorio': Size(1280, 800),
};

/// Por defecto, una superficie grande: las pantallas son más altas que la
/// superficie de prueba de Flutter.
void _superficie(WidgetTester tester, Size tamano) {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> abrirPreparacion(WidgetTester tester, {Size tamano = const Size(1000, 1400)}) async {
  _superficie(tester, tamano);
  await tester.pumpWidget(const MaterialApp(home: PantallaPreparacion()));
}

/// Abre la partida sobre [tablero] (por defecto, el de la Partida 1) con
/// dados que sacan [caras] (por defecto 4 y 3).
Future<void> abrirPartida(
  WidgetTester tester, {
  Tablero? tablero,
  List<int> caras = const [4, 3],
  Size tamano = const Size(1000, 1400),
}) async {
  _superficie(tester, tamano);
  await tester.pumpWidget(
    MaterialApp(
      home: PantallaPartida(
        tablero: tablero ?? tableroPartida1(),
        tirarDado: dadoConCaras(caras),
      ),
    ),
  );
}

Future<void> tocar(WidgetTester tester, Finder objetivo) async {
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

final botonTirar = find.widgetWithText(FilledButton, 'Tirar dados');

final botonPasar = find.widgetWithText(FilledButton, 'Pasar turno');

final explicacion = find.byKey(const ValueKey('explicacion'));

Finder dadoEn(int indice) => find.byKey(ValueKey('dado-$indice'));

/// La casilla [notacion], solo si responde al toque.
Finder casillaTocable(String notacion) => find.byKey(ValueKey('casilla-$notacion'));

/// El dibujo de la casilla [notacion], responda o no al toque.
Finder dibujoDe(String notacion) => find.byWidgetPredicate(
      (widget) => widget is CeldaWidget && widget.celda.posicion == pos(notacion),
    );

CeldaWidget celdaEn(WidgetTester tester, String notacion) =>
    tester.widget<CeldaWidget>(dibujoDe(notacion));

/// Las casillas dibujadas que cumplen [condicion], en notación del manual.
Set<String> celdasDibujadasDonde(WidgetTester tester, bool Function(CeldaWidget) condicion) => {
      for (final celda in tester.widgetList<CeldaWidget>(find.byType(CeldaWidget)))
        if (condicion(celda)) celda.celda.posicion.notacion,
    };

/// Verdadero si el widget de [objetivo] cabe completo a lo ancho de la pantalla.
bool cabeALoAncho(WidgetTester tester, Finder objetivo) {
  final rect = tester.getRect(objetivo);
  final ancho = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  return rect.left >= 0 && rect.right <= ancho;
}

bool habilitado(WidgetTester tester, Finder boton) =>
    tester.widget<ButtonStyleButton>(boton).onPressed != null;

/// Tira los dados y elige como dado ancla el de [indice].
Future<void> tirarYElegirAncla(WidgetTester tester, int indice) async {
  await tocar(tester, botonTirar);
  await tocar(tester, dadoEn(indice));
}
