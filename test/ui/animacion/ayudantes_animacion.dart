// Ayudantes de las pruebas de animaciones. No termina en `_test.dart`: solo lo importan.

import 'package:brilliant/ui/animacion/cartoon.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Como si el sistema pidiera reducir movimiento ("Quitar animaciones"), hasta el final
/// de la prueba.
void conMovimientoReducido(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// Que no quede ningún cuadro pendiente: nada se mueve solo.
void expectQuieto(WidgetTester tester) {
  expect(
    tester.binding.hasScheduledFrame,
    isFalse,
    reason: 'algo se sigue moviendo solo',
  );
}

/// La matriz de un `Transform`, o la identidad si no hay.
bool esIdentidad(Matrix4 matriz) => matriz.isIdentity();

// Para los recorridos de pantalla: qué se está moviendo ahora.

/// Si [objeto] pinta lo que dice [matcher] (por ejemplo, `paints..circle()`).
bool _pintaAlgo(RenderObject objeto, Object matcher) {
  try {
    expect(objeto, matcher);
    return true;
  } on TestFailure {
    return false;
  }
}

/// El iris que se está jugando: el de la ruta o el de la pantalla (los quietos no pintan).
final irisJugandose = find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.key == const ValueKey('iris'),
);

/// Si algún iris está pintando tinta.
bool irisPintando(WidgetTester tester) => irisJugandose.evaluate().any(
  (e) => _pintaAlgo(e.renderObject!, paints..path()),
);

/// Si algún tablero está soltando polvo (en "Elige un mapa" hay uno en cada tarjeta).
bool polvoEnElTablero(WidgetTester tester) => find
    .byKey(const ValueKey('polvo-del-tablero'))
    .evaluate()
    .any((e) => _pintaAlgo(e.renderObject!, paints..circle()));

/// La casilla [notacion] del tablero de la pantalla.
Finder _casilla(String notacion) => find.byWidgetPredicate(
  (widget) =>
      widget is CeldaWidget && widget.celda.posicion.notacion == notacion,
);

/// Si la casilla [notacion] está movida (sacudida, saltando o meneándose).
bool casillaMovida(WidgetTester tester, String notacion) => !tester
    .widget<Transform>(
      find.descendant(
        of: _casilla(notacion),
        matching: find.byKey(const ValueKey('efecto-de-celda')),
      ),
    )
    .transform
    .isIdentity();

/// La escala del número de la casilla [notacion] (1 en reposo).
double escalaDelNumero(WidgetTester tester, String notacion) => tester
    .widget<Transform>(
      find.descendant(
        of: _casilla(notacion),
        matching: find.byKey(const ValueKey('numero-que-aparece')),
      ),
    )
    .transform
    .entry(0, 0);

/// Cuánto subió el dado [indice] (positivo: en el aire).
double alturaDelDado(WidgetTester tester, int indice) => -tester
    .widget<Transform>(
      find.descendant(
        of: find.byKey(ValueKey('dado-$indice')),
        matching: find.byKey(const ValueKey('salto-del-dado')),
      ),
    )
    .transform
    .getTranslation()
    .y;

/// Las claves de todo lo que se mueve con las animaciones de cartoon.
const _clavesQueSeMueven = {
  'salto-del-dado',
  'giro-del-dado',
  'efecto-de-celda',
  'numero-que-aparece',
  'entrada-de-la-insignia',
  'sacudida',
};

/// Que nada esté moviéndose ahora: ni piezas fuera de su lugar, ni iris, ni polvo.
void expectNadaSeMueve(WidgetTester tester) {
  final movidas = [
    for (final transform in tester.widgetList<Transform>(
      find.byType(Transform),
    ))
      if (transform.key case ValueKey<String>(:final value)
          when _clavesQueSeMueven.contains(value) &&
              !transform.transform.isIdentity())
        value,
  ];
  expect(movidas, isEmpty, reason: 'se está moviendo');
  expect(irisPintando(tester), isFalse, reason: 'hay un iris');
  expect(polvoEnElTablero(tester), isFalse, reason: 'hay polvo');
  for (final pieza in tester.widgetList<AplastarYEstirar>(
    find.byType(AplastarYEstirar),
  )) {
    expect(pieza.aplastado, 0, reason: 'un botón está aplastado');
  }
}
