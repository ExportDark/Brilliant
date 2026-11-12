import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';

import '../ayudantes_cuenta.dart';

void main() {
  test('Dos cierres de sesión que no llegaron se recuerdan los dos, y se cierran los dos al '
      'volver el servidor (antes el segundo pisaba al primero)', () async {
    final servidor = ServidorFalso();
    final almacen = AlmacenEnMemoria(servidor.sesionIniciada('beto'));
    final cuentas = servidor.cliente();
    final bloc = SesionBloc(cuentas, almacen, ServidorCubit(cuentas, almacen));
    addTearDown(bloc.close);
    bloc.add(const SesionRevisada());
    await bloc.stream.firstWhere((s) => s.usuario == 'beto');

    // Ya había una sesión de ana por cerrar, de antes. Ahora beto sale sin servidor.
    almacen.porCerrar = [servidor.sesionIniciada('ana')];
    servidor.apagado = true;
    bloc.add(const SalidaPedida());
    await bloc.stream.firstWhere((s) => s.aviso == SesionBloc.cierreSinServidor);

    expect(almacen.porCerrar.map((s) => s.usuario), ['ana', 'beto']);

    servidor.apagado = false;
    bloc.add(const SesionLatido());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(almacen.porCerrar, isEmpty);
    expect(servidor.sesiones, isEmpty);
  });
}
