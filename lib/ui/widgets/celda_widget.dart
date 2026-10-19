import 'package:flutter/material.dart';

import '../../modelo/celda.dart';
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
/// llevan un aro blanco con un brillo suave, para que se vean encendidas y no
/// desteñidas; [Iluminacion.bloqueada] solo se aclara un poco. El cambio es
/// una transición suave.
///
/// Con [numeroResaltado], el número de la casilla se ilumina: va sobre un
/// círculo claro. Se usa para las casillas que tienen el número que sacó el
/// dado ancla.
class CeldaWidget extends StatelessWidget {
  final Celda celda;
  final double tamano;
  final bool seleccionada;
  final Iluminacion iluminacion;
  final bool numeroResaltado;

  const CeldaWidget({
    super.key,
    required this.celda,
    this.tamano = 48,
    this.seleccionada = false,
    this.iluminacion = Iluminacion.normal,
    this.numeroResaltado = false,
  });

  double get _aclarado {
    if (seleccionada || iluminacion == Iluminacion.posible) return _aclaradoFuerte;
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
        fontSize: tamano * 0.42,
        fontWeight: FontWeight.w700,
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
      child: _fichaAnimada(colorZona, fondo, encendida, numero),
    );
  }

  Widget _fichaAnimada(Color colorZona, Color fondo, bool encendida, Widget numero) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * 0.24),
        border: encendida
            ? Border.all(color: Colors.white, width: 3)
            : celda.esInicial
                ? Border.all(
                    color: Color.lerp(colorZona, Colors.black, _oscurecidoDelAro)!,
                    width: 2,
                  )
                : null,
        boxShadow: encendida
            ? [
                BoxShadow(
                  color: Paleta.acento.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: numeroResaltado ? _NumeroResaltado(tamano: tamano * 0.68, child: numero) : numero,
    );
  }
}

/// El círculo claro detrás del número resaltado, para que se vea iluminado en
/// cualquier color de zona.
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
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: child,
    );
  }
}
