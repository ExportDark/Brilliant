import 'package:flutter/material.dart';

import '../../modelo/mapa.dart';
import '../../modelo/tipo_region.dart';
import '../tema.dart';
import 'explicacion_de_jugada.dart';

/// El botón "Reglas" de la barra de arriba: abre [HojaDeReglas] del [mapa].
class BotonDeReglas extends StatelessWidget {
  final Mapa mapa;

  /// Si es una partida en línea: la hoja también explica los puntos.
  final bool enLinea;

  const BotonDeReglas({super.key, required this.mapa, this.enLinea = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('boton-reglas'),
      tooltip: 'Reglas de las zonas',
      icon: const Icon(Icons.menu_book_rounded),
      onPressed: () => mostrarReglas(context, mapa, enLinea: enLinea),
    );
  }
}

/// Abre las reglas de [mapa] en una hoja que sube desde abajo, sin dejar la partida.
Future<void> mostrarReglas(BuildContext context, Mapa mapa, {bool enLinea = false}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Paleta.fondo,
    builder: (_) => HojaDeReglas(mapa: mapa, enLinea: enLinea),
  );
}

/// Las reglas que hacen falta para jugar [mapa]: cómo se anota con el dado ancla, y la
/// regla de cada color de zona que tiene este mapa (solo los suyos, una vez cada uno).
class HojaDeReglas extends StatelessWidget {
  final Mapa mapa;
  final bool enLinea;

  const HojaDeReglas({super.key, required this.mapa, this.enLinea = false});

  /// Los tipos de zona del mapa, sin repetir, en el orden en que aparecen.
  static List<TipoRegion> tiposDe(Mapa mapa) {
    final tipos = <TipoRegion>[];
    for (final zona in mapa.zonas) {
      if (!tipos.any((t) => identical(t, zona.tipo))) tipos.add(zona.tipo);
    }
    return tipos;
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final alto = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      key: const ValueKey('hoja-de-reglas'),
      constraints: BoxConstraints(maxHeight: alto * 0.85),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reglas del ${mapa.nombre}',
                    style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toca un dado: es el ancla. El otro número va en una casilla vacía '
                    'pegada (arriba, abajo o a un lado) a una que tenga el número del '
                    'ancla, y tiene que respetar la regla de su zona.',
                    style: textos.bodyLarge?.copyWith(color: Paleta.tinta, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  for (final tipo in tiposDe(mapa)) _ReglaDeZona(tipo: tipo),
                  if (enLinea) ...[
                    const SizedBox(height: 12),
                    Text(
                      'En línea, cada zona da puntos al que la llena primero, segundo y '
                      'tercero. Cuánto da cada una está en el panel de zonas.',
                      style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una regla: una ficha del color de la zona, como en el tablero, su nombre y qué pide.
class _ReglaDeZona extends StatelessWidget {
  final TipoRegion tipo;

  const _ReglaDeZona({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final nombre = nombreDeZona(tipo.color);

    return Padding(
      key: ValueKey('regla-${tipo.color.name}-${tipo.regla.descripcion}'),
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: coloresDeZona[tipo.color],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${nombre[0].toUpperCase()}${nombre.substring(1)}',
                  style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${tipo.regla.descripcion}.',
                  style: textos.bodyMedium?.copyWith(color: Paleta.tinta),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
