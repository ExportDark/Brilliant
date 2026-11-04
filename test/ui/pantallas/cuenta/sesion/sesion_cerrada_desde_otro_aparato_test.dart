import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('BrilliantApp: si la sesión se cerró desde otro aparato, vuelve a "Iniciar sesión"', (
    tester,
  ) async {
    final servidor = ServidorFalso();
    final almacen = AlmacenEnMemoria(servidor.sesionIniciada('ana'));
    await abrirApp(
      tester,
      servidor: servidor,
      almacen: almacen,
      latidoCada: const Duration(minutes: 2),
    );
    expect(find.text('Elige un mapa'), findsOneWidget);

    // Mientras este no la usaba, se entró con la cuenta en otro celular.
    servidor.sesiones.clear();
    await tester.pump(const Duration(minutes: 2));
    await tester.pumpAndSettle();

    expect(botonEntrar, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('aviso-de-sesion')),
        matching: find.text(SesionBloc.sesionCerrada),
      ),
      findsOneWidget,
    );
    expect(almacen.sesion, isNull);
  });
}
