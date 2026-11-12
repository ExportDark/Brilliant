import 'package:flutter/material.dart';

import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'marcador.dart';
import 'textos_multijugador.dart';

/// Qué zonas siguen dando puntos y cuáles ya se llenaron, a la vista de todos. Una fila
/// por zona: su color, cuántas casillas tiene, sus tres puestos (los tomados, con quién;
/// los libres, con lo que pagan) y lo que da ahora, o "Agotada". Nadie ve los números de
/// los demás: solo esto.
class PanelDeZonas extends StatelessWidget {
  final List<ZonaEnSala> zonas;

  const PanelDeZonas({super.key, required this.zonas});

  @override
  Widget build(BuildContext context) {
    return TarjetaDeSeccion(
      titulo: 'Zonas',
      nota: 'Quien llena una zona primero se lleva más.',
      child: Column(
        children: [
          for (final (i, zona) in zonas.indexed) ...[
            if (i > 0) const Divider(height: 1, color: Paleta.baseTablero),
            _FilaDeZona(zona: zona),
          ],
        ],
      ),
    );
  }
}

class _FilaDeZona extends StatelessWidget {
  final ZonaEnSala zona;

  const _FilaDeZona({required this.zona});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final color = colorDeZona(zona.color);
    final colorFuerte = color == null ? Colors.grey : coloresDeZona[color]!;

    return Opacity(
      key: ValueKey('zona-${zona.id}'),
      // Una zona agotada ya no le importa a nadie: se ve apagada.
      opacity: zona.agotada ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: colorFuerte,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${nombreDeColor(zona.color)} · ${zona.casillas.length} casillas',
                      style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    // Al dejar el dedo encima se ve en qué ronda la llenó cada uno.
                    Tooltip(
                      message: zona.puestos.isEmpty ? 'Nadie la llenó todavía' : puestosDe(zona),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _puestos(colorFuerte),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  zona.agotada ? 'Agotada' : 'Da ${zona.puntosSiguiente}',
                  key: ValueKey('puntos-zona-${zona.id}'),
                  style: textos.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: zona.agotada ? Paleta.tintaSuave : Paleta.tinta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Los tomados, en orden, con quién; después los libres que pagan, con sus puntos (el
  /// próximo, marcado). Si varios empataron, el puesto siguiente se salta.
  List<Widget> _puestos(Color colorFuerte) {
    final tomados = [
      for (final p in zona.puestos)
        _Puesto(
          texto: '${ordinal(p.puesto)} ${p.usuario}',
          fondo: Color.lerp(colorFuerte, Colors.white, 0.55)!,
        ),
    ];
    final pagan = zona.puntosPorPuesto;
    final libres = [
      for (var puesto = zona.puestos.length + 1; puesto <= pagan.length; puesto++)
        _Puesto(
          texto: '${ordinal(puesto)} · ${pagan[puesto - 1]}',
          borde: puesto == zona.puestos.length + 1
              ? Color.lerp(colorFuerte, Colors.black, 0.25)!
              : Paleta.baseTablero,
        ),
    ];
    if (tomados.isEmpty && libres.isEmpty) {
      return [const _Puesto(texto: 'Libre', borde: Paleta.baseTablero)];
    }
    return [...tomados, ...libres];
  }
}

/// Un puesto de una zona: lleno (tomado) o con borde (libre).
class _Puesto extends StatelessWidget {
  final String texto;
  final Color? fondo;
  final Color? borde;

  const _Puesto({required this.texto, this.fondo, this.borde});

  @override
  Widget build(BuildContext context) {
    final borde = this.borde;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: borde == null ? null : Border.all(color: borde, width: 1.2),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Paleta.tinta,
              fontWeight: fondo != null ? FontWeight.w600 : FontWeight.w400,
            ),
      ),
    );
  }
}
