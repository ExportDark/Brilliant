import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/reloj.dart';

/// Un cronómetro que el test adelanta a mano.
class CronometroFalso implements Stopwatch {
  Duration medido = Duration.zero;

  @override
  Duration get elapsed => medido;

  @override
  void start() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('relojMonotono avanza solo con el cronómetro, no con la hora del sistema', () {
    final cronometro = CronometroFalso();
    final inicio = DateTime(2026, 11, 11, 12);
    final ahora = relojMonotono(cronometro: cronometro, inicio: inicio);

    expect(ahora(), inicio);

    cronometro.medido = const Duration(seconds: 7, milliseconds: 500);
    expect(ahora(), inicio.add(const Duration(seconds: 7, milliseconds: 500)));
  });

  test('relojMonotono de verdad nunca va hacia atrás', () async {
    final ahora = relojMonotono();
    final antes = ahora();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(ahora().isBefore(antes), isFalse);
    expect(ahora().difference(antes), greaterThanOrEqualTo(const Duration(milliseconds: 15)));
  });
}
