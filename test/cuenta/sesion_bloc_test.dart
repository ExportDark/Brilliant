import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/almacen_de_sesion.dart';
import 'package:brilliant/cuenta/sesion_bloc.dart';
import 'package:brilliant/cuenta/sesion_event.dart';
import 'package:brilliant/cuenta/sesion_state.dart';

import 'ayudantes_cuenta.dart';

/// Una descripción corta de un estado, para comparar listas de estados.
String _resumen(SesionState state) => [
      state.etapa.name,
      if (state.usuario != null) state.usuario!,
      if (state.ocupado) 'ocupado',
      if (state.error != null) 'error',
      if (state.aviso != null) state.aviso!,
    ].join(' · ');

void main() {
  late ServidorFalso servidor;
  late AlmacenEnMemoria almacen;

  setUp(() {
    servidor = ServidorFalso();
    almacen = AlmacenEnMemoria();
  });

  SesionBloc nuevoBloc() => SesionBloc(servidor.cliente(), almacen);

  group('SesionBloc al abrir la app', () {
    blocTest<SesionBloc, SesionState>(
      'sin sesión guardada, pide iniciar sesión',
      build: nuevoBloc,
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) => expect(_resumen(bloc.state), 'sinSesion'),
    );

    blocTest<SesionBloc, SesionState>(
      'con una sesión guardada que todavía sirve, entra directo',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) => expect(_resumen(bloc.state), 'conSesion · ana'),
    );

    blocTest<SesionBloc, SesionState>(
      'con una sesión vencida, la olvida y avisa',
      build: () {
        almacen.sesion = const Sesion(usuario: 'ana', token: 'vencido');
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · Tu sesión venció. Vuelve a iniciar sesión.');
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'sin conexión, con una sesión guardada deja jugar igual',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        servidor.apagado = true;
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(almacen.sesion, isNotNull);
      },
    );
  });

  group('SesionBloc al iniciar sesión', () {
    blocTest<SesionBloc, SesionState>(
      'con la contraseña buena, entra y guarda la sesión',
      build: () {
        servidor.cuentas['ana'] = contrasenaDePrueba;
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      expect: () => [
        isA<SesionState>().having(_resumen, 'resumen', 'revisando · ocupado'),
        isA<SesionState>().having(_resumen, 'resumen', 'conSesion · ana'),
      ],
      verify: (_) {
        expect(almacen.sesion?.usuario, 'ana');
        expect(servidor.sesiones[almacen.sesion!.token], 'ana');
      },
    );

    blocTest<SesionBloc, SesionState>(
      'con una contraseña mala, sigue sin sesión y muestra el error del servidor',
      build: () {
        servidor.cuentas['ana'] = contrasenaDePrueba;
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const EntradaPedida(usuario: 'ana', contrasena: 'no-es-la-buena')),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · error');
        expect(bloc.state.error!.generales.single, startsWith('No puede iniciar sesión'));
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'sin conexión, avisa que no se pudo hablar con el servidor',
      build: () {
        servidor.apagado = true;
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(bloc.state.error!.generales.single, startsWith('No se pudo conectar con el servidor'));
      },
    );
  });

  group('SesionBloc al crear la cuenta', () {
    blocTest<SesionBloc, SesionState>(
      'crea la cuenta y entra sola',
      build: nuevoBloc,
      act: (bloc) => bloc.add(const CuentaPedida(
        usuario: 'ana',
        contrasena: contrasenaDePrueba,
        repetida: contrasenaDePrueba,
      )),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(servidor.cuentas, {'ana': contrasenaDePrueba});
        expect(almacen.sesion?.usuario, 'ana');
      },
    );

    blocTest<SesionBloc, SesionState>(
      'con un usuario repetido, muestra el error en el campo del usuario',
      build: () {
        servidor.cuentas['ana'] = 'otra-contrasena-1';
        return nuevoBloc();
      },
      act: (bloc) => bloc.add(const CuentaPedida(
        usuario: 'ana',
        contrasena: contrasenaDePrueba,
        repetida: contrasenaDePrueba,
      )),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · error');
        expect(bloc.state.error!.de('username'), 'Ya existe un usuario con este nombre.');
      },
    );
  });

  group('SesionBloc con la sesión iniciada', () {
    late Sesion sesion;

    setUp(() {
      sesion = servidor.sesionIniciada('ana');
      almacen.sesion = sesion;
    });

    blocTest<SesionBloc, SesionState>(
      'cerrar sesión la cierra en el servidor y en el aparato',
      build: nuevoBloc,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const SalidaPedida()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · Cerraste sesión.');
        expect(almacen.sesion, isNull);
        expect(servidor.sesiones.containsKey(sesion.token), isFalse);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'cerrar sesión sin conexión la cierra igual en el aparato',
      build: nuevoBloc,
      act: (bloc) async {
        bloc.add(const SesionRevisada());
        await Future<void>.delayed(Duration.zero);
        servidor.apagado = true;
        bloc.add(const SalidaPedida());
      },
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · Cerraste sesión.');
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'borrar con una contraseña mala no la borra y muestra el error en el campo',
      build: nuevoBloc,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const BorradoPedido(contrasena: 'no-es-la-buena')),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana · error');
        expect(bloc.state.error!.de('current_password'), 'Contraseña inválida.');
        expect(servidor.cuentas, contains('ana'));
        expect(almacen.sesion, isNotNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'borrar con la contraseña buena la borra, olvida la sesión y avisa',
      build: nuevoBloc,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const BorradoPedido(contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · Tu cuenta se borró.');
        expect(servidor.cuentas, isEmpty);
        expect(servidor.sesiones, isEmpty);
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'AvisosDescartados olvida el error del último pedido',
      build: nuevoBloc,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const BorradoPedido(contrasena: 'no-es-la-buena'))
        ..add(const AvisosDescartados()),
      verify: (bloc) => expect(_resumen(bloc.state), 'conSesion · ana'),
    );
  });
}
