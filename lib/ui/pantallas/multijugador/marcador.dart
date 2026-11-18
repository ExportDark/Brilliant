import 'package:flutter/material.dart';

import '../../../modelo/color_zona.dart';
import '../../../modelo/mapa.dart';
import '../../../multijugador/modelos.dart';
import '../../tema.dart';
import 'tablero_chico.dart';
import 'textos_multijugador.dart';

/// La tarjeta blanca de las secciones del multijugador (marcador, zonas, resultado): la
/// misma forma que las tarjetas de "Elige un mapa".
class TarjetaDeSeccion extends StatelessWidget {
  final String titulo;
  final String? nota;
  final Widget child;

  const TarjetaDeSeccion({
    super.key,
    required this.titulo,
    this.nota,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final nota = this.nota;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: sombraDura(4),
      ),
      child: Material(
        color: Paleta.cartonClaro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titulo,
                style: textos.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              // La nota va debajo y a todo lo ancho: a la derecha del título no cabía en un
              // celular y se partía en tres renglones.
              if (nota != null)
                Text(
                  nota,
                  style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
                ),
              const SizedBox(height: 8),
              child,
            ],
          ),
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

  /// Una línea chica bajo el nombre ("Tú", "Se rindió", "2 primeros puestos"…).
  final String? detalle;

  /// Los colores de las zonas que llenó.
  final List<ColorZona> zonas;

  /// Lo que va antes de los puntos, como el ícono de "ya jugó".
  final Widget? estado;

  /// La clave del texto de los puntos.
  final Key? clavePuntos;

  /// La meta de la partida: si se sabe, debajo del nombre va una pista con cuánto falta.
  final int? meta;

  /// El tablero chico del jugador (ver [TableroChico]): va debajo de la fila, a todo lo
  /// ancho, con lo demás a su lado, para no quitarle ancho al nombre.
  final Widget? tablero;

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
    this.meta,
    this.tablero,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final tinta = fuera ? Paleta.tintaSuave : Paleta.tinta;
    final detalle = this.detalle;
    final estado = this.estado;
    final meta = this.meta;
    final tablero = this.tablero;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: mia ? Paleta.ficha.withValues(alpha: 0.3) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                        fontWeight: mia || lider
                            ? FontWeight.w700
                            : FontWeight.w500,
                        decoration: fuera ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (tablero == null) ..._detalles(textos, detalle, meta),
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
                        style: textos.bodySmall?.copyWith(
                          color: Paleta.tintaSuave,
                        ),
                      ),
                    ],
                  ),
                  key: clavePuntos ?? ValueKey('puntos-$nombre-$puntos'),
                ),
              ),
            ],
          ),
          if (tablero != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tablero,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _detalles(textos, detalle, meta),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Lo que va debajo del nombre: un punto por zona llena, las etiquetas y la pista.
  List<Widget> _detalles(TextTheme textos, String? detalle, int? meta) => [
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
    if (meta != null && meta > 0) ...[
      const SizedBox(height: 5),
      _PistaDePuntos(
        key: ValueKey('pista-$nombre'),
        avance: (puntos / meta).clamp(0.0, 1.0),
        apagada: fuera,
      ),
    ],
  ];
}

/// La pista de puntos: una barra fina de lo que lleva sobre la meta, como la pista de
/// puntos de un tablero de juego. Se llena en tinta; la de quien se fue, apagada.
class _PistaDePuntos extends StatelessWidget {
  final double avance;
  final bool apagada;

  const _PistaDePuntos({
    super.key,
    required this.avance,
    required this.apagada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Paleta.baseTablero,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: avance,
        heightFactor: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: apagada ? Paleta.tintaSuave : Paleta.tinta,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
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
        color: lider ? Paleta.ficha : Paleta.baseTablero,
        border: lider ? Border.all(color: Paleta.tinta, width: 2) : null,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$numero',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Paleta.tinta,
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

  /// La meta de la partida, o `null` si el servidor no la manda.
  final int? meta;

  /// El mapa de la partida, para el tablero chico de cada uno.
  final Mapa? mapa;

  const Marcador({
    super.key,
    required this.jugadores,
    required this.yo,
    required this.zonas,
    this.meta,
    this.mapa,
  });

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
      nota: [
        if (meta != null) ganaQuienLlegaA(meta!),
        'Cada punto de color es una zona que llenó.',
      ].join(' '),
      child: Column(
        children: [
          for (final (i, jugador) in ordenados.indexed)
            FilaDePuntos(
              key: ValueKey('jugador-${jugador.usuario}'),
              puesto: puestos[i],
              nombre: jugador.usuario,
              detalle: etiquetasDeJugador(
                mia: jugador.usuario == yo,
                estado: jugador.estado,
              ),
              puntos: jugador.puntos,
              meta: meta,
              tablero: tableroChicoDe(mapa, jugador),
              lider: hayPuntos && puestos[i] == 1 && jugador.activo,
              mia: jugador.usuario == yo,
              fuera: !jugador.activo,
              zonas: [for (final id in jugador.zonas) ?colorPorZona[id]],
              estado: jugador.activo
                  ? Icon(
                      jugador.listo
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_empty_rounded,
                      key: ValueKey('listo-${jugador.usuario}'),
                      size: 18,
                      color: jugador.listo
                          ? Paleta.disponible
                          : Paleta.tintaSuave,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// El tablero chico de [jugador], o `null` si no se sabe el mapa.
Widget? tableroChicoDe(Mapa? mapa, JugadorEnSala? jugador) {
  if (mapa == null || jugador == null) return null;
  return TableroChico(
    key: ValueKey('tablero-chico-${jugador.usuario}'),
    mapa: mapa,
    usuario: jugador.usuario,
    ocupadas: jugador.ocupadas.toSet(),
    ultima: jugador.ultima,
    apagado: !jugador.activo,
  );
}
