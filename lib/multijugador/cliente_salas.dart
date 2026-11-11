import '../cuenta/cliente_cuentas.dart';
import 'modelos.dart';

/// Hace un pedido con el token de la sesión, sin que el token salga de `SesionBloc`.
/// Si el servidor dice que la sesión ya no vale ([SesionVencida]), la sesión se cierra.
typedef ConToken = Future<T> Function<T>(Future<T> Function(String token) pedido);

/// Habla con las salas del servidor (`/salas/`, ver `Brilliant-servidor/README.md`).
///
/// Es una interfaz para que los tests de las pantallas y del [SalaBloc] usen una sala
/// falsa; [ClienteSalasHttp] es la de verdad. Todos los métodos devuelven la sala como la
/// ve quien pidió, y lanzan [ErrorDeSala] si el servidor rechaza el pedido,
/// [SinConexion] si no se puede hablar con él y [SesionVencida] si la sesión ya no vale.
abstract interface class ClienteSalas {
  Future<VistaDeSala> crear();
  Future<VistaDeSala> unirse(String codigo);
  Future<VistaDeSala> elegirMapa(String codigo, int nivel);
  Future<VistaDeSala> empezar(String codigo);

  /// Reparte los números iniciales: casilla -> número del 1 al 6.
  Future<VistaDeSala> preparar(String codigo, Map<String, int> valores);

  Future<VistaDeSala> jugar(
    String codigo, {
    required int ronda,
    required int dadoAncla,
    required String casilla,
  });

  Future<VistaDeSala> pasar(String codigo, {required int ronda});

  /// Salirse de la sala. En la partida devuelve la sala (con el resultado, si terminó);
  /// al salir del lobby, quien sale ya no está en ella y devuelve `null`.
  Future<VistaDeSala?> rendirse(String codigo);

  /// El estado de la sala, o `null` si no cambió desde [version]. Preguntar cuenta como
  /// estar conectado: la app lo hace cada segundo.
  Future<VistaDeSala?> estado(String codigo, {int? version});
}

class ClienteSalasHttp implements ClienteSalas {
  final ClienteCuentas _cuentas;
  final ConToken _conToken;

  ClienteSalasHttp(this._cuentas, this._conToken);

  @override
  Future<VistaDeSala> crear() => _pedir('POST', 'salas/');

  @override
  Future<VistaDeSala> unirse(String codigo) => _pedir('POST', '${_sala(codigo)}unirse/');

  @override
  Future<VistaDeSala> elegirMapa(String codigo, int nivel) =>
      _pedir('POST', '${_sala(codigo)}mapa/', cuerpo: {'nivel': nivel});

  @override
  Future<VistaDeSala> empezar(String codigo) => _pedir('POST', '${_sala(codigo)}empezar/');

  @override
  Future<VistaDeSala> preparar(String codigo, Map<String, int> valores) =>
      _pedir('POST', '${_sala(codigo)}preparacion/', cuerpo: {'valores': valores});

  @override
  Future<VistaDeSala> jugar(
    String codigo, {
    required int ronda,
    required int dadoAncla,
    required String casilla,
  }) =>
      _pedir(
        'POST',
        '${_sala(codigo)}jugada/',
        cuerpo: {'ronda': ronda, 'dado_ancla': dadoAncla, 'casilla': casilla},
      );

  @override
  Future<VistaDeSala> pasar(String codigo, {required int ronda}) =>
      _pedir('POST', '${_sala(codigo)}jugada/', cuerpo: {'ronda': ronda, 'pasar': true});

  @override
  Future<VistaDeSala?> rendirse(String codigo) {
    return _conToken((token) async {
      final (:estado, :datos) = await _cuentas.enviar(
        'POST',
        '${_sala(codigo)}rendirse/',
        token: token,
        reintentar: false,
      );
      if (estado == 204) return null;
      return _vista(estado, datos);
    });
  }

  @override
  Future<VistaDeSala?> estado(String codigo, {int? version}) {
    final consulta = version == null ? '' : '?version=$version';
    return _conToken((token) async {
      // Se reintenta: preguntar no cambia nada, y el servidor cierra las conexiones
      // inactivas.
      final (:estado, :datos) = await _cuentas.enviar(
        'GET',
        '${_sala(codigo)}$consulta',
        token: token,
      );
      if (estado == 304) return null;
      return _vista(estado, datos);
    });
  }

  /// La ruta de una sala, con el código tal cual lo escribió el jugador.
  static String _sala(String codigo) => 'salas/${Uri.encodeComponent(codigo.trim())}/';

  Future<VistaDeSala> _pedir(String metodo, String ruta, {Map<String, Object?>? cuerpo}) {
    return _conToken((token) async {
      // Crear, unirse, jugar... no se reintentan solos: el pedido pudo haber llegado.
      final (:estado, :datos) = await _cuentas.enviar(
        metodo,
        ruta,
        token: token,
        cuerpo: cuerpo,
        reintentar: false,
      );
      return _vista(estado, datos);
    });
  }

  static VistaDeSala _vista(int estado, Map<String, dynamic> datos) {
    if (estado == 401) throw const SesionVencida();
    if (estado >= 200 && estado < 300) return VistaDeSala.desdeJson(datos);
    if (estado >= 500) {
      throw ErrorDeSala(
        codigo: 'error_del_servidor',
        mensaje: 'El servidor tuvo un problema. Intenta de nuevo.',
        estadoHttp: estado,
      );
    }
    throw ErrorDeSala(
      codigo: datos['codigo'] as String? ?? 'desconocido',
      mensaje: datos['detail'] as String? ?? 'El servidor rechazó el pedido.',
      estadoHttp: estado,
      motivo: datos['motivo'] as String?,
    );
  }
}
