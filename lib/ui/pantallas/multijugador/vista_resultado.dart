import 'package:flutter/material.dart';

import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import '../../widgets/piezas.dart';
import 'marcador.dart';
import 'panel_de_zonas.dart';
import 'textos_multijugador.dart';

/// El final de la partida: quién ganó y por qué terminó, el ranking con los puntos de
/// cada uno y cómo se repartieron las zonas. No muestra los tableros: nadie los ve.
class VistaResultado extends StatelessWidget {
  final VistaDeSala sala;

  const VistaResultado({super.key, required this.sala});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final resultado = sala.resultado!;
    final gane = resultado.ganadores.contains(sala.yo.usuario);
    final jugadores = {for (final j in sala.jugadores) j.usuario: j};
    final colorPorZona = {for (final z in sala.zonas) z.id: colorDeZona(z.color)};
    // Los empatados en puntos y primeros comparten puesto.
    final puestos = puestosConEmpates(
      resultado.ranking,
      (f) => (f.estado == 'activo', f.puntos, f.primeros),
    );

    final titulo = gane
        ? (resultado.ganadores.length > 1
              ? '¡Empataste y ganaste!'
              : '¡Ganaste!')
        : resultado.ganadores.isEmpty
        ? 'Nadie ganó'
        : 'Ganó ${resultado.ganadores.join(' y ')}';

    final nadie = resultado.ganadores.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('resultado'),
      children: [
        // El cartel del final: amarillo si ganaste; si no, de cartón, con el trofeo del
        // que ganó (o una bandera, si nadie ganó).
        Container(
          key: const ValueKey('cartel-del-resultado'),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: decoracionDePieza(
            color: gane ? Paleta.ficha : Paleta.cartonClaro,
            radio: 20,
          ),
          child: Column(
            children: [
              Insignia(
                icono: nadie ? Icons.flag_rounded : Icons.emoji_events_rounded,
                color: gane
                    ? Paleta.cartonClaro
                    : nadie
                    ? Paleta.baseTablero
                    : Paleta.ficha,
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                key: const ValueKey('titulo-del-resultado'),
                textAlign: TextAlign.center,
                style: textos.headlineSmall?.copyWith(color: Paleta.tinta),
              ),
              const SizedBox(height: 4),
              Text(
                motivoDelFin(resultado.motivo, meta: sala.meta),
                key: const ValueKey('motivo-del-fin'),
                textAlign: TextAlign.center,
                style: textos.bodyLarge?.copyWith(
                  color: gane ? Paleta.tinta : Paleta.tintaSuave,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TarjetaDeSeccion(
          titulo: 'Puntos',
          child: Column(
            children: [
              for (final (i, fila) in resultado.ranking.indexed)
                FilaDePuntos(
                  key: ValueKey('fila-${fila.usuario}'),
                  puesto: puestos[i],
                  nombre: fila.usuario,
                  puntos: fila.puntos,
                  meta: sala.meta,
                  lider: resultado.ganadores.contains(fila.usuario),
                  mia: fila.usuario == sala.yo.usuario,
                  fuera: fila.estado != 'activo',
                  detalle: etiquetasDeJugador(
                    mia: fila.usuario == sala.yo.usuario,
                    estado: fila.estado,
                    primeros: fila.primeros,
                  ),
                  zonas: [
                    for (final id in jugadores[fila.usuario]?.zonas ?? const <int>[])
                      ?colorPorZona[id],
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PanelDeZonas(zonas: sala.zonas),
      ],
    );
  }
}
