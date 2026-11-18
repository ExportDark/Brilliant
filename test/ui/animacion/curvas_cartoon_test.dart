import 'package:brilliant/ui/animacion/cartoon.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('La goma empieza en 0, se pasa de 1 (alrededor de un 30 %) y termina exacto en 1', () {
    const goma = CurvaDeGoma();
    final valores = [for (var i = 0; i <= 100; i++) goma.transform(i / 100)];

    expect(valores.first, 0);
    expect(valores.last, 1);
    final maximo = valores.reduce((a, b) => a > b ? a : b);
    expect(maximo, closeTo(1.3, 0.04)); // el pico real queda un poco arriba
    // Cerca del final ya casi no se mueve.
    expect(goma.transform(0.98), closeTo(1, 0.03));
  });

  test('Con menos exceso, se pasa menos', () {
    const suave = CurvaDeGoma(exceso: 0.1, rebotes: 1);
    final maximo = [for (var i = 0; i <= 100; i++) suave.transform(i / 100)].reduce(
      (a, b) => a > b ? a : b,
    );

    expect(maximo, closeTo(1.1, 0.04));
    expect(suave.transform(1), 1);
  });

  test('"En dos": a 12 cuadros por segundo, el valor se queda quieto dentro de cada cuadro', () {
    const duracion = Duration(milliseconds: 500);
    const enDos = EnDos(Curves.linear, duracion);

    expect(enDos.cuadros, 6);
    // Dentro del primer cuadro (0 a 1/6), siempre lo mismo.
    expect(enDos.transform(0.01), enDos.transform(0.15));
    // Y en el siguiente cambia de golpe.
    expect(enDos.transform(0.17), greaterThan(enDos.transform(0.15)));
    expect(enDos.transform(1), 1);
  });
}
