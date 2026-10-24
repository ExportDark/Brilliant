import 'package:flutter/material.dart';

import '../../modelo/mapa.dart';
import '../../modelo/tablero.dart';
import '../tema.dart';
import '../widgets/tablero_widget.dart';
import 'pantalla_preparacion.dart';

/// La pantalla con la que arranca la app: los 4 mapas oficiales en tarjetas,
/// cada una con su tablero en miniatura. Al tocar una se pasa a la
/// preparación de ese mapa; desde ahí, la flecha de atrás vuelve aquí.
class PantallaEleccionDeMapa extends StatelessWidget {
  /// Decide qué sale en los dados de las partidas que arrancan desde aquí. Sin
  /// él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const PantallaEleccionDeMapa({super.key, this.tirarDado});

  /// El espacio entre tarjeta y tarjeta.
  static const _separacion = 12.0;

  void _elegir(BuildContext context, Mapa mapa) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaPreparacion(mapa: mapa, tirarDado: tirarDado)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant')),
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
                  // Siempre dos columnas: en un celular angosto las miniaturas
                  // se achican, igual que el tablero de la partida.
                  LayoutBuilder(
                    builder: (context, restricciones) {
                      final ancho = (restricciones.maxWidth - _separacion) / 2;
                      return Wrap(
                        spacing: _separacion,
                        runSpacing: _separacion,
                        children: [
                          for (final mapa in mapas)
                            SizedBox(
                              width: ancho,
                              child: _TarjetaDeMapa(
                                mapa: mapa,
                                alElegir: () => _elegir(context, mapa),
                              ),
                            ),
                        ],
                      );
                    },
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

/// Un mapa para elegir: su tablero vacío en miniatura, con las casillas
/// iniciales marcadas, su nombre y cuántas zonas tiene.
class _TarjetaDeMapa extends StatelessWidget {
  final Mapa mapa;
  final VoidCallback alElegir;

  const _TarjetaDeMapa({required this.mapa, required this.alElegir});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

    return Material(
      color: Colors.white,
      shape: forma,
      elevation: 1.5,
      shadowColor: Colors.black26,
      child: InkWell(
        key: ValueKey('mapa-${mapa.nivel}'),
        customBorder: forma,
        onTap: alElegir,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            children: [
              // Sin alTocar: el toque lo recibe la tarjeta entera.
              TableroWidget(tablero: Tablero.desdeMapa(mapa)),
              const SizedBox(height: 10),
              Text(
                mapa.nombre,
                style: textos.titleMedium?.copyWith(
                  color: Paleta.tinta,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${mapa.zonas.length} zonas',
                style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
