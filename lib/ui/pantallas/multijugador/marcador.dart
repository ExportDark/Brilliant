import 'package:flutter/material.dart';

import '../../../modelo/color_zona.dart';
import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'textos_multijugador.dart';

/// La tarjeta blanca de las secciones del multijugador (marcador, zonas, resultado): la
/// misma forma que las tarjetas de "Elige un mapa".
class TarjetaDeSeccion extends StatelessWidget {
  final String titulo;
  final String? nota;
  final Widget child;

  const TarjetaDeSeccion({super.key, required this.titulo, this.nota, required this.child});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final nota = this.nota;

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(titulo, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (nota != null)
                  Flexible(
                    child: Text(
                      nota,
                      textAlign: TextAlign.end,
                      style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// Una fila de puntos: el puesto en un círculo, el nombre, debajo las zonas que llenó (un
/// punto de color por zona) y los puntos grandes a la derecha. La usan el marcador de la
/// partida y el resultado.
class FilaDePuntos extends StatelessWidget {
  final int puesto;
  final String nombre;
  final int puntos;

  /// El que va primero: su círculo va lleno.
  final bool lider;

  /// La fila de quien mira: va con un fondo suave.
  final bool mia;

  /// Si ya no está en la partida: se ve apagado.
  final bool fuera;

  /// Una línea chica bajo el nombre ("se rindió", "2 primeros"…).
  final String? detalle;

  /// Los colores de las zonas que llenó.
  final List<ColorZona> zonas;

  /// Lo que va antes de los puntos, como el ícono de "ya jugó".
  final Widget? estado;

  /// La clave del texto de los puntos.
  final Key? clavePuntos;

  const FilaDePuntos({
    super.key,
    required this.puesto,
    required this.nombre,
    required this.puntos,
    this.lider = false,
    this.mia = false,
    this.fuera = false,
    this.detalle,
    this.zonas = const [],
    this.estado,
    this.clavePuntos,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final tinta = fuera ? Paleta.tintaSuave : Paleta.tinta;
    final detalle = this.detalle;
    final estado = this.estado;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: mia ? Paleta.acento.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Puesto(numero: puesto, lider: lider && !fuera),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textos.bodyLarge?.copyWith(
                    color: tinta,
                    fontWeight: mia || lider ? FontWeight.w700 : FontWeight.w500,
                    decoration: fuera ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (zonas.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final color in zonas)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: coloresDeZona[color],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
                if (detalle != null && detalle.isNotEmpty)
                  Text(
                    detalle,
                    style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
                  ),
              ],
            ),
          ),
          if (estado != null) ...[estado, const SizedBox(width: 8)],
          // Los puntos cambian con un fundido suave, para que se note cuando suben.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (hijo, animacion) => FadeTransition(
              opacity: animacion,
              child: ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(animacion),
                child: hijo,
              ),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$puntos',
                    style: textos.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tinta,
                    ),
                  ),
                  TextSpan(
                    text: ' pts',
                    style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
                  ),
                ],
              ),
              key: clavePuntos ?? ValueKey('puntos-$nombre-$puntos'),
            ),
          ),
        ],
      ),
    );
  }
}

/// El número del puesto en un círculo: lleno para el que va primero.
class _Puesto extends StatelessWidget {
  final int numero;
  final bool lider;

  const _Puesto({required this.numero, required this.lider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: lider ? Paleta.acento : Paleta.baseTablero,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$numero',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: lider ? Colors.white : Paleta.tinta,
        ),
      ),
    );
  }
}

/// El color de zona de un nombre que manda el servidor ("azul", "naranja"…).
ColorZona? colorDeZona(String color) =>
    ColorZona.values.where((c) => c.name == color).firstOrNull;

/// Los puestos de una lista ya ordenada, con empates: los que tienen lo mismo comparten
/// puesto ("1, 1, 3").
List<int> puestosConEmpates<T>(List<T> ordenados, Object Function(T) valor) {
  final puestos = <int>[];
  for (final (i, elemento) in ordenados.indexed) {
    final empata = i > 0 && valor(ordenados[i - 1]) == valor(elemento);
    puestos.add(empata ? puestos[i - 1] : i + 1);
  }
  return puestos;
}

/// El marcador de la partida en línea: los jugadores ordenados por puntos (y, si empatan,
/// por primeros puestos), con los que siguen jugando arriba. Solo lo público: nombre,
/// puntos, qué zonas llenó y si ya jugó la ronda. Nunca sus números.
class Marcador extends StatelessWidget {
  final List<JugadorEnSala> jugadores;
  final String yo;
  final List<ZonaEnSala> zonas;

  const Marcador({super.key, required this.jugadores, required this.yo, required this.zonas});

  @override
  Widget build(BuildContext context) {
    final colorPorZona = {for (final z in zonas) z.id: colorDeZona(z.color)};
    final ordenados = [...jugadores]
      ..sort((a, b) {
        if (a.activo != b.activo) return a.activo ? -1 : 1;
        final porPuntos = b.puntos.compareTo(a.puntos);
        if (porPuntos != 0) return porPuntos;
        final porPrimeros = b.primeros.compareTo(a.primeros);
        return porPrimeros != 0 ? porPrimeros : a.usuario.compareTo(b.usuario);
      });
    final puestos = puestosConEmpates(
      ordenados,
      (j) => (j.activo, j.puntos, j.primeros),
    );
    final hayPuntos = ordenados.any((j) => j.puntos > 0);

    return TarjetaDeSeccion(
      key: const ValueKey('marcador'),
      titulo: 'Marcador',
      nota: 'Cada punto de color es una zona llena',
      child: Column(
        children: [
          for (final (i, jugador) in ordenados.indexed)
            FilaDePuntos(
              key: ValueKey('jugador-${jugador.usuario}'),
              puesto: puestos[i],
              nombre: _nombre(jugador),
              puntos: jugador.puntos,
              lider: hayPuntos && puestos[i] == 1 && jugador.activo,
              mia: jugador.usuario == yo,
              fuera: !jugador.activo,
              zonas: [for (final id in jugador.zonas) ?colorPorZona[id]],
              estado: jugador.activo
                  ? Icon(
                      jugador.listo ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                      key: ValueKey('listo-${jugador.usuario}'),
                      size: 18,
                      color: jugador.listo ? Paleta.disponible : Paleta.tintaSuave,
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  String _nombre(JugadorEnSala jugador) {
    final etiquetas = [
      if (jugador.usuario == yo) 'tú',
      if (jugador.anfitrion) 'anfitrión',
      if (!jugador.activo) estadoDeSalida(jugador.estado),
    ];
    return etiquetas.isEmpty ? jugador.usuario : '${jugador.usuario} (${etiquetas.join(', ')})';
  }
}
