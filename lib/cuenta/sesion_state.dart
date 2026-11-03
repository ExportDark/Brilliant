import 'cliente_cuentas.dart';

/// En qué está la sesión.
enum EtapaDeSesion {
  /// Al abrir la app, mientras se revisa la sesión guardada.
  revisando,

  /// No hay sesión: hay que iniciarla o crear una cuenta.
  sinSesion,

  /// Hay sesión: se puede jugar.
  conSesion,
}

/// El estado de la sesión, que las pantallas de cuenta dibujan.
class SesionState {
  final EtapaDeSesion etapa;

  /// El usuario de la sesión, si hay una.
  final String? usuario;

  /// Hay un pedido al servidor en curso: los botones esperan.
  final bool ocupado;

  /// Lo que el servidor rechazó en el último pedido, si algo.
  final ErrorDeCuenta? error;

  /// Un aviso para el jugador, como "Tu cuenta se borró."
  final String? aviso;

  const SesionState({
    required this.etapa,
    this.usuario,
    this.ocupado = false,
    this.error,
    this.aviso,
  });

  const SesionState.revisando() : this(etapa: EtapaDeSesion.revisando);

  const SesionState.sinSesion({ErrorDeCuenta? error, String? aviso})
      : this(etapa: EtapaDeSesion.sinSesion, error: error, aviso: aviso);

  const SesionState.conSesion(String usuario, {ErrorDeCuenta? error})
      : this(etapa: EtapaDeSesion.conSesion, usuario: usuario, error: error);

  /// El mismo estado, esperando la respuesta de un pedido: sin el error ni el
  /// aviso anteriores.
  SesionState esperando() => SesionState(etapa: etapa, usuario: usuario, ocupado: true);

  /// El mismo estado, sin error ni aviso.
  SesionState sinAvisos() => SesionState(etapa: etapa, usuario: usuario, ocupado: ocupado);
}
