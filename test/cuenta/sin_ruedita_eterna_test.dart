import 'dart:convert';

import 'package:brilliant/cuenta/almacen_de_sesion.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';
import 'package:brilliant/cuenta/sesion_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudantes_cuenta.dart';

/// Un almacén que no puede leer ni guardar (el del aparato se rompió, o no tiene permiso).
class AlmacenQueFalla extends AlmacenEnMemoria {
  AlmacenQueFalla([super.sesion]);

  @override
  Future<Sesion?> leer() async => throw StateError('no se pudo leer');

  @override
  Future<void> guardar(Sesion sesion) async =>
      throw StateError('no se pudo guardar');
}

/// Lo inesperado (el almacén que falla, una respuesta con otra forma) no deja la app
/// esperando para siempre: antes, la ruedita de "Entrar" o la del arranque no terminaba.
void main() {
  test(
    'Al abrir, si no se puede leer la sesión guardada, pide iniciar sesión',
    () async {
      final servidor = ServidorFalso();
      final almacen = AlmacenQueFalla();
      final cuentas = servidor.cliente();
      final bloc = SesionBloc(
        cuentas,
        almacen,
        ServidorCubit(cuentas, almacen),
      );
      addTearDown(bloc.close);

      bloc.add(const SesionRevisada());
      await pumpEventQueue();

      expect(bloc.state.etapa, EtapaDeSesion.sinSesion);
      expect(bloc.state.ocupado, isFalse);
    },
  );

  test('Al entrar, si no se puede guardar la sesión, avisa y "Entrar" vuelve a estar', () async {
    final servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    final almacen = AlmacenQueFalla();
    final cuentas = servidor.cliente();
    final bloc = SesionBloc(cuentas, almacen, ServidorCubit(cuentas, almacen));
    addTearDown(bloc.close);

    bloc.add(
      const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
    );
    await pumpEventQueue();

    expect(bloc.state.ocupado, isFalse);
    expect(bloc.state.error, isNotNull);
  });

  test('Al abrir, si "quién soy" contesta con otra forma, sigue con la sesión guardada', () async {
    final mock = MockClient(
      (_) async =>
          http.Response.bytes(utf8.encode(jsonEncode({'username': 5})), 200),
    );
    final cuentas = ClienteCuentas(
      mock,
      Uri.parse('https://servidor.test:8443/'),
    );
    final almacen = AlmacenEnMemoria(const Sesion(usuario: 'ana', token: 't'));
    final bloc = SesionBloc(cuentas, almacen, ServidorCubit(cuentas, almacen));
    addTearDown(bloc.close);

    bloc.add(const SesionRevisada());
    await pumpEventQueue();

    expect(bloc.state.etapa, EtapaDeSesion.conSesion);
    expect(bloc.state.ocupado, isFalse);
  });
}
