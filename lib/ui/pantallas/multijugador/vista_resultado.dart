import 'package:flutter/material.dart';

import '../../../multijugador/modelos.dart';
import '../../tema.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('resultado'),
      children: [
        Text(
          titulo,
          key: const ValueKey('titulo-del-resultado'),
          textAlign: TextAlign.center,
          style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          motivoDelFin(resultado.motivo),
          key: const ValueKey('motivo-del-fin'),
          textAlign: TextAlign.center,
          style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
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
                  nombre: '${fila.usuario}${resultado.ganadores.contains(fila.usuario) ? ' ★' : ''}'
                      '${fila.estado == 'activo' ? '' : ' (${estadoDeSalida(fila.estado)})'}',
                  puntos: fila.puntos,
                  lider: resultado.ganadores.contains(fila.usuario),
                  mia: fila.usuario == sala.yo.usuario,
                  fuera: fila.estado != 'activo',
                  detalle: fila.primeros == 0
                      ? null
                      : fila.primeros == 1
                      ? '1 primer puesto'
                      : '${fila.primeros} primeros puestos',
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
