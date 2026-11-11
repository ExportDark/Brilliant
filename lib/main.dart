import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cuenta/almacen_de_sesion.dart';
import 'cuenta/buscador_de_servidores.dart';
import 'cuenta/cliente_cuentas.dart';
import 'cuenta/cliente_http.dart';
import 'cuenta/direccion_del_servidor.dart';
import 'cuenta/servidor_cubit.dart';
import 'cuenta/sesion_bloc.dart';
import 'cuenta/sesion_event.dart';
import 'cuenta/sesion_state.dart';
import 'multijugador/cliente_salas.dart';
import 'ui/pantallas/puerta_de_sesion.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final http = await crearClienteHttp();

  runApp(BrilliantApp(
    cuentas: ClienteCuentas(http, direccionPorDefecto()),
    almacen: const AlmacenSeguro(),
    buscador: crearBuscador(),
    cambiosDeRed: Connectivity().onConnectivityChanged,
    revisarCada: const Duration(seconds: 10),
    latidoCada: const Duration(minutes: 2),
  ));
}

/// La app: la sesión del jugador y el servidor de cuentas arriba de todo, y
/// debajo, "Iniciar sesión" o el juego según haya sesión o no.
class BrilliantApp extends StatefulWidget {
  /// Con quién se habla para las cuentas. Los tests pasan uno con un
  /// servidor falso.
  final ClienteCuentas cuentas;

  /// Dónde se guarda la sesión. Los tests pasan uno en memoria.
  final AlmacenDeSesion almacen;

  /// Con qué se buscan servidores en la red. Sin él no se buscan; los tests
  /// pasan uno falso.
  final BuscadorDeServidores buscador;

  /// Avisa cuando cambia la red del aparato (otra WiFi, o sin red): entonces
  /// se vuelve a revisar el servidor. Sin él, solo al abrir y al volver a la
  /// app.
  final Stream<Object?>? cambiosDeRed;

  /// Cada cuánto se vuelve a revisar mientras no hay servidor. Sin él, no se
  /// vuelve a revisar solo.
  final Duration? revisarCada;

  /// Cada cuánto, con la app en primer plano, se le avisa al servidor que la
  /// sesión sigue en uso: una cuenta tiene una sola sesión activa. Sin él, no
  /// se avisa solo.
  final Duration? latidoCada;

  /// Con qué se habla para las salas del multijugador. Sin él, con el servidor de
  /// cuentas; los tests pasan una sala falsa.
  final ClienteSalas? salas;

  /// Decide qué sale en los dados. Sin él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const BrilliantApp({
    super.key,
    required this.cuentas,
    required this.almacen,
    this.buscador = const SinBuscar(),
    this.cambiosDeRed,
    this.revisarCada,
    this.latidoCada,
    this.salas,
    this.tirarDado,
  });

  @override
  State<BrilliantApp> createState() => _BrilliantAppState();
}

class _BrilliantAppState extends State<BrilliantApp> {
  final _navegador = GlobalKey<NavigatorState>();

  late final ServidorCubit _servidor;
  late final SesionBloc _sesion;
  late final ClienteSalas _salas;
  late final AppLifecycleListener _ciclo;
  StreamSubscription<Object?>? _red;
  Timer? _latidos;

  @override
  void initState() {
    super.initState();
    _servidor = ServidorCubit(
      widget.cuentas,
      widget.almacen,
      buscador: widget.buscador,
      reintentarCada: widget.revisarCada,
    )..revisar();
    _sesion = SesionBloc(widget.cuentas, widget.almacen, _servidor)..add(const SesionRevisada());
    // Las salas piden el token prestado a la sesión: no sale de ahí.
    _salas = widget.salas ?? ClienteSalasHttp(widget.cuentas, _sesion.conToken);

    // Al volver a la app (por ejemplo, después de cambiar de WiFi en los
    // ajustes) y al cambiar la red, el servidor puede estar en otra parte.
    // Al volver, además, la sesión vuelve a estar en uso.
    _ciclo = AppLifecycleListener(
      onResume: () {
        _servidor.revisar();
        _sesion.add(const SesionLatido());
      },
    );
    _red = widget.cambiosDeRed?.listen((_) => _servidor.revisar());

    // En segundo plano no se avisa: la sesión de un celular guardado en el
    // bolsillo deja de contar como activa, y se puede entrar en otro.
    final cada = widget.latidoCada;
    if (cada != null) {
      _latidos = Timer.periodic(cada, (_) {
        final estado = WidgetsBinding.instance.lifecycleState;
        if (estado == null || estado == AppLifecycleState.resumed) {
          _sesion.add(const SesionLatido());
        }
      });
    }
  }

  @override
  void dispose() {
    _latidos?.cancel();
    _red?.cancel();
    _ciclo.dispose();
    _sesion.close();
    _servidor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ClienteSalas>.value(
      value: _salas,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _servidor),
          BlocProvider.value(value: _sesion),
        ],
        child: _conLaSesion(),
      ),
    );
  }

  Widget _conLaSesion() {
    return BlocListener<SesionBloc, SesionState>(
      // Al entrar o salir, se cierra todo lo que haya encima (crear cuenta,
      // mi cuenta, el diálogo de borrar) y la raíz muestra lo que toca.
      listenWhen: (antes, ahora) => antes.etapa != ahora.etapa,
      listener: (context, state) => _navegador.currentState?.popUntil((ruta) => ruta.isFirst),
      child: MaterialApp(
        title: 'Brilliant',
        navigatorKey: _navegador,
        debugShowCheckedModeBanner: false,
        theme: temaBrilliant(),
        home: PuertaDeSesion(tirarDado: widget.tirarDado),
      ),
    );
  }
}
