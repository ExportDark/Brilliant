import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/almacen_de_sesion.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/servidor_cubit.dart';
import 'package:brilliant/cuenta/servidor_state.dart';
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

  /// El servidor del último bloc creado.
  late ServidorCubit cubit;

  SesionBloc nuevoBloc({BuscadorDeServidores buscador = const SinBuscar()}) {
    final cuentas = servidor.cliente();
    cubit = ServidorCubit(cuentas, almacen, buscador: buscador);
    return SesionBloc(cuentas, almacen, cubit);
  }

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

  group('SesionBloc y el servidor', () {
    final nueva = Uri.parse('https://192.168.137.252:8443/');
    late BuscadorFalso buscador;

    setUp(() => buscador = BuscadorFalso());

    /// Un bloc creado con la dirección de siempre, y luego la PC cambió de
    /// red: ahí ya no contesta nadie.
    SesionBloc blocConLaPcEnOtraRed() {
      final bloc = nuevoBloc(buscador: buscador);
      servidor.direccion = '192.168.137.252';
      return bloc;
    }

    blocTest<SesionBloc, SesionState>(
      'al abrir, usa la dirección que eligió el jugador',
      build: () {
        final bloc = nuevoBloc();
        // La PC cambió de red, y el jugador ya había elegido la nueva.
        servidor.direccion = '192.168.137.252';
        almacen
          ..servidor = nueva
          ..sesion = servidor.sesionIniciada('ana');
        return bloc;
      },
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(bloc.servidor, nueva);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'mientras el servidor contesta, no busca, y el servidor queda disponible',
      build: () {
        servidor.cuentas['ana'] = contrasenaDePrueba;
        return nuevoBloc(buscador: buscador);
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(buscador.busquedas, 0);
        expect(cubit.state.disponibilidad, Disponibilidad.disponible);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'una contraseña mala también dice que el servidor está',
      build: () {
        servidor.cuentas['ana'] = contrasenaDePrueba;
        return nuevoBloc();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: 'otra-contrasena-1')),
      verify: (bloc) {
        expect(bloc.state.error, isNotNull);
        expect(cubit.state.disponibilidad, Disponibilidad.disponible);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'al entrar, si el servidor no contesta, lo encuentra en la red, se cambia a él y entra',
      build: () {
        servidor.cuentas['ana'] = contrasenaDePrueba;
        buscador.anunciados.add(anunciado('192.168.137.252'));
        return blocConLaPcEnOtraRed();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(bloc.servidor, nueva);
        expect(almacen.servidor, nueva, reason: 'la recuerda para la próxima vez');
        expect(
          cubit.state,
          ServidorState(
            direccion: nueva,
            disponibilidad: Disponibilidad.disponible,
            nombre: 'Brilliant en ORION',
          ),
        );
      },
    );

    blocTest<SesionBloc, SesionState>(
      'al crear la cuenta también',
      build: () {
        buscador.anunciados.add(anunciado('192.168.137.252'));
        return blocConLaPcEnOtraRed();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const CuentaPedida(
          usuario: 'ana',
          contrasena: contrasenaDePrueba,
          repetida: contrasenaDePrueba,
        )),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(servidor.cuentas, contains('ana'));
        expect(bloc.servidor, nueva);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'al abrir con la sesión guardada, si la PC cambió de IP, la encuentra y sigue la sesión',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        buscador.anunciados.add(anunciado('192.168.137.252'));
        return blocConLaPcEnOtraRed();
      },
      act: (bloc) => bloc.add(const SesionRevisada()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(bloc.servidor, nueva);
        expect(almacen.servidor, nueva);
        expect(
          servidor.pedidos.map((pedido) => pedido.headers['Authorization']),
          contains('Token ${almacen.sesion!.token}'),
          reason: 'el token se revisó en el servidor encontrado',
        );
      },
    );

    blocTest<SesionBloc, SesionState>(
      'si no encuentra ninguno, da el error de siempre y el servidor no está disponible',
      build: blocConLaPcEnOtraRed,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(
          bloc.state.error!.generales.single,
          startsWith('No se pudo conectar con el servidor (servidor.test)'),
        );
        expect(buscador.busquedas, 1);
        expect(bloc.servidor, cubit.porDefecto);
        expect(almacen.servidor, isNull);
        expect(cubit.state.disponibilidad, Disponibilidad.noDisponible);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'si contestan varios, no elige: pide elegir uno en "Servidor"',
      build: () {
        servidor.otrasDirecciones.add('192.168.137.40');
        buscador.anunciados.addAll([
          anunciado('192.168.137.252'),
          anunciado('192.168.137.40', pc: 'VEGA'),
        ]);
        return blocConLaPcEnOtraRed();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(
          bloc.state.error!.generales.single,
          'No se pudo conectar con el servidor (servidor.test), y en la red hay 2. '
          'Elige uno en "Servidor".',
        );
        expect(bloc.servidor, cubit.porDefecto);
      },
    );
  });

  group('SesionBloc y la sesión en otro aparato', () {
    blocTest<SesionBloc, SesionState>(
      'entrar con la cuenta activa en otro aparato muestra el error y no guarda nada',
      build: () {
        servidor.sesionIniciada('ana');
        return nuevoBloc();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · error');
        expect(bloc.state.error!.generales, [sesionEnOtroAparato]);
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'si la del otro aparato no se usa hace más de 5 minutos, entra y la vieja ya no sirve',
      build: () {
        servidor.sesionIniciada('ana');
        final despues = DateTime.now().add(const Duration(minutes: 6));
        servidor.ahora = () => despues;
        return nuevoBloc();
      },
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const EntradaPedida(usuario: 'ana', contrasena: contrasenaDePrueba)),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(servidor.sesiones.keys, [almacen.sesion!.token], reason: 'la vieja se cerró');
      },
    );

    blocTest<SesionBloc, SesionState>(
      'el latido, con sesión, le pregunta al servidor con el token: así sigue activa',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        return nuevoBloc();
      },
      act: (bloc) async {
        bloc.add(const SesionRevisada());
        await bloc.stream.firstWhere((state) => state.etapa == EtapaDeSesion.conSesion);
        servidor.pedidos.clear();
        bloc.add(const SesionLatido());
      },
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(servidor.pedidos.single.url.path, '/auth/users/me/');
        expect(servidor.pedidos.single.headers['Authorization'], 'Token ${almacen.sesion!.token}');
      },
    );

    blocTest<SesionBloc, SesionState>(
      'si el servidor ya cerró la sesión, el latido vuelve a "Iniciar sesión" con el aviso',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        return nuevoBloc();
      },
      act: (bloc) async {
        bloc.add(const SesionRevisada());
        await bloc.stream.firstWhere((state) => state.etapa == EtapaDeSesion.conSesion);
        // Se entró con la cuenta en otro aparato mientras este no la usaba.
        servidor.sesiones.clear();
        bloc.add(const SesionLatido());
      },
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion · ${SesionBloc.sesionCerrada}');
        expect(almacen.sesion, isNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'sin conexión, el latido no cierra nada: se sigue jugando',
      build: () {
        almacen.sesion = servidor.sesionIniciada('ana');
        return nuevoBloc();
      },
      act: (bloc) async {
        bloc.add(const SesionRevisada());
        await bloc.stream.firstWhere((state) => state.etapa == EtapaDeSesion.conSesion);
        servidor.apagado = true;
        bloc.add(const SesionLatido());
      },
      verify: (bloc) {
        expect(_resumen(bloc.state), 'conSesion · ana');
        expect(almacen.sesion, isNotNull);
      },
    );

    blocTest<SesionBloc, SesionState>(
      'sin sesión, el latido no hace nada',
      build: nuevoBloc,
      act: (bloc) => bloc
        ..add(const SesionRevisada())
        ..add(const SesionLatido()),
      verify: (bloc) {
        expect(_resumen(bloc.state), 'sinSesion');
        expect(servidor.pedidos.where((pedido) => pedido.headers.containsKey('Authorization')), isEmpty);
      },
    );
  });
}
