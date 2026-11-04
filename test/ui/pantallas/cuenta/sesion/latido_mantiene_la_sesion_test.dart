import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('BrilliantApp: con la app abierta, cada 2 minutos avisa que la sesión sigue en uso', (
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
    servidor.pedidos.clear();

    await tester.pump(const Duration(minutes: 1));
    expect(servidor.pedidos, isEmpty);

    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    final aviso = servidor.pedidos.single;
    expect(aviso.url.path, '/auth/users/me/');
    expect(aviso.headers['Authorization'], 'Token ${almacen.sesion!.token}');
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
