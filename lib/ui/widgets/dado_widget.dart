import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animacion/cartoon.dart';
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

/// Un dado de la tirada, dibujado como una pieza: un cubo claro con borde de
/// tinta, sus puntos y una sombra dura.
///
/// Con [anclado], el dado es el dado ancla: se hunde, se pinta del amarillo de
/// ficha y debajo lleva un ancla con la palabra "ancla". Es el único lugar de
/// la app donde aparece el ancla.
///
/// Se mueve como en los dibujos animados viejos: al tirarlo se agacha, salta
/// estirándose y dando una vuelta (con las caras cambiando en el aire, "en dos"),
/// y cae aplastado en su cara, rebotando. Al elegirlo como ancla da un brinco.
/// Lo que lee un lector de pantalla, y el toque, son siempre los de la cara real.
class DadoWidget extends StatefulWidget {
  final int valor;
  final bool anclado;
  final VoidCallback? alTocar;
  final double tamano;

  /// Qué tirada es (el turno, o la ronda en línea): cuando cambia, el dado salta.
  final int? tirada;

  /// Si también salta la primera vez que se dibuja (al tirar los dados).
  final bool saltaAlAparecer;

  /// Cuánto espera antes de saltar: el segundo dado sale un poquito después.
  final Duration demora;

  const DadoWidget({
    super.key,
    required this.valor,
    this.anclado = false,
    this.alTocar,
    this.tamano = 68,
    this.tirada,
    this.saltaAlAparecer = false,
    this.demora = Duration.zero,
  }) : assert(valor >= 1 && valor <= 6);

  @override
  State<DadoWidget> createState() => _DadoWidgetState();
}

class _DadoWidgetState extends State<DadoWidget> with TickerProviderStateMixin {
  /// El salto de la tirada (con su demora adelante). Empieza terminado.
  late final _salto = AnimationController(
    vsync: this,
    duration: widget.demora + Cartoon.tirada,
    value: 1,
  );

  /// El brinco al elegirlo como ancla.
  late final _brinco = AnimationController(vsync: this, duration: Cartoon.brinco, value: 1);

  var _porSaltar = false;

  @override
  void initState() {
    super.initState();
    _porSaltar = widget.saltaAlAparecer;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_porSaltar) {
      _porSaltar = false;
      if (!Cartoon.quieto(context)) _salto.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(DadoWidget antes) {
    super.didUpdateWidget(antes);
    if (Cartoon.quieto(context)) return;
    if (widget.tirada != antes.tirada) {
      _salto.duration = widget.demora + Cartoon.tirada;
      _salto.forward(from: 0);
    } else if (widget.anclado && !antes.anclado) {
      _brinco.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _salto.dispose();
    _brinco.dispose();
    super.dispose();
  }

  /// Dónde está el dado ahora: cuánto subió, cuánto se aplastó (o se estiró), cuánto
  /// giró y qué cara muestra.
  ({double alto, double aplastado, double giro, int cara}) _pose() {
    final total = _salto.duration!.inMicroseconds;
    final demora = widget.demora.inMicroseconds;
    final p = ((_salto.value * total - demora) / (total - demora)).clamp(0.0, 1.0);
    final altura = widget.tamano * 0.45;

    var alto = 0.0, aplastado = 0.0, giro = 0.0;
    var cara = widget.valor;
    if (_salto.value < 1) {
      if (p < 0.15) {
        // Se agacha antes de saltar.
        aplastado = 0.18 * (p / 0.15);
      } else if (p < 0.75) {
        // En el aire: sube y baja estirándose, da una vuelta, y las caras cambian "en
        // dos" (12 por segundo).
        final q = (p - 0.15) / 0.6;
        alto = altura * math.sin(math.pi * q);
        aplastado = -0.14 * math.cos(math.pi * q).abs();
        final sentido = widget.demora > Duration.zero ? -1 : 1;
        giro = sentido * 2 * math.pi * Curves.easeInOut.transform(q);
        final cuadro = (_salto.value * total / 1e6 * 12).floor();
        cara = (widget.valor + (widget.tirada ?? 0) * 5 + cuadro * 7) % 6 + 1;
      } else {
        // Cae aplastado en su cara y rebota hasta asentarse.
        final r = (p - 0.75) / 0.25;
        aplastado = 0.22 * (1 - const CurvaDeGoma(rebotes: 1).transform(r));
      }
    }

    // El brinco del ancla: sube un poco y cae aplastándose.
    if (_brinco.value < 1) {
      final b = _brinco.value;
      if (b < 0.5) {
        alto += widget.tamano * 0.18 * math.sin(math.pi * b);
        aplastado += -0.08 * math.sin(math.pi * b * 2);
      } else {
        aplastado += 0.14 * (1 - const CurvaDeGoma(rebotes: 1).transform((b - 0.5) / 0.5));
      }
    }
    return (alto: alto, aplastado: aplastado, giro: giro, cara: cara);
  }

  @override
  Widget build(BuildContext context) {
    final tamano = widget.tamano;
    final anclado = widget.anclado;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tamano * 0.22),
      side: BorderSide(color: Paleta.tinta, width: anclado ? 3.5 : grosorDeTinta),
    );
    // El dado es una pieza: con sombra dura. El ancla se hunde (casi sin sombra y un
    // poco más abajo) y se pinta del amarillo de ficha.
    const alto = 5.0;
    final altoAhora = anclado ? 1.0 : alto;
    final sinMovimiento = Cartoon.quieto(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          selected: anclado,
          label: 'Dado: ${widget.valor}',
          excludeSemantics: true,
          child: AnimatedBuilder(
            animation: Listenable.merge([_salto, _brinco]),
            builder: (context, _) {
              final pose = _pose();
              return Transform.translate(
                key: const ValueKey('salto-del-dado'),
                offset: Offset(0, -pose.alto),
                child: AplastarYEstirar(
                  aplastado: pose.aplastado,
                  child: Transform.rotate(
                    key: const ValueKey('giro-del-dado'),
                    angle: pose.giro,
                    child: AnimatedContainer(
                      duration: sinMovimiento ? Duration.zero : const Duration(milliseconds: 90),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(0, alto - altoAhora, 0),
                      margin: const EdgeInsets.only(bottom: alto),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tamano * 0.22),
                        boxShadow: sombraDura(altoAhora),
                      ),
                      child: Material(
                        color: anclado ? Paleta.ficha : const Color(0xFFFFFCF4),
                        shape: forma,
                        child: InkWell(
                          customBorder: forma,
                          onTap: widget.alTocar,
                          child: SizedBox.square(
                            dimension: tamano,
                            child: Padding(
                              padding: EdgeInsets.all(tamano * 0.2),
                              child: _Puntos(valor: pose.cara, tamanoPunto: tamano * 0.16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        AnimatedOpacity(
          opacity: anclado ? 1 : 0,
          duration: sinMovimiento ? Duration.zero : const Duration(milliseconds: 160),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.anchor, size: 16, color: Paleta.tinta),
              SizedBox(width: 4),
              Text(
                'ancla',
                style: TextStyle(color: Paleta.tinta, fontWeight: FontWeight.w800),
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
