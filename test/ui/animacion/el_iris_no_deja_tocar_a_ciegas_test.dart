import 'package:brilliant/ui/widgets/dado_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../multijugador/ayudantes_salas.dart';
import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Mientras el iris tapa la pantalla, lo de abajo no se puede tocar: no se ve. Cuando se
/// abre, sí.
void main() {
  testWidgets('Al empezar en línea, un dado tocado con el iris tapando no se elige; con el '
      'iris abierto, sí', (tester) async {
    final salas = SalasFalsas();
    await abrirSalaSola(tester, salas);
    await crearSala(tester, salas, vistaDePrueba());

    salas.vista = partidaEnJuego(version: 9);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(irisPintando(tester), isTrue);

    await tester.tap(dadoEn(0), warnIfMissed: false);
    await tester.pump();
    expect(tester.widget<DadoWidget>(dadoEn(0)).anclado, isFalse);

    await tester.pumpAndSettle();
    await tocar(tester, dadoEn(0));
    expect(tester.widget<DadoWidget>(dadoEn(0)).anclado, isTrue);
  });
}
