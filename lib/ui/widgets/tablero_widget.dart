import 'package:flutter/material.dart';

import '../../modelo/posicion.dart';
import '../../modelo/tablero.dart';
import '../animacion/cartoon.dart';
import '../tema.dart';
import 'celda_widget.dart';

/// Dibuja el tablero completo de un [Tablero]: las 49 fichas con el color de
/// su región y el número que tengan anotado, sobre una base de tinta que se ve
/// entre ellas como la cuadrícula impresa de un tablero, con una sombra dura
/// debajo. No muestra coordenadas: las letras y números del manual solo existen
/// en el código.
///
/// Las celdas para las que [esTocable] devuelve verdadero responden al toque
/// llamando a [alTocar] con su posición. [iluminacionDe] decide cómo se
/// resalta cada celda; sin él, ninguna se resalta. Las celdas para las que
/// [numeroResaltadoEn] devuelve verdadero iluminan su número.
///
/// El tablero se adapta al ancho que tenga: las fichas miden hasta
/// [tamanoMaximoCelda], y se achican si no caben, como en un celular angosto.
///
/// Cuando cambia el tablero, festeja como en los dibujos animados viejos: donde
/// se anotó un número sale un "¡puf!" de polvo, y las casillas de una zona que se
/// acaba de llenar se menean (ver [CeldaWidget]). Al dibujarse por primera vez no
/// se mueve nada, ni cuando pasa a ser el tablero de otro mapa (por ejemplo, la tarjeta
/// del lobby cuando el anfitrión cambia de mapa).
class TableroWidget extends StatefulWidget {
  final Tablero tablero;
  final Posicion? seleccionada;
  final void Function(Posicion)? alTocar;
  final bool Function(Posicion)? esTocable;
  final Iluminacion Function(Posicion)? iluminacionDe;
  final bool Function(Posicion)? numeroResaltadoEn;

  /// La casilla que lleva el aro de "aquí no se puede" (ver `CeldaWidget.marcada`).
  final Posicion? marcada;
  final double tamanoMaximoCelda;

  const TableroWidget({
    super.key,
    required this.tablero,
    this.seleccionada,
    this.alTocar,
    this.esTocable,
    this.iluminacionDe,
    this.numeroResaltadoEn,
    this.marcada,
    this.tamanoMaximoCelda = 48,
  });

  /// El espacio entre ficha y ficha.
  static const separacion = 4.0;

  /// El borde de la base alrededor de las fichas.
  static const relleno = 6.0;

  @override
  State<TableroWidget> createState() => _TableroWidgetState();
}

class _TableroWidgetState extends State<TableroWidget>
    with SingleTickerProviderStateMixin {
  /// El polvo de las casillas recién anotadas. Empieza terminado.
  late final _polvo = AnimationController(
    vsync: this,
    duration: Cartoon.anotar,
    value: 1,
  );
  var _conPolvo = <Posicion>[];

  /// Las casillas de las zonas que se acaban de llenar, y un número que cambia con cada
  /// festejo (así la casilla sabe que es uno nuevo).
  var _festejando = <Posicion>{};
  var _festejo = 0;

  /// La forma del mapa que se está dibujando (ver [_formaDe]).
  late var _forma = _formaDe(widget.tablero);

  /// La forma de un mapa: qué casillas tiene cada zona, de qué color y con qué regla. Dos
  /// tableros con la misma forma son el mismo mapa, con otros números. Contar las zonas no
  /// alcanza: el Nivel 3 y el Nivel 4 tienen 8 cada uno.
  static String _formaDe(Tablero tablero) => [
    for (final region in tablero.regiones)
      '${region.tipo.color.name} ${region.tipo.regla.descripcion}: '
          '${region.casillas.map((c) => c.posicion.notacion).join(',')}',
  ].join(' | ');

  @override
  void dispose() {
    _polvo.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TableroWidget antes) {
    super.didUpdateWidget(antes);
    final ahora = widget.tablero;
    final previo = antes.tablero;
    final forma = _formaDe(ahora);
    if (forma != _forma) {
      // Otro mapa: no hay nada que festejar. Las casillas se dibujan de nuevo (ver
      // `build`), así tampoco festejan ellas.
      _forma = forma;
      _conPolvo = [];
      _polvo.value = 1;
      _festejando = {};
      return;
    }
    if (Cartoon.quieto(context)) return;

    final nuevas = [
      for (final celda in ahora.celdas)
        if (celda.valor != null &&
            previo.celdaEn(celda.posicion)?.valor == null)
          celda.posicion,
    ];
    if (nuevas.isNotEmpty) {
      _conPolvo = nuevas;
      _polvo.forward(from: 0);
    }

    final llenas = <Posicion>{};
    for (final (i, region) in ahora.regiones.indexed) {
      if (region.completada && !previo.regiones[i].completada) {
        llenas.addAll(region.casillas.map((c) => c.posicion));
      }
    }
    if (llenas.isNotEmpty) {
      _festejando = llenas;
      _festejo++;
    }
  }

  /// El tamaño de ficha que cabe en [anchoDisponible], sin pasar del máximo:
  /// el tablero ocupa 7 fichas, sus separaciones y el relleno de la base. Se
  /// redondea hacia abajo para que no sobre ni medio píxel.
  double _tamanoQueCabe(double anchoDisponible) {
    if (!anchoDisponible.isFinite) return widget.tamanoMaximoCelda;
    final queCabe =
        ((anchoDisponible - 2 * TableroWidget.relleno) / Tablero.columnas -
                TableroWidget.separacion)
            .floorToDouble();
    return queCabe < widget.tamanoMaximoCelda
        ? queCabe
        : widget.tamanoMaximoCelda;
  }

  /// El centro de la casilla [posicion] dentro de la base, con fichas de [tamano].
  static Offset _centroDe(Posicion posicion, double tamano) {
    const paso = TableroWidget.separacion;
    final lado = tamano + paso;
    return Offset(
      TableroWidget.relleno + posicion.columna * lado + paso / 2 + tamano / 2,
      TableroWidget.relleno + posicion.fila * lado + paso / 2 + tamano / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final tamano = _tamanoQueCabe(restricciones.maxWidth);

        final base = Container(
          // Con otro mapa, las casillas empiezan de nuevo: como al dibujarse por primera
          // vez, no comparan con las del mapa de antes.
          key: ValueKey(_forma),
          padding: const EdgeInsets.all(TableroWidget.relleno),
          // Deja ver la sombra dura bajo el tablero.
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: Paleta.tinta,
            borderRadius: BorderRadius.circular(tamano * 0.3),
            boxShadow: sombraDura(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var fila = 0; fila < Tablero.filas; fila++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var columna = 0; columna < Tablero.columnas; columna++)
                      Padding(
                        padding: const EdgeInsets.all(
                          TableroWidget.separacion / 2,
                        ),
                        child: _celda(
                          Posicion(fila: fila, columna: columna),
                          tamano,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );

        // El polvo va encima de todas las fichas, para que no lo tape la de al lado.
        return Stack(
          clipBehavior: Clip.none,
          children: [
            base,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _polvo,
                  builder: (context, _) => CustomPaint(
                    key: const ValueKey('polvo-del-tablero'),
                    painter: _PolvoEnCasillas(
                      // "Animado en dos": a 12 cuadros por segundo.
                      progreso: const EnDos(
                        Curves.linear,
                        Cartoon.anotar,
                      ).transform(_polvo.value),
                      centros: [
                        for (final p in _conPolvo) _centroDe(p, tamano),
                      ],
                      alcance: tamano * 0.62,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _celda(Posicion posicion, double tamano) {
    final celda = CeldaWidget(
      celda: widget.tablero.celdaEn(posicion)!,
      tamano: tamano,
      seleccionada: posicion == widget.seleccionada,
      iluminacion: widget.iluminacionDe?.call(posicion) ?? Iluminacion.normal,
      numeroResaltado: widget.numeroResaltadoEn?.call(posicion) ?? false,
      marcada: posicion == widget.marcada,
      festejo: _festejando.contains(posicion) ? _festejo : 0,
    );

    final tocable =
        widget.alTocar != null && (widget.esTocable?.call(posicion) ?? true);

    final alTocar = tocable ? () => widget.alTocar!(posicion) : null;

    // La ficha va siempre en el mismo lugar (así conserva sus animaciones al volverse
    // tocable); el toque va encima, solo si responde. Para el lector de pantalla, el
    // toque va en la misma casilla que su número: la capa de encima no se lee (si no,
    // sería un botón vacío sobre cada casilla).
    return Semantics(
      onTap: alTocar,
      child: Stack(
        children: [
          celda,
          if (tocable)
            Positioned.fill(
              child: GestureDetector(
                key: ValueKey('casilla-${posicion.notacion}'),
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: alTocar,
                child: const MouseRegion(cursor: SystemMouseCursors.click),
              ),
            ),
        ],
      ),
    );
  }
}

/// El "¡puf!" de polvo en cada casilla recién anotada.
class _PolvoEnCasillas extends CustomPainter {
  final double progreso;
  final List<Offset> centros;
  final double alcance;

  const _PolvoEnCasillas({
    required this.progreso,
    required this.centros,
    required this.alcance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final centro in centros) {
      NubesDePolvo(
        progreso: progreso,
        centro: centro,
        alcance: alcance,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_PolvoEnCasillas antes) =>
      progreso != antes.progreso ||
      centros.length != antes.centros.length ||
      alcance != antes.alcance;
}
