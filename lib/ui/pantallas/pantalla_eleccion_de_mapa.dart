import 'package:flutter/material.dart';

import '../../modelo/mapa.dart';
import '../tema.dart';
import '../widgets/tarjeta_de_mapa.dart';
import 'multijugador/pantalla_multijugador.dart';
import 'pantalla_mi_cuenta.dart';
import 'pantalla_preparacion.dart';

/// La pantalla con la que arranca el juego, con la sesión iniciada: los 4
/// mapas oficiales en tarjetas,
/// cada una con su tablero en miniatura. Al tocar una se pasa a la
/// preparación de ese mapa; desde ahí, la flecha de atrás vuelve aquí.
class PantallaEleccionDeMapa extends StatelessWidget {
  /// Decide qué sale en los dados de las partidas que arrancan desde aquí. Sin
  /// él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const PantallaEleccionDeMapa({super.key, this.tirarDado});

  void _elegir(BuildContext context, Mapa mapa) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaPreparacion(mapa: mapa, tirarDado: tirarDado)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brilliant'),
        actions: [
          IconButton(
            key: const ValueKey('boton-multijugador'),
            tooltip: 'Jugar con otros',
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaMultijugador()),
            ),
          ),
          IconButton(
            key: const ValueKey('boton-mi-cuenta'),
            tooltip: 'Mi cuenta',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaMiCuenta()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Elige un mapa',
                    style: textos.headlineSmall?.copyWith(
                      color: Paleta.tinta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cada uno tiene sus propias zonas.',
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
                  ),
                  const SizedBox(height: 16),
                  TarjetaDeMapa.rejilla(
                    tarjeta: (mapa) => TarjetaDeMapa(
                      mapa: mapa,
                      alElegir: () => _elegir(context, mapa),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
