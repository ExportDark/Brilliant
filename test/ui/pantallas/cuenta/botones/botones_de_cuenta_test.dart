import 'dart:async';

import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/ui/widgets/indicador_del_servidor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

/// Los botones de cuenta hacen lo suyo y nada más: Enter en el teclado respeta lo mismo
/// que el botón, lo que va en camino no se puede cortar a medias, y lo que pasó se ve.
void main() {
  int veces(ServidorFalso servidor, String ruta) =>
      servidor.intentados.where((r) => r == ruta).length;

  testWidgets(
    'Sin servidor, Enter en la contraseña no intenta entrar (el botón tampoco '
    'deja)',
    (tester) async {
      final servidor = ServidorFalso()..apagado = true;
      await abrirApp(
        tester,
        servidor: servidor,
        conSesion: false,
        buscador: BuscadorFalso(),
      );
      final antes = veces(servidor, 'POST /auth/token/login/');

      await escribir(tester, 'campo-usuario', 'ana');
      await escribir(tester, 'campo-contrasena', contrasenaDePrueba);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(veces(servidor, 'POST /auth/token/login/'), antes);
    },
  );

  testWidgets(
    'Sin servidor, Enter en "Repite la contraseña" no intenta crear la cuenta',
    (tester) async {
      final servidor = ServidorFalso()..apagado = true;
      await abrirApp(
        tester,
        servidor: servidor,
        conSesion: false,
        buscador: BuscadorFalso(),
      );
      await tocar(tester, enlaceCrearCuenta);

      await escribir(tester, 'campo-usuario-nuevo', 'beto');
      await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
      await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(veces(servidor, 'POST /auth/users/'), 0);
    },
  );

  testWidgets('Con la cuenta borrándose, el diálogo no se cierra (ni tocando afuera ni con '
      'atrás), y si la contraseña estaba mal, se ve', (tester) async {
    final servidor = ServidorFalso();
    await abrirApp(tester, servidor: servidor);
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));
    await escribir(tester, 'campo-contrasena-borrar', 'no-es-la-contrasena');
    final soltar = Completer<void>();
    servidor.esperaAntesDeContestar = soltar.future;

    final borrar = find.widgetWithText(FilledButton, 'Borrar cuenta');
    await tester.tap(borrar);
    await tester.pump();
    final dialogo = tester.getRect(find.byType(AlertDialog));
    await tester.tapAt(
      Offset(dialogo.center.dx, dialogo.bottom + 40),
    ); // afuera
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute(); // atrás
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('¿Borrar tu cuenta?'), findsOneWidget);

    soltar.complete();
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar tu cuenta?'), findsOneWidget);
    expect(servidor.cuentas, contains('ana'));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('campo-contrasena-borrar')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data ?? '').isNotEmpty &&
              w.data != 'Tu contraseña',
        ),
      ),
      findsWidgets,
      reason: 'el error de la contraseña se ve bajo el campo',
    );
  });

  testWidgets(
    'Mientras se crea la cuenta, atrás no deja la pantalla a medias',
    (tester) async {
      final servidor = ServidorFalso();
      await abrirApp(tester, servidor: servidor, conSesion: false);
      await tocar(tester, enlaceCrearCuenta);
      await escribir(tester, 'campo-usuario-nuevo', 'beto');
      await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
      await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
      final soltar = Completer<void>();
      servidor.esperaAntesDeContestar = soltar.future;

      // Un toque y unos cuadros, sin dejar que se agote el tiempo del pedido.
      await tester.tap(botonCrearCuenta);
      await tester.pump();
      await tester.pageBack();
      // Lo que dura la transición de salir, y de sobra (el pedido se agota a los 10 s).
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      final crearCuenta = ModalRoute.of(
        tester.element(
          find.text(
            'Elige tu nombre de usuario y una contraseña.',
            skipOffstage: false,
          ),
        ),
      )!;
      expect(crearCuenta.isCurrent, isTrue, reason: 'sigue en "Crear cuenta"');

      servidor.esperaAntesDeContestar = null;
      soltar.complete();
      await tester.pumpAndSettle();
      expect(find.text('Elige un mapa'), findsOneWidget);
    },
  );

  testWidgets(
    'Si la cuenta se creó pero no se pudo entrar, vuelve a "Iniciar sesión" con '
    'el aviso y el usuario escrito (antes ese aviso no se veía nunca)',
    (tester) async {
      final servidor = ServidorFalso();
      await abrirApp(tester, servidor: servidor, conSesion: false);
      await tocar(tester, enlaceCrearCuenta);
      await escribir(tester, 'campo-usuario-nuevo', 'beto');
      await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
      await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
      servidor.rutasQueNoLlegan.add('POST /auth/token/login/');

      await tocar(tester, botonCrearCuenta);

      expect(servidor.cuentas, contains('beto'));
      expect(find.byKey(const ValueKey('aviso-de-sesion')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('campo-contrasena')),
        findsOneWidget,
        reason: 'en Entrar',
      );
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const ValueKey('campo-usuario')),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        'beto',
      );
    },
  );

  testWidgets(
    'Deshabilitado, el indicador del servidor no dice "Toca…" ni lleva flecha',
    (tester) async {
      final servidor = ServidorFalso()..apagado = true;
      final cubit = ServidorCubit(servidor.cliente(), AlmacenEnMemoria());
      addTearDown(cubit.close);
      await cubit.revisar();

      Future<void> mostrar({VoidCallback? alTocar}) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: IndicadorDelServidor(alTocar: alTocar),
            ),
          ),
        ),
      );

      await mostrar(alTocar: () {});
      expect(indicadorDelServidor(tester), contains('Toca'));

      await mostrar();
      expect(indicadorDelServidor(tester), 'Sin servidor · No contesta.');
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    },
  );
}
