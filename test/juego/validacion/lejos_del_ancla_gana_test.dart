import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: lejos del ancla gana, aunque la regla de la zona también lo rechace', () {
    // D3 es azul y la zona ya tiene un 4, así que el 3 no entraría; pero
    // además no hay ningún 5 a su lado, y eso es lo que se le dice al jugador.
    final resultado = evaluarEn(tableroPartida1(), 'D3', ancla: 5, valor: 3);

    expect(resultado, isA<SinAncla>());
    expect((resultado as SinAncla).ancla, 5);
  });
}
