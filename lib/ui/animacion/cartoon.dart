import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema.dart';

/// La base de las animaciones de la app, al estilo de los dibujos animados viejos: las
/// piezas se aplastan al chocar y se estiran al saltar, se agachan antes de arrancar, y
/// vuelven con un rebote de goma que se pasa de largo y se apaga. Lo decorativo (el
/// polvo, las rayitas de brillo, las caras del dado en el aire) cambia "en dos": a 12
/// cuadros por segundo, como esas caricaturas.
///
/// Reglas para todas: solo se mueve algo cuando pasa algo (tocar, tirar, anotar,
/// terminar), nada se mueve en reposo; solo con transformaciones (nunca cambia el tamaño
/// en el layout); y si el sistema pide reducir movimiento, nada se mueve.
abstract final class Cartoon {
  /// Lo que tarda cada animación. Ninguna jugada se frena más de medio segundo; el iris
  /// del final es la excepción, una vez por partida.
  static const toque = Duration(milliseconds: 320);
  static const tirada = Duration(milliseconds: 480);
  static const desfaseDelSegundoDado = Duration(milliseconds: 60);
  static const brinco = Duration(milliseconds: 300);
  static const anotar = Duration(milliseconds: 380);
  static const noSePuede = Duration(milliseconds: 320);
  static const encender = Duration(milliseconds: 240);
  static const zonaLlena = Duration(milliseconds: 460);
  static const puntos = Duration(milliseconds: 420);
  static const temblor = Duration(milliseconds: 220);
  static const logo = Duration(milliseconds: 650);
  static const insignia = Duration(milliseconds: 480);
  static const irisApertura = Duration(milliseconds: 450);
  static const irisCierre = Duration(milliseconds: 1100);

  /// Si el sistema pide reducir movimiento: entonces nada se mueve.
  static bool quieto(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duracion], o cero si hay que reducir movimiento.
  static Duration duracion(BuildContext context, Duration duracion) =>
      quieto(context) ? Duration.zero : duracion;
}

/// Un resorte de goma: sale de 0, se pasa de 1 (la primera vez, más o menos por [exceso]) y vuelve
/// con [rebotes] oscilaciones que se apagan, terminando exacto en 1.
///
/// Es `1 - e^(-a·t)·cos(w·t)` con `w = (rebotes + ½)·π`: así `cos(w) = 0` y en t = 1 da
/// justo 1. `a` sale de pedir que el primer exceso (en `w·t = π`) sea [exceso].
class CurvaDeGoma extends Curve {
  final double exceso;
  final int rebotes;

  const CurvaDeGoma({this.exceso = 0.3, this.rebotes = 2})
    : assert(exceso > 0 && exceso < 1),
      assert(rebotes >= 0);

  double get _w => (rebotes + 0.5) * math.pi;
  double get _a => -(_w / math.pi) * math.log(exceso);

  @override
  double transformInternal(double t) => 1 - math.exp(-_a * t) * math.cos(_w * t);
}

/// La goma de siempre: se pasa un 30 % y vuelve con dos oscilaciones.
const curvaDeGoma = CurvaDeGoma();

/// Antes de arrancar, retrocede un poco: la pieza se agacha antes de saltar.
const curvaDeAnticipacion = Curves.easeInBack;

/// [curva], pero escalonada a 12 cuadros por segundo ("animar en dos"), para una
/// animación que dura [duracion]. Para lo decorativo: el movimiento de las piezas va
/// suave.
class EnDos extends Curve {
  final Curve curva;
  final Duration duracion;

  const EnDos(this.curva, this.duracion);

  /// Cuántos cuadros de 1/12 s caben en la animación (al menos uno).
  int get cuadros => math.max(1, (duracion.inMilliseconds * 12 / 1000).round());

  /// Cada cuadro toma el valor del medio de su tramo: así el primero ya se ve (no se
  /// queda en 0) y el último no termina antes de tiempo.
  @override
  double transformInternal(double t) {
    final escalon = ((t * cuadros).floor() + 0.5) / cuadros;
    return curva.transform(escalon.clamp(0.0, 1.0));
  }
}

/// La pieza aplastada o estirada, desde abajo, como si chocara con la mesa. Con
/// [aplastado] positivo queda más ancha y más baja; negativo, más alta y angosta (en el
/// aire). Cero, como es.
class AplastarYEstirar extends StatelessWidget {
  final double aplastado;
  final Alignment alineacion;
  final Widget child;

  const AplastarYEstirar({
    super.key,
    required this.aplastado,
    this.alineacion = Alignment.bottomCenter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (aplastado == 0) return child;
    return Transform(
      alignment: alineacion,
      transform: Matrix4.diagonal3Values(1 + aplastado * 0.8, 1 - aplastado, 1),
      child: child,
    );
  }
}

/// El "¡puf!" de polvo: cinco nubecitas de cartón con borde de tinta que salen de
/// [centro] hacia afuera, crecen y se achican hasta desaparecer. [progreso] va de 0 a 1.
class NubesDePolvo extends CustomPainter {
  final double progreso;
  final Offset centro;
  final double alcance;

  const NubesDePolvo({required this.progreso, required this.centro, required this.alcance});

  @override
  void paint(Canvas canvas, Size size) {
    if (progreso <= 0 || progreso >= 1) return;
    // Sale rápido y se frena; crece hasta la mitad y después se achica.
    final salida = Curves.easeOut.transform(progreso);
    final tamano = math.sin(progreso * math.pi);
    final relleno = Paint()..color = Paleta.cartonClaro;
    final borde = Paint()
      ..color = Paleta.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 5; i++) {
      final angulo = -math.pi / 2 + i * 2 * math.pi / 5;
      final punto = centro + Offset.fromDirection(angulo, alcance * (0.55 + 0.45 * salida));
      final radio = alcance * 0.28 * tamano;
      if (radio < 0.5) continue;
      canvas.drawCircle(punto, radio, relleno);
      canvas.drawCircle(punto, radio, borde);
    }
  }

  @override
  bool shouldRepaint(NubesDePolvo antes) =>
      progreso != antes.progreso || centro != antes.centro || alcance != antes.alcance;
}

/// Las rayitas de brillo del "¡ding!": ocho trazos de tinta alrededor de [centro], que
/// salen hacia afuera y se acortan hasta desaparecer. [progreso] va de 0 a 1.
class RayitasDeBrillo extends CustomPainter {
  final double progreso;
  final Offset centro;
  final double radio;

  const RayitasDeBrillo({required this.progreso, required this.centro, required this.radio});

  @override
  void paint(Canvas canvas, Size size) {
    if (progreso <= 0 || progreso >= 1) return;
    final pintura = Paint()
      ..color = Paleta.tinta
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final adentro = radio * (1.05 + 0.35 * progreso);
    final largo = radio * 0.35 * (1 - progreso);
    for (var i = 0; i < 8; i++) {
      final angulo = i * math.pi / 4 + math.pi / 8;
      final desde = centro + Offset.fromDirection(angulo, adentro);
      final hasta = centro + Offset.fromDirection(angulo, adentro + largo);
      canvas.drawLine(desde, hasta, pintura);
    }
  }

  @override
  bool shouldRepaint(RayitasDeBrillo antes) =>
      progreso != antes.progreso || centro != antes.centro || radio != antes.radio;
}

/// Tiembla un instante cada vez que cambia [disparador] (si está [activa]): gira de un
/// lado al otro, cada vez menos, como algo nervioso. Para la ficha del tiempo en los
/// últimos segundos.
class Sacudida extends StatefulWidget {
  final Object? disparador;
  final bool activa;
  final Widget child;

  const Sacudida({super.key, required this.disparador, this.activa = true, required this.child});

  @override
  State<Sacudida> createState() => _SacudidaState();
}

class _SacudidaState extends State<Sacudida> with SingleTickerProviderStateMixin {
  late final _animacion = AnimationController(vsync: this, duration: Cartoon.temblor, value: 1);

  @override
  void didUpdateWidget(Sacudida antes) {
    super.didUpdateWidget(antes);
    if (widget.activa && widget.disparador != antes.disparador && !Cartoon.quieto(context)) {
      _animacion.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animacion,
      builder: (context, hijo) {
        final t = _animacion.value;
        return Transform.rotate(
          key: const ValueKey('sacudida'),
          angle: t >= 1 ? 0 : 0.12 * math.sin(t * math.pi * 4) * (1 - t),
          child: hijo,
        );
      },
      child: widget.child,
    );
  }
}
