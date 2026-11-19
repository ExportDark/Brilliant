import 'dart:convert';

import 'package:brilliant/cuenta/almacen_de_sesion.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudantes_cuenta.dart';

/// Cada mensaje de cuenta es corto y dice lo que pasó; si otra parte de la pantalla ya lo
/// dice (el indicador del servidor), no se repite.
void main() {
  late ServidorFalso servidor;
  late AlmacenEnMemoria almacen;
  late SesionBloc bloc;

  SesionBloc nuevoBloc({BuscadorDeServidores buscador = const SinBuscar()}) {
    final cuentas = servidor.cliente();
    return SesionBloc(
      cuentas,
      almacen,
      ServidorCubit(cuentas, almacen, buscador: buscador),
    );
  }

  setUp(() {
    servidor = ServidorFalso()..cuentas['ana'] = contrasenaDePrueba;
    almacen = AlmacenEnMemoria();
  });
  tearDown(() => bloc.close());

  Future<void> mandar(Object evento) async {
    bloc.add(evento as dynamic);
    await pumpEventQueue();
  }

  test(
    'Tiempo agotado: "El servidor tardó en contestar. Intenta de nuevo."',
    () async {
      bloc = nuevoBloc();
      servidor.tardaDemasiado = true;

      await mandar(
        const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
      );

      expect(bloc.state.error!.generales, [
        'El servidor tardó en contestar. Intenta de nuevo.',
      ]);
    },
  );

  test('Sin conexión al entrar no se repite en un recuadro: ya lo dice el indicador', () async {
    bloc = nuevoBloc();
    servidor.apagado = true;

    await mandar(
      const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
    );

    expect(bloc.state.error, isNull);
    expect(bloc.state.ocupado, isFalse);
  });

  test('Sin conexión con varios servidores en la red, tampoco: ya los muestra la lista', () async {
    servidor.otrasDirecciones.addAll(['192.168.137.40', '192.168.137.41']);
    bloc = nuevoBloc(
      buscador: BuscadorFalso([
        anunciado('192.168.137.40'),
        anunciado('192.168.137.41', pc: 'VEGA'),
      ]),
    );
    servidor.direccion = '192.168.137.40';

    await mandar(
      const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba),
    );

    expect(bloc.state.error, isNull);
  });

  test('La sesión cerrada se dice siempre igual: "Tu sesión se cerró. Vuelve a entrar."', () async {
    almacen.sesion = const Sesion(usuario: 'ana', token: 'vencido');
    bloc = nuevoBloc();

    await mandar(const SesionRevisada());

    expect(bloc.state.aviso, 'Tu sesión se cerró. Vuelve a entrar.');
  });

  test('Cerrar sesión no deja un aviso (repetiría lo que el jugador acaba de hacer)', () async {
    almacen.sesion = servidor.sesionIniciada('ana');
    bloc = nuevoBloc();
    await mandar(const SesionRevisada());

    await mandar(const SalidaPedida());

    expect(bloc.state.aviso, isNull);
  });

  test('Cerrar sesión sin servidor tampoco (antes explicaba cómo se avisa después)', () async {
    almacen.sesion = servidor.sesionIniciada('ana');
    bloc = nuevoBloc();
    await mandar(const SesionRevisada());
    servidor.apagado = true;

    await mandar(const SalidaPedida());

    expect(bloc.state.aviso, isNull);
  });

  test('"Cuenta borrada."', () async {
    almacen.sesion = servidor.sesionIniciada('ana');
    bloc = nuevoBloc();
    await mandar(const SesionRevisada());

    await mandar(const BorradoPedido(contrasena: contrasenaDePrueba));

    expect(bloc.state.aviso, 'Cuenta borrada.');
  });

  test(
    '"Cuenta creada. Ya puedes entrar." si se creó y no se pudo entrar',
    () async {
      bloc = nuevoBloc();
      servidor.rutasQueNoLlegan.add('POST /auth/token/login/');

      await mandar(
        const CuentaPedida(
          usuario: 'beto',
          contrasena: contrasenaDePrueba,
          repetida: contrasenaDePrueba,
        ),
      );

      expect(bloc.state.aviso, 'Cuenta creada. Ya puedes entrar.');
    },
  );

  group('Lo que contesta el servidor', () {
    Future<ErrorDeCuenta> errorAlEntrar(int estado, Object cuerpo) async {
      final cliente = ClienteCuentas(
        MockClient(
          (_) async =>
              http.Response.bytes(utf8.encode(jsonEncode(cuerpo)), estado),
        ),
        Uri.parse('https://servidor.test:8443/'),
      );
      try {
        await cliente.entrar(usuario: 'ana', contrasena: contrasenaDePrueba);
      } on ErrorDeCuenta catch (error) {
        return error;
      }
      fail('No dio error');
    }

    test('Demasiados intentos, con la espera en minutos si es larga', () async {
      final largo = await errorAlEntrar(429, {
        'detail': 'Solicitud fue regulada (throttled). Se espera que esté disponible en 3412 segundos.',
      });
      final corto = await errorAlEntrar(429, {
        'detail': 'Solicitud fue regulada (throttled). Se espera que esté disponible en 1 segundos.',
      });

      expect(largo.generales, ['Demasiados intentos. Espera 57 min.']);
      expect(corto.generales, ['Demasiados intentos. Espera 1 s.']);
    });

    test('Un rechazo sin mensaje, o un "sí" sin token: "El servidor tuvo un problema."', () async {
      expect((await errorAlEntrar(400, <String, Object>{})).generales, [
        'El servidor tuvo un problema. Intenta de nuevo.',
      ]);
      expect((await errorAlEntrar(200, {'otra_cosa': 1})).generales, [
        'El servidor tuvo un problema. Intenta de nuevo.',
      ]);
    });
  });
}
