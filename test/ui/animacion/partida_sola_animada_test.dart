import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/dado_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../pantallas/ayudantes_pantallas.dart';
import 'ayudantes_animacion.dart';

/// Las casillas iluminadas donde se puede anotar.
Set<String> posibles(WidgetTester tester) =>
    celdasDibujadasDonde(tester, (c) => c.iluminacion == Iluminacion.posible);

/// Deja pasar [ms] milisegundos de a un cuadro, y dice si en alguno pasó [algo].
Future<bool> enAlgunCuadro(
  WidgetTester tester,
  int ms,
  bool Function() algo,
) async {
  var paso = false;
  for (var t = 0; t < ms; t += 16) {
    await tester.pump(const Duration(milliseconds: 16));
    if (algo()) paso = true;
  }
  return paso;
}

void main() {
  testWidgets('Una partida sola, con todo lo que se mueve: la tirada salta, se puede elegir '
      'el ancla en el aire, las casillas se encienden, anotar suelta polvo una vez, y el '
      'turno siguiente vuelve a saltar', (tester) async {
    // La Partida 1 del manual, con dados 4 y 3.
    await abrirPartida(tester);
    await tester.tap(botonTirar);
    await tester.pump();

    // La tirada salta.
    await tester.pump(const Duration(milliseconds: 150));
    expect(alturaDelDado(tester, 0), greaterThan(5));
    expect(alturaDelDado(tester, 1), greaterThan(5));

    // En pleno salto, el 3 se elige de ancla: el toque llega igual.
    await tester.tap(dadoEn(1));
    await tester.pump();
    expect(tester.widget<DadoWidget>(dadoEn(1)).anclado, isTrue);
    final iluminadas = posibles(tester);
    expect(iluminadas, isNotEmpty);

    // Las que se encienden dan su saltito.
    expect(
      await enAlgunCuadro(
        tester,
        400,
        () => iluminadas.any((n) => casillaMovida(tester, n)),
      ),
      isTrue,
    );
    await tester.pumpAndSettle();
    expectNadaSeMueve(tester);

    // Anotar: el número aparece de golpe con polvo, una sola vez.
    final donde = iluminadas.first;
    await tester.tap(casillaTocable(donde));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(polvoEnElTablero(tester), isTrue);
    expect(escalaDelNumero(tester, donde), lessThan(1));
    await tester.pumpAndSettle();
    expect(polvoEnElTablero(tester), isFalse);
    expect(escalaDelNumero(tester, donde), 1);
    expect(find.text('Turno 2'), findsOneWidget);
    expectNadaSeMueve(tester);
    expectQuieto(tester);

    // El turno siguiente vuelve a saltar; el número de antes ya no se mueve.
    await tester.tap(botonTirar);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(alturaDelDado(tester, 0), greaterThan(5));
    expect(polvoEnElTablero(tester), isFalse);
    expect(escalaDelNumero(tester, donde), 1);
    await tester.pumpAndSettle();
    expectNadaSeMueve(tester);
    expectQuieto(tester);
  });

  testWidgets('Tocar una casilla donde no se puede: sacude la cabeza, no suelta polvo y no '
      'anota', (tester) async {
    await abrirPartida(tester);
    await tirarYElegirAncla(tester, 1);
    final ninguna = celdasDibujadasDonde(
      tester,
      (c) => c.celda.valor == null && c.iluminacion != Iluminacion.posible,
    ).first;

    await tester.tap(casillaTocable(ninguna));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(casillaMovida(tester, ninguna), isTrue);
    expect(polvoEnElTablero(tester), isFalse);

    await tester.pumpAndSettle();
    expect(celdaEn(tester, ninguna).celda.valor, isNull);
    expect(find.text('Turno 1'), findsOneWidget);
    expectNadaSeMueve(tester);
  });
}
