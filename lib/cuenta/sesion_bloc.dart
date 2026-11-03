import 'package:bloc/bloc.dart';

import 'almacen_de_sesion.dart';
import 'cliente_cuentas.dart';
import 'sesion_event.dart';
import 'sesion_state.dart';

/// Cuando no se puede hablar con el servidor.
const _sinConexion = ErrorDeCuenta(
  generales: [
    'No se pudo conectar con el servidor. Revisa que esté encendido y que estés en la '
        'misma red.',
  ],
);

/// La sesión del jugador: crear la cuenta, iniciar y cerrar sesión, y borrar
/// la cuenta, hablando con el servidor de cuentas.
///
/// Vive arriba de toda la app: sin sesión no se puede jugar. Guarda la sesión
/// en el [AlmacenDeSesion], así que al volver a abrir la app no hay que
/// escribir otra vez la contraseña. El token no sale del bloc: las pantallas
/// solo ven el usuario.
class SesionBloc extends Bloc<SesionEvent, SesionState> {
  final ClienteCuentas _cuentas;
  final AlmacenDeSesion _almacen;

  /// La sesión iniciada, con su token. Es `null` sin sesión.
  Sesion? _sesion;

  SesionBloc(this._cuentas, this._almacen) : super(const SesionState.revisando()) {
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
      },
      transformer: (eventos, atender) => eventos.asyncExpand(atender),
    );
  }

  Future<void> _alRevisar(Emitter<SesionState> emit) async {
    final guardada = await _almacen.leer();
    if (guardada == null) return emit(const SesionState.sinSesion());

    try {
      await _cuentas.quienSoy(guardada.token);
      _sesion = guardada;
      emit(SesionState.conSesion(guardada.usuario));
    } on SesionVencida {
      await _almacen.borrar();
      emit(const SesionState.sinSesion(aviso: 'Tu sesión venció. Vuelve a iniciar sesión.'));
    } on SinConexion {
      // El juego no necesita el servidor: sin red se puede seguir jugando con
      // la sesión guardada, que se vuelve a revisar la próxima vez.
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
      emit(const SesionState.sinSesion(error: _sinConexion));
    }
  }

  Future<void> _alCrearCuenta(CuentaPedida event, Emitter<SesionState> emit) async {
    emit(state.esperando());
    try {
      await _cuentas.crearCuenta(
        usuario: event.usuario,
        contrasena: event.contrasena,
        repetida: event.repetida,
      );
    } on ErrorDeCuenta catch (error) {
      return emit(SesionState.sinSesion(error: error));
    } on SinConexion {
      return emit(const SesionState.sinSesion(error: _sinConexion));
    }

    try {
      await _iniciar(event.usuario, event.contrasena);
      emit(SesionState.conSesion(event.usuario));
    } on Exception {
      // La cuenta sí se creó: solo falló iniciar la sesión.
      emit(const SesionState.sinSesion(aviso: 'Tu cuenta se creó. Inicia sesión para jugar.'));
    }
  }

  Future<void> _alSalir(Emitter<SesionState> emit) async {
    final sesion = _sesion;
    emit(state.esperando());
    if (sesion != null) {
      try {
        await _cuentas.salir(sesion.token);
      } on Exception {
        // Aunque el servidor no conteste, en este aparato la sesión se
        // cierra igual: el token se olvida y vence solo.
      }
    }
    await _olvidarSesion();
    emit(const SesionState.sinSesion(aviso: 'Cerraste sesión.'));
  }

  Future<void> _alBorrar(BorradoPedido event, Emitter<SesionState> emit) async {
    final sesion = _sesion;
    if (sesion == null) return;

    emit(state.esperando());
    try {
      await _cuentas.borrarCuenta(token: sesion.token, contrasena: event.contrasena);
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

  Future<void> _iniciar(String usuario, String contrasena) async {
    final token = await _cuentas.entrar(usuario: usuario, contrasena: contrasena);
    final sesion = Sesion(usuario: usuario, token: token);
    await _almacen.guardar(sesion);
    _sesion = sesion;
  }

  Future<void> _olvidarSesion() async {
    _sesion = null;
    await _almacen.borrar();
  }
}
