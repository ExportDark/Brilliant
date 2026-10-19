import 'package:flutter/material.dart';

import '../tema.dart';

/// Dónde van los puntos de cada cara del dado, en una grilla de 3×3: cada par
/// es (fila, columna), de 0 a 2.
const _puntosPorCara = {
  1: [(1, 1)],
  2: [(0, 0), (2, 2)],
  3: [(0, 0), (1, 1), (2, 2)],
  4: [(0, 0), (0, 2), (2, 0), (2, 2)],
  5: [(0, 0), (0, 2), (1, 1), (2, 0), (2, 2)],
  6: [(0, 0), (1, 0), (2, 0), (0, 2), (1, 2), (2, 2)],
};

/// Un dado de la tirada, dibujado como un dado de verdad: un cuadro blanco
/// redondeado con sus puntos.
///
/// Con [anclado], el dado es el dado ancla: lleva un aro del color de acento,
/// y debajo un ancla con la palabra "ancla". Es el único lugar de la app
/// donde aparece el ancla.
class DadoWidget extends StatelessWidget {
  final int valor;
  final bool anclado;
  final VoidCallback? alTocar;
  final double tamano;

  const DadoWidget({
    super.key,
    required this.valor,
    this.anclado = false,
    this.alTocar,
    this.tamano = 68,
  }) : assert(valor >= 1 && valor <= 6);

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tamano * 0.26),
      side: anclado
          ? const BorderSide(color: Paleta.acento, width: 3)
          : const BorderSide(color: Color(0xFFE3DCD1), width: 1.5),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          selected: anclado,
          label: 'Dado: $valor',
          excludeSemantics: true,
          child: Material(
            color: anclado ? const Color(0xFFF2EFFC) : Colors.white,
            shape: forma,
            elevation: anclado ? 3 : 1.5,
            shadowColor: Colors.black26,
            child: InkWell(
              customBorder: forma,
              onTap: alTocar,
              child: SizedBox.square(
                dimension: tamano,
                child: Padding(
                  padding: EdgeInsets.all(tamano * 0.2),
                  child: _Puntos(valor: valor, tamanoPunto: tamano * 0.15),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedOpacity(
          opacity: anclado ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.anchor, size: 16, color: Paleta.acento),
              SizedBox(width: 4),
              Text(
                'ancla',
                style: TextStyle(color: Paleta.acento, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Los puntos de una cara, repartidos en una grilla de 3×3.
class _Puntos extends StatelessWidget {
  final int valor;
  final double tamanoPunto;

  const _Puntos({required this.valor, required this.tamanoPunto});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final (fila, columna) in _puntosPorCara[valor]!)
          Align(
            // Alignment va de -1 a 1: las columnas 0, 1 y 2 quedan a la
            // izquierda, al centro y a la derecha.
            alignment: Alignment(columna - 1.0, fila - 1.0),
            child: Container(
              key: const ValueKey('punto-del-dado'),
              width: tamanoPunto,
              height: tamanoPunto,
              decoration: const BoxDecoration(color: Paleta.tinta, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
