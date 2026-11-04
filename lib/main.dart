import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cuenta/almacen_de_sesion.dart';
import 'cuenta/buscador_de_servidores.dart';
import 'cuenta/cliente_cuentas.dart';
import 'cuenta/cliente_http.dart';
import 'cuenta/direccion_del_servidor.dart';
import 'cuenta/sesion_bloc.dart';
import 'cuenta/sesion_event.dart';
import 'cuenta/sesion_state.dart';
import 'ui/pantallas/puerta_de_sesion.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final http = await crearClienteHttp();

  runApp(BrilliantApp(
    cuentas: ClienteCuentas(http, direccionPorDefecto()),
    almacen: const AlmacenSeguro(),
    buscador: crearBuscador(),
  ));
}

/// La app: la sesión del jugador arriba de todo, y debajo, "Iniciar sesión" o
/// el juego según haya sesión o no.
class BrilliantApp extends StatefulWidget {
  /// Con quién se habla para las cuentas. Los tests pasan uno con un
  /// servidor falso.
  final ClienteCuentas cuentas;

  /// Dónde se guarda la sesión. Los tests pasan uno en memoria.
  final AlmacenDeSesion almacen;

  /// Con qué se buscan servidores en la red. Sin él no se buscan; los tests
  /// pasan uno falso.
  final BuscadorDeServidores buscador;

  /// Decide qué sale en los dados. Sin él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const BrilliantApp({
    super.key,
    required this.cuentas,
    required this.almacen,
    this.buscador = const SinBuscar(),
    this.tirarDado,
  });

  @override
  State<BrilliantApp> createState() => _BrilliantAppState();
}

class _BrilliantAppState extends State<BrilliantApp> {
  final _navegador = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SesionBloc(widget.cuentas, widget.almacen, buscador: widget.buscador)
        ..add(const SesionRevisada()),
      child: BlocListener<SesionBloc, SesionState>(
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
      ),
    );
  }
}
