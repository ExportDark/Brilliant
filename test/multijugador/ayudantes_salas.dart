// Ayudantes compartidos por los tests del multijugador. No termina en `_test.dart`, así
// que `flutter test` no lo corre: solo lo importan los tests.

import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';

/// El JSON de una sala, como lo manda el servidor (`GET /salas/<código>/`). Los
/// parámetros son lo que suele variar en un test; el resto trae valores razonables.
Map<String, dynamic> vistaJson({
  String codigo = 'K7M4QX',
  int version = 1,
  String estado = 'esperando',
  int nivel = 2,
  String anfitrion = 'ana',
  int ronda = 0,
  List<int>? dados,
  double? segundosRestantes,
  String yo = 'ana',
  String miEstado = 'activo',
  bool preparado = false,
  String accion = 'pendiente',
  Map<String, int> tablero = const {},
  List<Map<String, dynamic>> jugadas = const [],
  bool puedePasar = false,
  List<Map<String, dynamic>>? jugadores,
  List<Map<String, dynamic>>? zonas,
  Map<String, dynamic>? resultado,
}) {
  return {
    'codigo': codigo,
    'version': version,
    'estado': estado,
    'nivel': nivel,
    'anfitrion': anfitrion,
    'ronda': ronda,
    'dados': dados,
    'segundos_restantes': segundosRestantes,
    'yo': {
      'usuario': yo,
      'estado': miEstado,
      'preparado': preparado,
      'accion': accion,
      'tablero': tablero,
      'iniciales': ['E1', 'A3', 'C4', 'F5', 'B6', 'E7'],
      'jugadas': jugadas,
      'puede_pasar': puedePasar,
    },
    'jugadores': jugadores ?? [jugadorJson('ana', anfitrion: true), jugadorJson('beto')],
    'zonas': zonas ?? [zonaJson(id: 10, tipo: 'gris', color: 'gris', casillas: ['D1', 'D7'])],
    'resultado': resultado,
  };
}

Map<String, dynamic> jugadorJson(
  String usuario, {
  bool anfitrion = false,
  String estado = 'activo',
  bool listo = false,
  int puntos = 0,
  int primeros = 0,
  List<int> zonas = const [],
}) {
  return {
    'usuario': usuario,
    'estado': estado,
    'anfitrion': anfitrion,
    'listo': listo,
    'puntos': puntos,
    'primeros': primeros,
    'zonas': zonas,
  };
}

Map<String, dynamic> zonaJson({
  int id = 1,
  String tipo = 'verde',
  String color = 'verde',
  List<String> casillas = const ['A1', 'B1'],
  List<Map<String, dynamic>> puestos = const [],
  bool agotada = false,
  int puntosSiguiente = 3,
  List<int>? puntosPorPuesto,
}) {
  return {
    'id': id,
    'tipo': tipo,
    'color': color,
    'casillas': casillas,
    'puestos': puestos,
    'agotada': agotada,
    'puntos_siguiente': puntosSiguiente,
    'puntos_por_puesto': ?puntosPorPuesto,
  };
}

VistaDeSala vistaDePrueba({
  String codigo = 'K7M4QX',
  int version = 1,
  String estado = 'esperando',
  int nivel = 2,
  String yo = 'ana',
  String anfitrion = 'ana',
  int ronda = 0,
  List<int>? dados,
  String miEstado = 'activo',
  bool preparado = false,
  String accion = 'pendiente',
  Map<String, int> tablero = const {},
  List<Map<String, dynamic>> jugadas = const [],
  bool puedePasar = false,
  List<Map<String, dynamic>>? jugadores,
  List<Map<String, dynamic>>? zonas,
  Map<String, dynamic>? resultado,
  double? segundosRestantes,
}) {
  return VistaDeSala.desdeJson(vistaJson(
    puedePasar: puedePasar,
    codigo: codigo,
    version: version,
    estado: estado,
    nivel: nivel,
    yo: yo,
    anfitrion: anfitrion,
    ronda: ronda,
    dados: dados,
    miEstado: miEstado,
    preparado: preparado,
    accion: accion,
    tablero: tablero,
    jugadas: jugadas,
    jugadores: jugadores,
    zonas: zonas,
    resultado: resultado,
    segundosRestantes: segundosRestantes,
  ));
}

/// Una partida en la ronda 1, con los dados (1, 3) y todo listo para anotar un 3 en D1.
VistaDeSala partidaEnJuego({
  int version = 5,
  String yo = 'ana',
  String accion = 'pendiente',
  Map<String, int> tablero = const {'E1': 1, 'A3': 3, 'C4': 4, 'F5': 5, 'B6': 6, 'E7': 2},
  List<Map<String, dynamic>> jugadas = const [
    {'ancla': 1, 'valor': 3, 'casillas': ['D1', 'E2', 'F1']},
    {'ancla': 3, 'valor': 1, 'casillas': ['A2', 'A4', 'B3']},
  ],
}) {
  return vistaDePrueba(
    version: version,
    estado: 'jugando',
    yo: yo,
    ronda: 1,
    dados: const [1, 3],
    segundosRestantes: 60,
    tablero: tablero,
    accion: accion,
    jugadas: jugadas,
  );
}

/// Un cliente de salas falso: contesta lo que el test dejó en [vista], y anota cada
/// llamada en [llamadas]. Sirve para probar el bloc y las pantallas sin servidor.
class SalasFalsas implements ClienteSalas {
  /// Lo que el servidor contesta ahora.
  VistaDeSala? vista;

  /// Lo que contesta [rendirse]; `null` es salir del lobby.
  VistaDeSala? alRendirse;

  /// Cada pedido que llegó, en orden: `crear`, `unirse K7M4QX`, `jugar 1 D1`...
  final llamadas = <String>[];

  /// Si está apagado, todo da [SinConexion].
  bool sinConexion = false;

  /// Si no es nulo, todo da [SesionVencida].
  bool sesionVencida = false;

  /// El error que da el próximo pedido (una sola vez), o `null`.
  ErrorDeSala? errorEnElProximo;

  /// Cada pedido de estado se queda esperando a que el test lo suelte, si no es nulo.
  Future<void>? esperaAntesDeContestar;

  /// Se llama después de anotar cada pedido que cambia algo, para que el test mueva
  /// [vista] como lo haría el servidor.
  void Function(String llamada)? alActuar;

  Future<VistaDeSala> _contestar(String llamada) async {
    llamadas.add(llamada);
    _fallarSiToca();
    alActuar?.call(llamada);
    return vista!;
  }

  void _fallarSiToca() {
    if (sinConexion) throw const SinConexion();
    if (sesionVencida) throw const SesionVencida();
    final error = errorEnElProximo;
    if (error != null) {
      errorEnElProximo = null;
      throw error;
    }
  }

  @override
  Future<VistaDeSala> crear() => _contestar('crear');

  @override
  Future<VistaDeSala> unirse(String codigo) => _contestar('unirse $codigo');

  @override
  Future<VistaDeSala> elegirMapa(String codigo, int nivel) => _contestar('mapa $nivel');

  @override
  Future<VistaDeSala> empezar(String codigo) => _contestar('empezar');

  @override
  Future<VistaDeSala> preparar(String codigo, Map<String, int> valores) =>
      _contestar('preparar ${valores.length}');

  @override
  Future<VistaDeSala> jugar(
    String codigo, {
    required int ronda,
    required int dadoAncla,
    required String casilla,
  }) =>
      _contestar('jugar $ronda $dadoAncla $casilla');

  @override
  Future<VistaDeSala> pasar(String codigo, {required int ronda}) => _contestar('pasar $ronda');

  @override
  Future<VistaDeSala?> rendirse(String codigo) async {
    llamadas.add('rendirse');
    _fallarSiToca();
    alActuar?.call('rendirse');
    return alRendirse;
  }

  @override
  Future<VistaDeSala?> estado(String codigo, {int? version}) async {
    llamadas.add('estado ${version ?? ''}'.trim());
    final espera = esperaAntesDeContestar;
    if (espera != null) await espera;
    _fallarSiToca();
    final actual = vista!;
    return version == actual.version ? null : actual;
  }

  /// Cuántas veces se preguntó el estado.
  int get preguntas => llamadas.where((l) => l.startsWith('estado')).length;
}

/// Presta un token fijo, como `SesionBloc.conToken` con una sesión iniciada.
Future<T> conTokenDePrueba<T>(Future<T> Function(String token) pedido) => pedido('token-de-prueba');

/// Un [ConToken] que solo cuenta cuántas veces se usó el token.
class ConTokenQueCuenta {
  var usos = 0;

  Future<T> llamar<T>(Future<T> Function(String token) pedido) {
    usos++;
    return pedido('token-de-prueba');
  }
}
