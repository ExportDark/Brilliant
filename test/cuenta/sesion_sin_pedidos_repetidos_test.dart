import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';
import 'package:brilliant/cuenta/sesion_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_cuenta.dart';

/// Lo que cambia algo en el servidor (entrar, crear o borrar la cuenta) no se manda dos
/// veces: ni por un doble toque, ni repitiéndolo después de un tiempo agotado (el pedido
/// pudo haber llegado aunque la respuesta no). Antes, repetirlo daba mensajes falsos:
/// "ya existe ese usuario" con la cuenta recién creada, o "sesión en otro aparato" con
/// este mismo.
void main() {
  late ServidorFalso servidor;
  late AlmacenEnMemoria almacen;
  late SesionBloc bloc;

  SesionBloc nuevoBloc({BuscadorDeServidores buscador = const SinBuscar()}) {
    final cuentas = servidor.cliente();
    final cubit = ServidorCubit(cuentas, almacen, buscador: buscador);
    return SesionBloc(cuentas, almacen, cubit);
  }

  setUp(() {
    servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    almacen = AlmacenEnMemoria();
  });
  tearDown(() => bloc.close());

  int veces(String ruta) => servidor.intentados.where((r) => r == ruta).length;

  test('Dos "Entrar" seguidos mandan un solo pedido', () async {
    bloc = nuevoBloc()
      ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba))
      ..add(
        const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
      );
    await pumpEventQueue();

    expect(veces('POST /auth/token/login/'), 1);
    expect(bloc.state.etapa, EtapaDeSesion.conSesion);
    expect(bloc.state.error, isNull);
  });

  test('Dos "Crear cuenta" seguidos mandan un solo pedido', () async {
    bloc = nuevoBloc();
    const pedida = CuentaPedida(
      usuario: 'beto',
      contrasena: contrasenaDePrueba,
      repetida: contrasenaDePrueba,
    );
    bloc
      ..add(pedida)
      ..add(pedida);
    await pumpEventQueue();

    expect(veces('POST /auth/users/'), 1);
    expect(bloc.state.etapa, EtapaDeSesion.conSesion);
  });

  test('Crear la cuenta con el tiempo agotado no se repite en otro servidor de la red', () async {
    servidor.otrasDirecciones.add('192.168.137.252');
    final buscador = BuscadorFalso([anunciado('192.168.137.252')]);
    bloc = nuevoBloc(buscador: buscador);
    servidor.rutasQueTardan.add('POST /auth/users/');

    bloc.add(
      const CuentaPedida(
        usuario: 'beto',
        contrasena: contrasenaDePrueba,
        repetida: contrasenaDePrueba,
      ),
    );
    await pumpEventQueue();

    expect(veces('POST /auth/users/'), 1);
    expect(bloc.state.error!.generales.single, contains('tardó'));
  });

  test('Entrar con el tiempo agotado no se repite', () async {
    servidor.otrasDirecciones.add('192.168.137.252');
    final buscador = BuscadorFalso([anunciado('192.168.137.252')]);
    bloc = nuevoBloc(buscador: buscador);
    servidor.rutasQueTardan.add('POST /auth/token/login/');

    bloc.add(
      const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
    );
    await pumpEventQueue();

    expect(veces('POST /auth/token/login/'), 1);
  });

  test('Si no hubo conexión (el pedido no salió), sí se repite en el servidor que se '
      'encontró en la red', () async {
    final buscador = BuscadorFalso([anunciado('192.168.137.252')]);
    bloc = nuevoBloc(buscador: buscador);
    servidor.direccion = '192.168.137.252';

    bloc.add(
      const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
    );
    await pumpEventQueue();

    expect(bloc.state.etapa, EtapaDeSesion.conSesion);
  });
}
