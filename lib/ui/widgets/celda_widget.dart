import 'package:flutter/material.dart';

import '../../modelo/celda.dart';
import '../../modelo/color5.dart';

const _colorPorColor5 = {
  Color5.amarillo: Colors.yellow,
  Color5.verde: Colors.green,
  Color5.morado: Colors.purple,
  Color5.azul: Colors.blue,
  Color5.rojo: Colors.red,
};

/// Cuánto se acerca al blanco el color de la zona al iluminar una casilla:
/// mucho para las que se pueden usar, poco para las que la regla bloquea.
const _aclaradoFuerte = 0.55;
const _aclaradoSuave = 0.25;

/// Cómo se resalta una celda mientras se busca dónde anotar el dado.
enum Iluminacion {
  /// Sin resaltar.
  normal,

  /// El número se puede anotar aquí.
  posible,

  /// La casilla está libre, pero la regla de su zona no acepta el número.
  bloqueada,
}

/// Representa visualmente una [Celda]: fondo del color de su zona, borde
/// grueso si es una casilla inicial, y el valor anotado (si tiene).
///
/// La cuadrícula siempre es negra: para resaltar una casilla se ilumina su
/// relleno, que se aclara hacia el blanco. [seleccionada] (la casilla donde
/// va a caer el próximo número) y [Iluminacion.posible] se aclaran mucho;
/// [Iluminacion.bloqueada], solo un poco.
class CeldaWidget extends StatelessWidget {
  final Celda celda;
  final double tamano;
  final bool seleccionada;
  final Iluminacion iluminacion;

  const CeldaWidget({
    super.key,
    required this.celda,
    this.tamano = 48,
    this.seleccionada = false,
    this.iluminacion = Iluminacion.normal,
  });

  double get _aclarado {
    if (seleccionada || iluminacion == Iluminacion.posible) return _aclaradoFuerte;
    if (iluminacion == Iluminacion.bloqueada) return _aclaradoSuave;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final aclarado = _aclarado;

    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.lerp(_colorPorColor5[celda.color], Colors.white, aclarado),
        border: Border.all(width: celda.esInicial ? 3 : 1),
      ),
      child: Text(
        celda.valor?.toString() ?? '',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          // Sobre un fondo muy aclarado, el blanco ya no se lee.
          color: aclarado >= _aclaradoFuerte ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}
