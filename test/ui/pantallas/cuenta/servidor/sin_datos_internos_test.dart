import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

/// Lo que se le muestra al jugador mientras busca el servidor no habla de cómo funciona por
/// dentro: ni de los archivos del servidor (iniciar.bat), ni de la PC, ni de direcciones o
/// puertos. La dirección solo se ve en el campo donde se escribe.

/// Todos los textos a la vista, menos los de los campos donde se escribe.
List<String> textosALaVista(WidgetTester tester) => [
  for (final elemento in find.byType(RichText).evaluate())
    if (find
        .ancestor(
          of: find.byWidget(elemento.widget),
          matching: find.byType(TextField),
        )
        .evaluate()
        .isEmpty)
      (elemento.widget as RichText).text.toPlainText(),
];

final _ip = RegExp(r'\d{1,3}(\.\d{1,3}){3}');

/// Que ningún texto a la vista hable de lo de adentro.
void expectSinDatosInternos(WidgetTester tester, String donde) {
  for (final texto in textosALaVista(tester)) {
    final minusculas = texto.toLowerCase();
    expect(minusculas, isNot(contains('iniciar')), reason: '$donde: "$texto"');
    expect(minusculas, isNot(contains('.bat')), reason: '$donde: "$texto"');
    expect(texto, isNot(contains(' PC')), reason: '$donde: "$texto"');
    expect(texto, isNot(contains('servidor.test')), reason: '$donde: "$texto"');
    expect(texto, isNot(contains(':8443')), reason: '$donde: "$texto"');
    expect(_ip.hasMatch(texto), isFalse, reason: '$donde: "$texto"');
  }
}

void main() {
  testWidgets('Buscando en la red: mientras busca, lo que encuentra, si no encuentra nada, y '
      'el servidor elegido', (tester) async {
    final servidor = ServidorFalso()..apagado = true;
    final buscador = BuscadorFalso([], const Duration(seconds: 1));
    await abrirApp(
      tester,
      servidor: servidor,
      conSesion: false,
      buscador: buscador,
    );
    expectSinDatosInternos(tester, 'sin servidor');

    await tester.tap(botonServidor);
    await tester.pump();
    await tester.pump();
    expect(find.text('Buscando servidores…'), findsOneWidget);
    expectSinDatosInternos(tester, 'buscando');

    await tester.pumpAndSettle();
    expect(
      find.textContaining('No se encontró ninguno'),
      findsOneWidget,
    );
    expectSinDatosInternos(tester, 'sin resultados');

    servidor
      ..apagado = false
      ..direccion = '192.168.137.252';
    buscador.anunciados.add(anunciado('192.168.137.252'));
    await tocar(tester, find.widgetWithText(TextButton, 'Buscar de nuevo'));
    expect(find.text('Brilliant en ORION'), findsOneWidget);
    expectSinDatosInternos(tester, 'con uno encontrado');

    await tocar(tester, find.byKey(const ValueKey('servidor-192.168.137.252')));
    expect(indicadorDelServidor(tester), startsWith('Servidor disponible'));
    expectSinDatosInternos(tester, 'disponible');
  });

  testWidgets('Sin poder buscar (en la web), el diálogo pide la dirección sin hablar de cómo '
      'se arranca el servidor', (tester) async {
    await abrirApp(
      tester,
      servidor: ServidorFalso()..apagado = true,
      conSesion: false,
    );
    expectSinDatosInternos(tester, 'sin servidor');

    await tocar(tester, botonServidor);
    expect(find.byKey(const ValueKey('campo-servidor')), findsOneWidget);
    expectSinDatosInternos(tester, 'el diálogo');
  });

  testWidgets(
    'Si el servidor tardó en contestar al entrar, el aviso no muestra la dirección',
    (tester) async {
      final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
      await abrirApp(tester, servidor: servidor, conSesion: false);
      servidor.tardaDemasiado = true;

      await entrarCon(tester, 'ana', contrasenaDePrueba);
      expect(find.textContaining('tardó en contestar'), findsOneWidget);
      expectSinDatosInternos(tester, 'tardó en contestar');
    },
  );

  testWidgets(
    'Si no se pudo conectar al entrar, el aviso no muestra la dirección',
    (tester) async {
      final servidor = ServidorFalso();
      await abrirApp(tester, servidor: servidor, conSesion: false);
      servidor.apagado = true;

      await entrarCon(tester, 'ana', contrasenaDePrueba);
      expect(indicadorDelServidor(tester), startsWith('Sin servidor'));
      expectSinDatosInternos(tester, 'no se pudo conectar');
    },
  );
}
