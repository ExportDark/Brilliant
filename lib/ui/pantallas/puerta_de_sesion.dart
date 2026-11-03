import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_state.dart';
import '../widgets/logo_brilliant.dart';
import 'pantalla_eleccion_de_mapa.dart';
import 'pantalla_entrar.dart';

/// La raíz de la app: sin sesión muestra "Iniciar sesión", y con sesión,
/// "Elige un mapa". Mientras revisa la sesión guardada, el logo.
class PuertaDeSesion extends StatelessWidget {
  /// Decide qué sale en los dados de las partidas. Sin él salen al azar; los
  /// tests lo fijan.
  final int Function()? tirarDado;

  const PuertaDeSesion({super.key, this.tirarDado});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SesionBloc, SesionState>(
      buildWhen: (antes, ahora) => antes.etapa != ahora.etapa,
      builder: (context, state) => switch (state.etapa) {
        EtapaDeSesion.revisando => const _Revisando(),
        EtapaDeSesion.sinSesion => const PantallaEntrar(),
        EtapaDeSesion.conSesion => PantallaEleccionDeMapa(tirarDado: tirarDado),
      },
    );
  }
}

class _Revisando extends StatelessWidget {
  const _Revisando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoBrilliant(),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
