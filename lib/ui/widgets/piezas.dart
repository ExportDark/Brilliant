import 'package:flutter/material.dart';

import '../animacion/cartoon.dart';
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
///
/// Como en los dibujos animados viejos, al apretarla además se aplasta (más ancha y más
/// baja), y al soltarla vuelve con un rebote de goma: se estira un poco y se asienta.
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

class _PiezaPresionableState extends State<PiezaPresionable>
    with SingleTickerProviderStateMixin {
  /// Cuánto se aplasta mientras se la aprieta.
  static const aplastadaAlApretar = 0.08;

  var _hundida = false;

  /// El rebote al soltarla. Empieza terminado: en reposo, la pieza está como es.
  late final _rebote = AnimationController(vsync: this, duration: Cartoon.toque, value: 1);

  @override
  void dispose() {
    _rebote.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PiezaPresionable antes) {
    super.didUpdateWidget(antes);
    // Si se deshabilita con el dedo encima, se suelta sola: si no, al volver a
    // habilitarse quedaría hundida y aplastada hasta el próximo toque.
    if (!_activa && _hundida) {
      _hundida = false;
      _rebote.value = 1;
    }
  }

  void _hundir(bool hundida) {
    if (hundida == _hundida) return;
    // Deshabilitada no se aprieta, pero soltarla siempre la suelta.
    if (hundida && !_activa) return;
    setState(() => _hundida = hundida);
    if (hundida) {
      _rebote.value = 1;
    } else if (!Cartoon.quieto(context)) {
      _rebote.forward(from: 0);
    }
  }

  /// Cuánto se aplasta ahora: apretada, un poco; al soltarla, de ahí a cero con la goma
  /// (que se pasa: se estira un instante antes de asentarse).
  double get _aplastado {
    if (!_activa || Cartoon.quieto(context)) return 0;
    if (_hundida) return aplastadaAlApretar;
    return aplastadaAlApretar * (1 - curvaDeGoma.transform(_rebote.value));
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
        child: AnimatedBuilder(
          animation: _rebote,
          builder: (context, hijo) => AplastarYEstirar(
            key: const ValueKey('aplastar-y-estirar'),
            aplastado: _aplastado,
            child: hijo!,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Una ficha redonda con un ícono, como el trofeo del final de la partida: de color, con
/// borde de tinta y sombra dura, y el ícono en tinta para que se lea sobre cualquier color.
class Insignia extends StatefulWidget {
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
  State<Insignia> createState() => _InsigniaState();
}

/// Al aparecer, la insignia entra de golpe con el rebote de goma y suelta rayitas de
/// brillo alrededor, el "¡ding!" de los dibujos animados viejos.
class _InsigniaState extends State<Insignia> with SingleTickerProviderStateMixin {
  late final _entrada = AnimationController(vsync: this, duration: Cartoon.insignia, value: 1);
  var _porEntrar = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_porEntrar) {
      _porEntrar = false;
      if (!Cartoon.quieto(context)) _entrada.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamano = widget.tamano;
    final ficha = Container(
      width: tamano,
      height: tamano,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        border: Border.all(color: Paleta.tinta, width: grosorDeTinta),
        boxShadow: sombraDura(3),
      ),
      child: Icon(widget.icono, size: tamano * 0.52, color: Paleta.tinta),
    );

    return AnimatedBuilder(
      animation: _entrada,
      builder: (context, hijo) {
        final t = _entrada.value;
        // Las rayitas salen cuando ya entró, "en dos".
        final brillo = t < 0.35 ? 0.0 : (t - 0.35) / 0.65;
        return CustomPaint(
          key: const ValueKey('brillo-de-la-insignia'),
          foregroundPainter: RayitasDeBrillo(
            progreso: t >= 1 ? 1 : const EnDos(Curves.linear, Cartoon.insignia).transform(brillo),
            centro: Offset(tamano / 2, tamano / 2),
            radio: tamano / 2,
          ),
          child: Transform.scale(
            key: const ValueKey('entrada-de-la-insignia'),
            scale: t >= 1 ? 1 : curvaDeGoma.transform(t),
            child: hijo,
          ),
        );
      },
      child: ficha,
    );
  }
}
