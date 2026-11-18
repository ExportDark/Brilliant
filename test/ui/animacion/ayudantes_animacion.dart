// Ayudantes de las pruebas de animaciones. No termina en `_test.dart`: solo lo importan.

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
