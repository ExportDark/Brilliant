import 'package:bloc/bloc.dart';

import 'almacen_de_sesion.dart';
import 'cliente_cuentas.dart';
import 'direccion_del_servidor.dart';
import 'servidor_cubit.dart';
import 'sesion_event.dart';
import 'sesion_state.dart';

/// La sesión del jugador: crear la cuenta, iniciar y cerrar sesión, y borrar
/// la cuenta, hablando con el servidor de cuentas.
///
/// Vive arriba de toda la app: sin sesión no se puede jugar. Guarda la sesión
/// en el [AlmacenDeSesion], así que al volver a abrir la app no hay que
/// escribir otra vez la contraseña. El token no sale del bloc: las pantallas
/// solo ven el usuario.
///
/// Dónde está el servidor lo sabe el [ServidorCubit]. Si un pedido no llega,
/// el bloc le pide buscarlo en la red: si encuentra uno solo, se cambia a él
/// y el pedido se repite, sin que el jugador tenga que escribir la IP nueva.
class SesionBloc extends Bloc<SesionEvent, SesionState> {
  final ClienteCuentas _cuentas;
  final AlmacenDeSesion _almacen;
  final ServidorCubit _servidor;

  /// La sesión iniciada, con su token. Es `null` sin sesión.
  Sesion? _sesion;

  SesionBloc(this._cuentas, this._almacen, this._servidor)
      : super(const SesionState.revisando()) {
    // Un solo manejador, que atiende los pedidos de a uno y en el orden en
    // que llegan: así un segundo toque, o cerrar sesión mientras se revisa
    // la guardada, no se cruza con el pedido anterior.
    on<SesionEvent>(
      (event, emit) => switch (event) {
        SesionRevisada() => _alRevisar(emit),
        EntradaPedida() => _alEntrar(event, emit),
        CuentaPedida() => _alCrearCuenta(event, emit),
        SalidaPedida() => _alSalir(emit),
        BorradoPedido() => _alBorrar(event, emit),
        AvisosDescartados() => emit(state.sinAvisos()),
        SesionLatido() => _alLatir(emit),
      },
      transformer: (eventos, atender) => eventos.asyncExpand(atender),
    );
  }

  /// El aviso cuando la sesión de este aparato dejó de valer mientras se usaba.
  static const sesionCerrada =
      'Tu sesión se cerró: pasó mucho tiempo sin usarla, el servidor se reinició o se '
      'entró con tu cuenta en otro aparato. Vuelve a iniciar sesión.';

  /// El aviso al cerrar sesión cuando el servidor no se enteró: no se puede
  /// decir "Cerraste sesión." a secas, porque en el servidor sigue abierta.
  static const cierreSinServidor =
      'Cerraste sesión en este aparato. El servidor no contestó: se le avisará al '
      'volver a conectar, y si no, la sesión vence sola en 5 minutos.';

  /// La dirección del servidor con la que se está hablando.
  Uri get servidor => _cuentas.servidor;

  /// Cuando no se puede hablar con el servidor: dice con qué dirección se
  /// intentó, para que se note si es la de otra red.
  ErrorDeCuenta get _sinConexion => ErrorDeCuenta(
        generales: [
          'No se pudo conectar con el servidor (${textoDeDireccion(servidor)}). Revisa que '
              'esté encendido y que estés en la misma red, o cambia la dirección en '
              '"Servidor".',
        ],
      );

  Future<void> _alRevisar(Emitter<SesionState> emit) async {
    // Primero, la dirección que eligió el jugador la última vez.
    await _servidor.cargar();

    // Un cierre de sesión que no llegó la última vez, se vuelve a mandar.
    await _cerrarPendiente();

    final guardada = await _almacen.leer();
    if (guardada == null) return emit(const SesionState.sinSesion());

    try {
      await _conElServidor(() => _cuentas.quienSoy(guardada.token));
      _sesion = guardada;
      emit(SesionState.conSesion(guardada.usuario));
    } on SesionVencida {
      await _almacen.borrar();
      emit(const SesionState.sinSesion(aviso: 'Tu sesión venció. Vuelve a iniciar sesión.'));
    } on Exception {
      // El juego no necesita el servidor: sin red, o sin saber a cuál de los
      // de la red hablarle, se puede seguir jugando con la sesión guardada,
      // que se vuelve a revisar la próxima vez.
      _sesion = guardada;
      emit(SesionState.conSesion(guardada.usuario));
    }
  }

  Future<void> _alEntrar(EntradaPedida event, Emitter<SesionState> emit) async {
    emit(state.esperando());
    try {
      await _iniciar(event.usuario, event.contrasena);
      emit(SesionState.conSesion(event.usuario));
    } on ErrorDeCuenta catch (error) {
      emit(SesionState.sinSesion(error: error));
    } on SinConexion {
      emit(SesionState.sinSesion(error: _sinConexion));
    }
  }

  Future<void> _alCrearCuenta(CuentaPedida event, Emitter<SesionState> emit) async {
    emit(state.esperando());
    try {
      await _conElServidor(() => _cuentas.crearCuenta(
            usuario: event.usuario,
            contrasena: event.contrasena,
            repetida: event.repetida,
          ));
    } on ErrorDeCuenta catch (error) {
      return emit(SesionState.sinSesion(error: error));
    } on SinConexion {
      return emit(SesionState.sinSesion(error: _sinConexion));
    }

    try {
      await _iniciar(event.usuario, event.contrasena);
      emit(SesionState.conSesion(event.usuario));
    } on Exception {
      // La cuenta sí se creó: solo falló iniciar la sesión.
      emit(const SesionState.sinSesion(aviso: 'Tu cuenta se creó. Inicia sesión para jugar.'));
    }
  }

  Future<void> _alLatir(Emitter<SesionState> emit) async {
    final sesion = _sesion;
    if (sesion == null) return _cerrarPendiente();

    try {
      await _conElServidor(() => _cuentas.quienSoy(sesion.token));
    } on SesionVencida {
      // Venció, o se entró con la cuenta en otro aparato mientras este no la
      // usaba: la sesión de aquí ya no vale.
      await _olvidarSesion();
      emit(const SesionState.sinSesion(aviso: sesionCerrada));
    } on Exception {
      // Sin red, o sin saber a cuál servidor hablarle: se sigue jugando, y se
      // vuelve a avisar en el próximo latido.
    }
  }

  Future<void> _alSalir(Emitter<SesionState> emit) async {
    final sesion = _sesion;
    emit(state.esperando());
    final llego = sesion == null || await _cerrarEnElServidor(sesion);
    // Aunque el servidor no conteste, en este aparato la sesión se cierra
    // igual: el token se olvida. Si el servidor no se enteró, queda anotado para
    // volver a avisarle, y si no, la sesión vence sola.
    await _olvidarSesion();
    if (!llego) await _almacen.guardarPorCerrar(sesion);
    emit(SesionState.sinSesion(aviso: llego ? 'Cerraste sesión.' : cierreSinServidor));
  }

  /// Le avisa al servidor que [sesion] se cerró. Es verdadero si ya está
  /// cerrada allá: porque se cerró ahora, o porque ya no valía (venció).
  Future<bool> _cerrarEnElServidor(Sesion sesion) async {
    try {
      await _conElServidor(() => _cuentas.salir(sesion.token));
      return true;
    } on SesionVencida {
      return true;
    } on Exception {
      return false;
    }
  }

  /// Si quedó una sesión que se cerró aquí sin que el servidor se enterara,
  /// intenta cerrarla ahora. Si tampoco llega, sigue anotada.
  Future<void> _cerrarPendiente() async {
    final pendiente = await _almacen.leerPorCerrar();
    if (pendiente == null) return;
    if (await _cerrarEnElServidor(pendiente)) await _almacen.guardarPorCerrar(null);
  }

  Future<void> _alBorrar(BorradoPedido event, Emitter<SesionState> emit) async {
    final sesion = _sesion;
    if (sesion == null) return;

    emit(state.esperando());
    try {
      await _conElServidor(
        () => _cuentas.borrarCuenta(token: sesion.token, contrasena: event.contrasena),
      );
      await _olvidarSesion();
      emit(const SesionState.sinSesion(aviso: 'Tu cuenta se borró.'));
    } on ErrorDeCuenta catch (error) {
      emit(SesionState.conSesion(sesion.usuario, error: error));
    } on SinConexion {
      emit(SesionState.conSesion(sesion.usuario, error: _sinConexion));
    } on SesionVencida {
      await _olvidarSesion();
      emit(const SesionState.sinSesion(aviso: 'Tu sesión venció. Vuelve a iniciar sesión.'));
    }
  }

  /// Hace [pedido]; si el servidor no contesta, le pide al [ServidorCubit]
  /// buscarlo en la red, por si la PC o el aparato cambiaron de red. Si
  /// contesta uno solo, el cubit se cambia a él y el pedido se repite. Si
  /// contestan varios, no elige: el jugador elige en "Servidor".
  Future<T> _conElServidor<T>(Future<T> Function() pedido) async {
    final intentada = servidor;
    try {
      final respuesta = await pedido();
      _servidor.contesto();
      return respuesta;
    } on SinConexion {
      final encontrados = await _servidor.buscarOtro(intentada);
      if (encontrados.length > 1) {
        throw ErrorDeCuenta(generales: [
          'No se pudo conectar con el servidor (${textoDeDireccion(intentada)}), y en la red '
              'hay ${encontrados.length}. Elige uno en "Servidor".',
        ]);
      }
      if (encontrados.isEmpty) rethrow;
      return pedido();
    } on Exception {
      // Contestó, aunque fuera para rechazar el pedido: está ahí.
      _servidor.contesto();
      rethrow;
    }
  }

  Future<void> _iniciar(String usuario, String contrasena) async {
    // Antes de entrar, se cierra la sesión que quedó abierta en el servidor, si
    // la hay: si no, en este mismo celular el servidor diría que la cuenta ya
    // está en uso en otro aparato.
    await _cerrarPendiente();
    final token = await _conElServidor(
      () => _cuentas.entrar(usuario: usuario, contrasena: contrasena),
    );
    final sesion = Sesion(usuario: usuario, token: token);
    await _almacen.guardar(sesion);
    _sesion = sesion;
  }

  Future<void> _olvidarSesion() async {
    _sesion = null;
    await _almacen.borrar();
  }
}
