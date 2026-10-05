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

/// Cómo se resalta una celda mientras se busca dónde anotar el dado anclado.
enum Iluminacion {
  /// Sin resaltar.
  normal,

  /// El número anclado se puede anotar aquí.
  posible,

  /// La casilla está libre, pero la regla de su zona no acepta el número.
  bloqueada,
}

/// Representa visualmente una [Celda]: fondo del color de su zona, borde
/// grueso si es una casilla inicial, y el valor anotado (si tiene).
///
/// Con [seleccionada], el borde se resalta en ámbar para marcar la casilla
/// donde va a caer el próximo número. Con [iluminacion], la celda se marca
/// con borde blanco si el dado anclado cabe ahí, o se oscurece si no cabe.
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

  @override
  Widget build(BuildContext context) {
    final posible = iluminacion == Iluminacion.posible;

    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorPorColor5[celda.color],
        border: Border.all(
          color: seleccionada
              ? Colors.amber
              : (posible ? Colors.white : Colors.black),
          width: seleccionada || posible ? 4 : (celda.esInicial ? 3 : 1),
        ),
      ),
      foregroundDecoration: iluminacion == Iluminacion.bloqueada
          ? const BoxDecoration(color: Colors.black54)
          : null,
      child: Text(
        celda.valor?.toString() ?? '',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
