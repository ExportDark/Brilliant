import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('BrilliantApp: en segundo plano no avisa, y al volver avisa enseguida', (
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

    // El celular se guarda en el bolsillo: la sesión deja de contar como
    // activa y se puede entrar en otro.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    servidor.pedidos.clear();
    await tester.pump(const Duration(minutes: 6));
    expect(servidor.pedidos.where((pedido) => pedido.headers.containsKey('Authorization')), isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(
      servidor.pedidos.where(
        (pedido) => pedido.headers['Authorization'] == 'Token ${almacen.sesion!.token}',
      ),
      hasLength(1),
    );
  });
}
