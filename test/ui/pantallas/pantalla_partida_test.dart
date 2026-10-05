import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

Posicion _pos(String notacion) => Posicion.desdeNotacion(notacion);

/// El tablero con los valores iniciales de la Partida 1 del manual.
final _inicial = Tablero.mapaOriginal().conValores({
  _pos('C1'): 4,
  _pos('F2'): 1,
  _pos('B4'): 2,
  _pos('E4'): 5,
  _pos('C6'): 3,
  _pos('E7'): 6,
});

/// Todo el tablero lleno menos [libre]. Las casillas sin valor en [valores]
/// llevan un 1; no se revisan las reglas al llenarlo.
Tablero _llenoMenos(String libre, {Map<String, int> valores = const {}}) {
  final base = Tablero.mapaOriginal();
  return base.conValores({
    for (final celda in base.celdas)
      if (celda.posicion != _pos(libre)) celda.posicion: valores[celda.posicion.notacion] ?? 1,
  });
}

/// Un dado que va sacando [caras] en orden.
int Function() _dado(List<int> caras) {
  var siguiente = 0;
  return () => caras[siguiente++ % caras.length];
}

Future<void> _abrir(
  WidgetTester tester, {
  Tablero? tablero,
  List<int> caras = const [4, 3],
}) async {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(home: PantallaPartida(tablero: tablero ?? _inicial, tirarDado: _dado(caras))),
  );
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

final _tirar = find.widgetWithText(FilledButton, 'Tirar dados');

Finder _dadoEn(int indice) => find.byKey(ValueKey('dado-$indice'));

Finder _casilla(String notacion) => find.byKey(ValueKey('casilla-$notacion'));

bool _habilitado(WidgetTester tester, Finder boton) =>
    tester.widget<ButtonStyleButton>(boton).onPressed != null;

CeldaWidget _celdaEn(WidgetTester tester, String notacion) => tester.widget<CeldaWidget>(
      find.byWidgetPredicate(
        (widget) => widget is CeldaWidget && widget.celda.posicion == _pos(notacion),
      ),
    );

/// Tira los dados y ancla el de [indice].
Future<void> _tirarYAnclar(WidgetTester tester, int indice) async {
  await _tocar(tester, _tirar);
  await _tocar(tester, _dadoEn(indice));
}

void main() {
  group('PantallaPartida', () {
    testWidgets('arranca en el turno 1, sin dados y con "Tirar dados"', (tester) async {
      await _abrir(tester);

      expect(find.text('Turno 1'), findsOneWidget);
      expect(_habilitado(tester, _tirar), isTrue);
      expect(_dadoEn(0), findsNothing);
    });

    testWidgets('tirar muestra los dos dados y ya no deja volver a tirar', (tester) async {
      await _abrir(tester);

      await _tocar(tester, _tirar);

      expect(find.descendant(of: _dadoEn(0), matching: find.text('4')), findsOneWidget);
      expect(find.descendant(of: _dadoEn(1), matching: find.text('3')), findsOneWidget);
      expect(_habilitado(tester, _tirar), isFalse);
    });

    testWidgets('sin ancla elegida no se ilumina ni se marca nada', (tester) async {
      await _abrir(tester);

      await _tocar(tester, _tirar);

      final celdas = tester.widgetList<CeldaWidget>(find.byType(CeldaWidget));
      expect(celdas.map((celda) => celda.iluminacion).toSet(), {Iluminacion.normal});
      expect(celdas.where((celda) => celda.esAncla), isEmpty);
    });

    testWidgets('con el 4 de ancla se iluminan las vecinas de C1 donde cabe el 3', (
      tester,
    ) async {
      await _abrir(tester);

      await _tirarYAnclar(tester, 0);

      expect(_celdaEn(tester, 'C1').esAncla, isTrue);
      expect(_celdaEn(tester, 'B1').iluminacion, Iluminacion.posible);
      expect(_celdaEn(tester, 'D1').iluminacion, Iluminacion.posible);
      // C2 está junto al 4, pero la zona azul ya tiene un 4: el 3 no entra.
      expect(_celdaEn(tester, 'C2').iluminacion, Iluminacion.bloqueada);
      // Lejos del 4, o solo en diagonal, no se ilumina.
      expect(_celdaEn(tester, 'A2').iluminacion, Iluminacion.normal);
      expect(_celdaEn(tester, 'D2').iluminacion, Iluminacion.normal);
    });

    testWidgets('cambiar de ancla mueve las anclas y lo que se ilumina', (tester) async {
      await _abrir(tester);
      await _tirarYAnclar(tester, 0);

      await _tocar(tester, _dadoEn(1));

      // Ahora el ancla es el 3 (en C6) y se pone el 4.
      expect(_celdaEn(tester, 'C1').esAncla, isFalse);
      expect(_celdaEn(tester, 'C6').esAncla, isTrue);
      expect(_celdaEn(tester, 'B6').iluminacion, Iluminacion.posible);
      expect(_celdaEn(tester, 'C2').iluminacion, Iluminacion.normal);
    });

    testWidgets('tocar una casilla lejos del ancla explica dónde va', (tester) async {
      await _abrir(tester);
      await _tirarYAnclar(tester, 0);

      await _tocar(tester, _casilla('A2'));

      expect(find.textContaining('A2 no está junto a ningún 4'), findsOneWidget);
      expect(_celdaEn(tester, 'A2').celda.valor, isNull);
    });

    testWidgets('tocar una casilla que rompe la regla la explica y no anota', (tester) async {
      await _abrir(tester);
      await _tirarYAnclar(tester, 0);

      await _tocar(tester, _casilla('C2'));

      expect(find.textContaining('C2 · Zona azul — Todos iguales'), findsOneWidget);
      expect(find.textContaining('Ya tiene: 4'), findsOneWidget);
      expect(_celdaEn(tester, 'C2').celda.valor, isNull);
    });

    testWidgets('tocar una casilla iluminada anota el otro dado y pasa al siguiente turno', (
      tester,
    ) async {
      await _abrir(tester);
      await _tirarYAnclar(tester, 0);
      await _tocar(tester, _casilla('C2'));

      await _tocar(tester, _casilla('B1'));

      expect(_celdaEn(tester, 'B1').celda.valor, 3);
      expect(find.text('Turno 2'), findsOneWidget);
      expect(_dadoEn(0), findsNothing);
      expect(find.byKey(const ValueKey('explicacion')), findsNothing);
      expect(_habilitado(tester, _tirar), isTrue);
    });

    testWidgets('si ningún dado cabe, se puede pasar el turno', (tester) async {
      // E5 es la última casilla libre y su zona roja ya tiene del 1 al 5.
      final tablero = _llenoMenos('E5', valores: {'F5': 1, 'E6': 2, 'D6': 3, 'D7': 4, 'E7': 5});
      await _abrir(tester, tablero: tablero, caras: [2, 3]);

      await _tocar(tester, _tirar);
      await _tocar(tester, find.widgetWithText(FilledButton, 'Pasar turno'));

      expect(find.text('Turno 2'), findsOneWidget);
      expect(_dadoEn(0), findsNothing);
    });

    testWidgets('cuando ninguna casilla acepta nada, la partida termina', (tester) async {
      await _abrir(tester, tablero: _llenoMenos('E5'));

      expect(find.textContaining('Fin de la partida: llenaste 48 de 49'), findsOneWidget);
      expect(_habilitado(tester, _tirar), isFalse);
    });
  });
}
