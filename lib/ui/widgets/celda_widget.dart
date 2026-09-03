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

/// Representa visualmente una [Celda]: fondo del color de su zona, borde
/// grueso si es una casilla inicial, y el valor anotado (si tiene).
class CeldaWidget extends StatelessWidget {
  final Celda celda;
  final double tamano;

  const CeldaWidget({super.key, required this.celda, this.tamano = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorPorColor5[celda.color],
        border: Border.all(
          color: Colors.black,
          width: celda.esInicial ? 3 : 1,
        ),
      ),
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
