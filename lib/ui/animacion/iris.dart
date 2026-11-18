import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../tema.dart';
import '../widgets/piezas.dart';
import 'cartoon.dart';

/// El iris de los dibujos animados viejos: la pantalla en tinta con un hueco redondo, que
/// se cierra o se abre. Solo en los momentos clave: al empezar la partida y al terminarla.

/// La tinta que cubre todo menos un círculo de [radio] alrededor de [centro].
class TintaConHueco extends CustomPainter {
  final Offset centro;
  final double radio;

  const TintaConHueco({required this.centro, required this.radio});

  @override
  void paint(Canvas canvas, Size size) {
    final todo = Offset.zero & size;
    // Si el hueco ya cubre toda la pantalla, no hay nada que pintar.
    final esquinaMasLejana = [
      todo.topLeft,
      todo.topRight,
      todo.bottomLeft,
      todo.bottomRight,
    ].map((e) => (e - centro).distance).reduce(math.max);
    if (radio >= esquinaMasLejana) return;
    final tinta = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(todo)
      ..addOval(Rect.fromCircle(center: centro, radius: math.max(radio, 0)));
    canvas.drawPath(tinta, Paint()..color = Paleta.tinta);
  }

  @override
  bool shouldRepaint(TintaConHueco antes) =>
      centro != antes.centro || radio != antes.radio;
}

/// El radio que cubre toda un área de [tamano] desde [centro].
double radioQueCubre(Size tamano, Offset centro) => [
  Offset.zero,
  Offset(tamano.width, 0),
  Offset(0, tamano.height),
  Offset(tamano.width, tamano.height),
].map((e) => (e - centro).distance).reduce(math.max);

/// Recorta a su hijo en un círculo.
class _Circulo extends CustomClipper<Path> {
  final Offset centro;
  final double radio;

  const _Circulo(this.centro, this.radio);

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: centro, radius: radio));

  @override
  bool shouldReclip(_Circulo antes) =>
      centro != antes.centro || radio != antes.radio;
}

/// Una ruta que entra con el iris: primero el círculo se cierra sobre la pantalla de
/// antes, hasta quedar todo en tinta, y después se abre desde el centro sobre la nueva. Al
/// volver, al revés. Con movimiento reducido, entra sin animación.
///
/// Mientras se cierra, la pantalla nueva ya está encima pero no se ve: no recibe toques
/// (si no, un toque rápido, como un doble toque en "Inicio", tiraría los dados a ciegas).
class RutaConIris<T> extends PageRouteBuilder<T> {
  RutaConIris({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: Cartoon.irisApertura,
        reverseTransitionDuration: Cartoon.irisApertura,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animacion, _, hijo) {
          if (Cartoon.quieto(context)) return hijo;
          return AnimatedBuilder(
            animation: animacion,
            child: hijo,
            builder: (context, hijo) {
              final t = animacion.value;
              final tamano = MediaQuery.sizeOf(context);
              final centro = tamano.center(Offset.zero);
              final todo = radioQueCubre(tamano, centro);
              // Hasta el 40 % se cierra sobre la de antes (la nueva no se ve); después, se
              // abre sobre la nueva. La nueva va siempre en el mismo lugar del árbol, así
              // no pierde su estado al cambiar de mitad.
              final cerrando = t < 0.4;
              final radio = cerrando
                  ? todo * (1 - Curves.easeIn.transform(t / 0.4))
                  : todo * Curves.easeOut.transform((t - 0.4) / 0.6);
              return Stack(
                fit: StackFit.expand,
                children: [
                  AbsorbPointer(
                    absorbing: cerrando,
                    child: ClipPath(
                      clipper: _Circulo(centro, cerrando ? todo : radio),
                      child: Opacity(opacity: cerrando ? 0 : 1, child: hijo),
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      key: const ValueKey('iris'),
                      painter: TintaConHueco(
                        centro: centro,
                        radio: t >= 1 ? todo : radio,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
}

/// El iris encima de [child], que se juega una vez cada vez que [disparador] cambia a un
/// valor que no es `null` (con [alAparecer], también si ya lo tiene al dibujarse). Con
/// cierre, se cierra sobre el trofeo (la primera [Insignia] que haya adentro), se queda un
/// instante y se vuelve a abrir; si no hay trofeo a la vista, sobre el centro. La
/// apertura solo se abre desde el centro. Nunca bloquea los toques, y con movimiento
/// reducido no aparece.
class Iris extends StatefulWidget {
  final Object? disparador;
  final bool cierre;
  final bool alAparecer;
  final Widget child;

  const Iris.apertura({
    super.key,
    required this.disparador,
    this.alAparecer = false,
    required this.child,
  }) : cierre = false;

  const Iris.cierre({super.key, required this.disparador, required this.child})
    : cierre = true,
      alAparecer = false;

  @override
  State<Iris> createState() => _IrisState();
}

class _IrisState extends State<Iris> with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(
    vsync: this,
    duration: widget.cierre ? Cartoon.irisCierre : Cartoon.irisApertura,
    value: 1,
  );
  final _area = GlobalKey();
  var _porJugar = false;

  /// Dónde está el trofeo dentro del área, o `null` si no está a la vista. Se busca en
  /// cada cuadro de la animación, antes de dibujar (durante el dibujo no se puede recorrer
  /// el árbol): así lo sigue si la pantalla se desplaza para mostrarlo.
  Offset? _centroDelTrofeo;

  @override
  void initState() {
    super.initState();
    _porJugar = widget.alAparecer && widget.disparador != null;
    if (widget.cierre) {
      _animacion.addListener(() {
        // Solo en los cuadros de la animación: al arrancarla desde un build también avisa,
        // y ahí todavía no se puede recorrer el árbol.
        final fase = SchedulerBinding.instance.schedulerPhase;
        if (_animacion.value < 1 && fase == SchedulerPhase.transientCallbacks) {
          _centroDelTrofeo = _centro();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_porJugar) {
      _porJugar = false;
      _jugar();
    }
  }

  @override
  void didUpdateWidget(Iris antes) {
    super.didUpdateWidget(antes);
    if (widget.disparador != null && widget.disparador != antes.disparador) {
      _jugar();
    }
  }

  void _jugar() {
    if (Cartoon.quieto(context)) return;
    _animacion.forward(from: 0);
    if (!widget.cierre) return;
    // Que el trofeo se vea: si quedó fuera de la pantalla, se lleva a la vista.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trofeo = _trofeo();
      if (trofeo != null && trofeo.mounted) {
        Scrollable.ensureVisible(trofeo, alignment: 0.3);
      }
    });
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  /// La primera insignia que haya dentro del iris, o `null`.
  Element? _trofeo() {
    Element? encontrada;
    void buscar(Element elemento) {
      if (encontrada != null) return;
      if (elemento.widget is Insignia) {
        encontrada = elemento;
        return;
      }
      elemento.visitChildElements(buscar);
    }

    final area = _area.currentContext;
    if (area is Element) area.visitChildElements(buscar);
    return encontrada;
  }

  /// Dónde está el trofeo dentro del área del iris, si está a la vista.
  Offset? _centro() {
    final trofeo = _trofeo()?.findRenderObject();
    final area = _area.currentContext?.findRenderObject();
    if (trofeo is! RenderBox || area is! RenderBox) return null;
    if (!trofeo.attached || !area.attached || !trofeo.hasSize || !area.hasSize) {
      return null;
    }
    final enPantalla = trofeo.localToGlobal(trofeo.size.center(Offset.zero));
    final local = area.globalToLocal(enPantalla);
    return (Offset.zero & area.size).contains(local) ? local : null;
  }

  @override
  Widget build(BuildContext context) {
    // Ocupa toda el área que recibe, aunque lo de adentro sea más bajo (por ejemplo, el
    // contenido de una pantalla que se desplaza): si no, el iris dejaría un pedazo sin
    // tinta.
    return Stack(
      key: _area,
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animacion,
              builder: (context, _) => LayoutBuilder(
                builder: (context, restricciones) {
                  final tamano = restricciones.biggest;
                  // En reposo no se busca nada: el iris está abierto del todo.
                  if (_animacion.value >= 1) {
                    return const SizedBox.shrink(key: ValueKey('iris'));
                  }
                  final centro =
                      (widget.cierre ? _centroDelTrofeo : null) ??
                      tamano.center(Offset.zero);
                  final todo = radioQueCubre(tamano, centro);
                  return CustomPaint(
                    key: const ValueKey('iris'),
                    painter: TintaConHueco(centro: centro, radio: _radio(todo)),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// El radio del hueco ahora, para un área que se cubre con [todo].
  double _radio(double todo) {
    final t = _animacion.value;
    if (t >= 1) return todo;
    if (!widget.cierre) return todo * Curves.easeOut.transform(t);
    // Se cierra hasta dejar solo el trofeo, se queda un instante y se abre.
    const alrededorDelTrofeo = 52.0;
    if (t < 0.4) {
      return alrededorDelTrofeo +
          (todo - alrededorDelTrofeo) * (1 - Curves.easeIn.transform(t / 0.4));
    }
    if (t < 0.6) return alrededorDelTrofeo;
    return alrededorDelTrofeo +
        (todo - alrededorDelTrofeo) * Curves.easeOut.transform((t - 0.6) / 0.4);
  }
}
