import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';

/// Un reparto válido: un número distinto en cada casilla inicial.
final _repartoCompleto = {
  for (final (indice, casilla) in casillasIniciales.indexed) casilla: indice + 1,
};

Future<void> _abrir(WidgetTester tester) async {
  // La pantalla es más alta que la superficie de prueba por defecto.
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: PantallaPreparacion()));
}

Future<void> _tocar(WidgetTester tester, Finder boton) async {
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

Future<void> _asignar(WidgetTester tester, String casilla, int valor) async {
  await _tocar(tester, find.byKey(ValueKey('casilla-$casilla')));
  await _tocar(tester, find.byKey(ValueKey('numero-$valor')));
}

Future<void> _repartir(WidgetTester tester, {int faltantes = 0}) async {
  final entradas = _repartoCompleto.entries.toList();
  for (final entrada in entradas.take(entradas.length - faltantes)) {
    await _asignar(tester, entrada.key, entrada.value);
  }
}

bool _habilitado(WidgetTester tester, Finder boton) =>
    tester.widget<ButtonStyleButton>(boton).onPressed != null;

final _inicio = find.widgetWithText(FilledButton, 'Inicio');

/// El texto que muestra la celda del tablero en [notacion].
String _textoEnTablero(WidgetTester tester, String notacion) {
  final celda = find.byWidgetPredicate(
    (widget) =>
        widget is CeldaWidget && widget.celda.posicion == Posicion.desdeNotacion(notacion),
  );
  final texto = find.descendant(of: celda, matching: find.byType(Text));
  return tester.widget<Text>(texto).data!;
}

void main() {
  group('PantallaPreparacion', () {
    testWidgets('arranca con "Inicio" deshabilitado', (tester) async {
      await _abrir(tester);

      expect(_inicio, findsOneWidget);
      expect(_habilitado(tester, _inicio), isFalse);
    });

    testWidgets('el número elegido aparece en el tablero y en el resumen', (tester) async {
      await _abrir(tester);

      await _asignar(tester, 'C1', 4);

      expect(_textoEnTablero(tester, 'C1'), '4');
      expect(find.text('C1 = 4'), findsOneWidget);
    });

    testWidgets('quitar un número vacía la casilla', (tester) async {
      await _abrir(tester);
      await _asignar(tester, 'C1', 4);

      await _tocar(tester, find.byKey(const ValueKey('casilla-C1')));
      await _tocar(tester, find.widgetWithText(OutlinedButton, 'Quitar'));

      expect(_textoEnTablero(tester, 'C1'), '');
      expect(find.text('C1 = —'), findsOneWidget);
    });

    testWidgets('un número ya usado no se puede elegir para otra casilla', (tester) async {
      await _abrir(tester);
      await _asignar(tester, 'C1', 4);

      await _tocar(tester, find.byKey(const ValueKey('casilla-F2')));

      expect(_habilitado(tester, find.byKey(const ValueKey('numero-4'))), isFalse);
      expect(_habilitado(tester, find.byKey(const ValueKey('numero-5'))), isTrue);
    });

    testWidgets('con una casilla vacía "Inicio" sigue deshabilitado', (tester) async {
      await _abrir(tester);

      await _repartir(tester, faltantes: 1);

      expect(_habilitado(tester, _inicio), isFalse);
    });

    testWidgets('con las 6 casillas llenas "Inicio" se habilita', (tester) async {
      await _abrir(tester);

      await _repartir(tester);

      expect(_habilitado(tester, _inicio), isTrue);
    });

    testWidgets('"Inicio" lleva a la partida con los valores fijos', (tester) async {
      await _abrir(tester);
      await _repartir(tester);

      await _tocar(tester, _inicio);

      expect(find.byType(PantallaPartida), findsOneWidget);
      expect(find.byType(PantallaPreparacion), findsNothing);
      for (final MapEntry(key: casilla, value: valor) in _repartoCompleto.entries) {
        expect(_textoEnTablero(tester, casilla), '$valor');
      }
    });

    testWidgets('reiniciar borra el reparto y deshabilita "Inicio"', (tester) async {
      await _abrir(tester);
      await _repartir(tester);

      await _tocar(tester, find.widgetWithText(OutlinedButton, 'Reiniciar'));

      expect(_habilitado(tester, _inicio), isFalse);
      for (final casilla in casillasIniciales) {
        expect(_textoEnTablero(tester, casilla), '');
      }
    });
  });
}
