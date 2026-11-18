import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../modelo/celda.dart';
import '../animacion/cartoon.dart';
import '../tema.dart';

/// Cuánto se acerca al blanco el color de la zona al iluminar una casilla:
/// más para las que se pueden usar, poco para las que la regla bloquea.
const _aclaradoFuerte = 0.4;
const _aclaradoSuave = 0.25;

/// Cuánto más oscuro que la zona es el aro de las casillas iniciales.
const _oscurecidoDelAro = 0.3;

/// Cómo se resalta una celda mientras se busca dónde anotar el dado.
enum Iluminacion {
  /// Sin resaltar.
  normal,

  /// El número se puede anotar aquí.
  posible,

  /// La casilla está libre, pero la regla de su zona no acepta el número.
  bloqueada,
}

/// Representa visualmente una [Celda] como una ficha redondeada del color de
/// su zona, con el valor anotado (si tiene). Las casillas iniciales llevan un
/// aro tenue en un tono más oscuro de su propio color.
///
/// Para resaltar una casilla se ilumina: [seleccionada] (la casilla donde va
/// a caer el próximo número) e [Iluminacion.posible] se aclaran y además
/// llevan un aro de cartón con un borde amarillo de ficha por fuera, para que
/// se vean como una pieza marcada; [Iluminacion.bloqueada] solo se aclara un
/// poco. El cambio es una transición corta.
///
/// Con [numeroResaltado], el número de la casilla se ilumina: va sobre un
/// círculo claro. Se usa para las casillas que tienen el número que sacó el
/// dado ancla.
///
/// Con [marcada], lleva un aro suave en un tono oscuro de su zona: es la casilla que se
/// tocó y no se pudo usar, mientras se explica por qué.
///
/// Se mueve como en los dibujos animados viejos, solo cuando algo cambia: al anotarse,
/// el número aparece de golpe y rebota; marcada, sacude la cabeza ("aquí no"); al
/// encenderse como posible, da un saltito; y con un [festejo] nuevo (su zona se acaba de
/// llenar), se menea. Las que están en fila salen una tras otra, en ola.
class CeldaWidget extends StatefulWidget {
  final Celda celda;
  final double tamano;
  final bool seleccionada;
  final Iluminacion iluminacion;
  final bool numeroResaltado;
  final bool marcada;

  /// Cambia (a un número distinto de 0) cuando la zona de esta casilla se acaba de llenar:
  /// entonces la casilla se menea.
  final int festejo;

  const CeldaWidget({
    super.key,
    required this.celda,
    this.tamano = 48,
    this.seleccionada = false,
    this.iluminacion = Iluminacion.normal,
    this.numeroResaltado = false,
    this.marcada = false,
    this.festejo = 0,
  });

  @override
  State<CeldaWidget> createState() => _CeldaWidgetState();
}

/// Qué está haciendo la casilla.
enum _Efecto { ninguno, anotar, noSePuede, encender, festejo }

class _CeldaWidgetState extends State<CeldaWidget>
    with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(vsync: this, value: 1);
  var _efecto = _Efecto.ninguno;
  var _demora = Duration.zero;

  Celda get celda => widget.celda;
  double get tamano => widget.tamano;
  bool get seleccionada => widget.seleccionada;
  Iluminacion get iluminacion => widget.iluminacion;
  bool get numeroResaltado => widget.numeroResaltado;
  bool get marcada => widget.marcada;

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CeldaWidget antes) {
    super.didUpdateWidget(antes);
    if (Cartoon.quieto(context)) return;
    // La ola: cada casilla sale un poquito después de la que tiene arriba a la izquierda.
    final enFila = celda.posicion.fila + celda.posicion.columna;
    if (antes.celda.valor == null && celda.valor != null) {
      _empezar(_Efecto.anotar, Cartoon.anotar);
    } else if (marcada && !antes.marcada) {
      _empezar(_Efecto.noSePuede, Cartoon.noSePuede);
    } else if (widget.festejo != 0 && widget.festejo != antes.festejo) {
      _empezar(
        _Efecto.festejo,
        Cartoon.zonaLlena,
        demora: Duration(milliseconds: 25 * enFila),
      );
    } else if (iluminacion == Iluminacion.posible &&
        antes.iluminacion != Iluminacion.posible) {
      _empezar(
        _Efecto.encender,
        Cartoon.encender,
        demora: Duration(milliseconds: 20 * enFila),
      );
    }
  }

  void _empezar(
    _Efecto efecto,
    Duration duracion, {
    Duration demora = Duration.zero,
  }) {
    _efecto = efecto;
    _demora = demora;
    _animacion.duration = demora + duracion;
    _animacion.forward(from: 0);
  }

  /// Cuánto avanzó el efecto (de 0 a 1), sin contar la demora.
  double get _avance {
    final total = _animacion.duration?.inMicroseconds ?? 0;
    final demora = _demora.inMicroseconds;
    if (total <= demora) return 1;
    return ((_animacion.value * total - demora) / (total - demora)).clamp(
      0.0,
      1.0,
    );
  }

  /// La ficha movida según el efecto: sacudida, saltando o meneándose. Siempre va dentro
  /// del mismo `Transform` (en reposo, sin mover nada): si no, la ficha se recrearía al
  /// empezar el efecto y su cambio de color daría un salto.
  Widget _conEfecto(Widget ficha) {
    final matriz = Matrix4.identity();
    final t = _avance;
    switch (_animacion.value >= 1 ? _Efecto.ninguno : _efecto) {
      case _Efecto.noSePuede:
        // "Aquí no": de un lado al otro, tres veces, cada vez menos.
        matriz.translateByDouble(
          tamano * 0.1 * math.sin(t * math.pi * 6) * (1 - t),
          0,
          0,
          1,
        );
      case _Efecto.encender:
        // "¡Aquí!": un saltito.
        matriz.translateByDouble(
          0,
          -tamano * 0.12 * math.sin(math.pi * t),
          0,
          1,
        );
      case _Efecto.festejo:
        // Se menea y se agranda un poco, como si bailara.
        final meneo = math.sin(t * math.pi * 3) * (1 - t);
        matriz
          ..translateByDouble(tamano / 2, tamano / 2, 0, 1)
          ..rotateZ(0.14 * meneo)
          ..scaleByDouble(
            1 + 0.1 * math.sin(math.pi * t),
            1 + 0.1 * math.sin(math.pi * t),
            1,
            1,
          )
          ..translateByDouble(-tamano / 2, -tamano / 2, 0, 1);
      case _Efecto.ninguno || _Efecto.anotar:
        break;
    }
    return Transform(
      key: const ValueKey('efecto-de-celda'),
      transform: matriz,
      child: ficha,
    );
  }

  /// El número recién anotado aparece de golpe: de nada, se pasa y vuelve.
  Widget _numeroConEfecto(Widget numero) {
    final anotando = _efecto == _Efecto.anotar && _animacion.value < 1;
    return Transform.scale(
      key: const ValueKey('numero-que-aparece'),
      scale: anotando ? curvaDeGoma.transform(_avance) : 1,
      child: numero,
    );
  }

  double get _aclarado {
    if (seleccionada || iluminacion == Iluminacion.posible) {
      return _aclaradoFuerte;
    }
    if (iluminacion == Iluminacion.bloqueada) return _aclaradoSuave;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorZona = coloresDeZona[celda.color]!;
    final fondo = Color.lerp(colorZona, Colors.white, _aclarado)!;
    final encendida = seleccionada || iluminacion == Iluminacion.posible;
    final numero = Text(
      celda.valor?.toString() ?? '',
      style: TextStyle(
        fontFamily: familiaDeTitulos,
        fontSize: tamano * 0.44,
        // Sobre el círculo del número resaltado va siempre oscuro; si no,
        // depende de qué tan claro sea el fondo.
        color: numeroResaltado ? Paleta.tinta : tintaSobre(fondo),
      ),
    );

    // Solo se anima el color y el aro. El tamaño va fuera de la animación:
    // si cambiara animado (por ejemplo, al achicar la ventana), el tablero se
    // desbordaría mientras dura la transición.
    return SizedBox.square(
      dimension: tamano,
      child: AnimatedBuilder(
        animation: _animacion,
        builder: (context, _) => _conEfecto(
          _fichaAnimada(colorZona, fondo, encendida, _numeroConEfecto(numero)),
        ),
      ),
    );
  }

  Widget _fichaAnimada(
    Color colorZona,
    Color fondo,
    bool encendida,
    Widget numero,
  ) {
    return AnimatedContainer(
      duration: Cartoon.duracion(context, const Duration(milliseconds: 160)),
      curve: Curves.easeOut,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * 0.18),
        border: encendida
            ? Border.all(color: Paleta.carton, width: 3)
            : marcada
            // "Aquí no se puede": un aro rojo, que se ve sobre cualquier zona.
            ? Border.all(color: Paleta.peligro, width: 3)
            : celda.esInicial
            ? Border.all(
                color: Color.lerp(colorZona, Colors.black, _oscurecidoDelAro)!,
                width: 2,
              )
            : null,
        // La encendida lleva un borde amarillo de ficha por fuera del aro, sin
        // difuminar: se ve aunque la base del tablero sea oscura.
        boxShadow: encendida
            ? const [
                BoxShadow(
                  color: Paleta.ficha,
                  spreadRadius: 2.5,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: numeroResaltado
          ? _NumeroResaltado(tamano: tamano * 0.68, child: numero)
          : numero,
    );
  }
}

/// El círculo de cartón detrás del número resaltado, para que se vea en cualquier
/// color de zona.
class _NumeroResaltado extends StatelessWidget {
  final double tamano;
  final Widget child;

  const _NumeroResaltado({required this.tamano, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Paleta.carton,
        shape: BoxShape.circle,
        border: Border.all(color: Paleta.tinta, width: 1.5),
      ),
      child: child,
    );
  }
}
