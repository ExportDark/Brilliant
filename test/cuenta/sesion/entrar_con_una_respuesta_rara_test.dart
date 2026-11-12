import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';
import 'package:brilliant/cuenta/sesion_state.dart';

import '../ayudantes_cuenta.dart';

/// Un servidor que contesta [alEntrar] al iniciar sesión; a todo lo demás, 401 (está ahí).
SesionBloc blocConServidorQueContesta(http.Response alEntrar) {
  final cliente = MockClient((pedido) async {
    if (pedido.url.path == '/auth/token/login/') return alEntrar;
    return http.Response(jsonEncode({'detail': 'Sin sesión'}), 401);
  });
  final cuentas = ClienteCuentas(cliente, Uri.parse('https://servidor.test:8443/'));
  final almacen = AlmacenEnMemoria();
  return SesionBloc(cuentas, almacen, ServidorCubit(cuentas, almacen));
}

Future<SesionState> entrar(SesionBloc bloc) async {
  bloc.add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba));
  return bloc.stream.firstWhere((s) => !s.ocupado);
}

void main() {
  test('Si el servidor contesta 401 al iniciar sesión, "Entrar" no se queda esperando', () async {
    final bloc = blocConServidorQueContesta(http.Response('{}', 401));
    addTearDown(bloc.close);

    final estado = await entrar(bloc);

    expect(estado.etapa, EtapaDeSesion.sinSesion);
    expect(estado.error?.generales.single, 'El servidor no aceptó el pedido. Intenta de nuevo.');
  });

  test('Si el servidor dice que sí pero no manda el token, no se entra y se avisa', () async {
    final bloc = blocConServidorQueContesta(http.Response('{"expiry": null}', 200));
    addTearDown(bloc.close);

    final estado = await entrar(bloc);

    expect(estado.etapa, EtapaDeSesion.sinSesion);
    expect(
      estado.error?.generales.single,
      'El servidor contestó algo inesperado. Intenta de nuevo.',
    );
  });
}
