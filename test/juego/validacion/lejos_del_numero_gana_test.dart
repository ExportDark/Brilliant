import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/validacion_jugada.dart';

import '../ayudantes.dart';

void main() {
  test('evaluarJugada: estar lejos del número buscado gana, aunque la regla de la zona también lo rechace', () {
    // Dado ancla 5. D3 es azul y la zona ya tiene un 4, así que el 3 no
    // entraría; pero además no hay ningún 5 a su lado, y eso es lo que se le
    // dice al jugador.
    final resultado = evaluarEn(tableroPartida1(), 'D3', ancla: 5, valor: 3);

    expect(resultado, isA<SinVecinoConNumero>());
    expect((resultado as SinVecinoConNumero).numero, 5);
  });
}
