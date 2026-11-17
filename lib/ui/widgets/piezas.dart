import 'package:flutter/material.dart';

import '../tema.dart';

/// La decoración de una pieza de cartón: el color, el borde de tinta y la sombra dura.
BoxDecoration decoracionDePieza({
  Color color = Paleta.carton,
  double radio = 16,
  double alto = 4,
  double borde = grosorDeTinta,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radio),
    border: Border.all(color: Paleta.tinta, width: borde),
    boxShadow: alto > 0 ? sombraDura(alto) : null,
  );
}

/// La bandeja de cartón donde va el contenido de una pantalla, apoyada sobre la mesa.
/// Lleva el ancho máximo cómodo para leer, y se centra en pantallas anchas.
class Bandeja extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry relleno;
  final double anchoMaximo;

  const Bandeja({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.fromLTRB(18, 20, 18, 20),
    this.anchoMaximo = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: Container(
          // Deja ver la sombra dura bajo la bandeja.
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: sombraDura(6),
          ),
          // El cartón es un Material: así los toques de las listas (ListTile) se ven
          // sobre él, y no debajo.
          child: Material(
            color: Paleta.carton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
            ),
            child: Padding(padding: relleno, child: child),
          ),
        ),
      ),
    );
  }
}

/// Una pieza que se hunde al tocarla: la sombra dura se acorta y la pieza baja, como un
/// botón de verdad. Envuelve a un botón (u otra cosa tocable) que ya tiene su borde; esta
/// solo pone la sombra y el movimiento. Sin [activa], la sombra no se ve.
class PiezaPresionable extends StatefulWidget {
  final Widget child;
  final bool activa;
  final double radio;
  final double alto;

  const PiezaPresionable({
    super.key,
    required this.child,
    this.activa = true,
    this.radio = 14,
    this.alto = 4,
  });

  @override
  State<PiezaPresionable> createState() => _PiezaPresionableState();
}

class _PiezaPresionableState extends State<PiezaPresionable> {
  var _hundida = false;

  void _hundir(bool hundida) {
    if (_activa && hundida != _hundida) {
      setState(() => _hundida = hundida);
    }
  }

  /// Si se ve como pieza: no si se la apagó, ni si el botón que envuelve está deshabilitado.
  bool get _activa {
    final hijo = widget.child;
    return widget.activa && (hijo is! ButtonStyleButton || hijo.enabled);
  }

  @override
  Widget build(BuildContext context) {
    final alto = !_activa ? 0.0 : (_hundida ? 1.0 : widget.alto);
    // Sin animaciones si el sistema pide reducirlas.
    final sinMovimiento = MediaQuery.disableAnimationsOf(context);

    return Listener(
      onPointerDown: (_) => _hundir(true),
      onPointerUp: (_) => _hundir(false),
      onPointerCancel: (_) => _hundir(false),
      child: AnimatedContainer(
        duration: sinMovimiento
            ? Duration.zero
            : const Duration(milliseconds: 70),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, widget.alto - alto, 0),
        margin: EdgeInsets.only(bottom: widget.alto),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radio),
          boxShadow: alto > 0 ? sombraDura(alto) : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Una ficha redonda con un ícono, como el trofeo del final de la partida: de color, con
/// borde de tinta y sombra dura, y el ícono en tinta para que se lea sobre cualquier color.
class Insignia extends StatelessWidget {
  final IconData icono;
  final Color color;
  final double tamano;

  const Insignia({
    super.key,
    required this.icono,
    this.color = Paleta.ficha,
    this.tamano = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Paleta.tinta, width: grosorDeTinta),
        boxShadow: sombraDura(3),
      ),
      child: Icon(icono, size: tamano * 0.52, color: Paleta.tinta),
    );
  }
}
