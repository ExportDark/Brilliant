import 'package:flutter_test/flutter_test.dart';

import '../../multijugador/ayudantes_salas.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Las animaciones solo se mueven cuando pasa algo: después de abrir cada pantalla y dejar
/// que se asiente, no queda ningún cuadro pendiente (no hay nada animándose en reposo, que
/// gastaría batería).
void main() {
  testWidgets('Iniciar sesión', (tester) async {
    await abrirApp(tester, conSesion: false);
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('Elige un mapa', (tester) async {
    await abrirApp(tester);
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('La preparación', (tester) async {
    await abrirPreparacion(tester);
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('La partida, con los dados en la mesa', (tester) async {
    await abrirPartida(tester);
    await tocar(tester, botonTirar);
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });

  testWidgets('El lobby, la partida en línea y el resultado', (tester) async {
    final salas = SalasFalsas();
    await abrirMultijugador(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());
    await tester.pumpAndSettle();
    expectQuieto(tester);

    salas.vista = partidaEnJuego(version: 9);
    await pasarSegundos(tester, 1);
    await tester.pumpAndSettle();
    expectQuieto(tester);

    salas.vista = vistaDePrueba(
      version: 10,
      estado: 'terminada',
      resultado: {
        'motivo': 'tablero_lleno',
        'ganadores': ['ana'],
        'ranking': [],
      },
    );
    await pasarSegundos(tester, 1);
    await tester.pumpAndSettle();
    expectQuieto(tester);
  });
}
