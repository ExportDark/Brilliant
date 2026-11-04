import 'package:bloc/bloc.dart';

import 'almacen_de_sesion.dart';
import 'buscador_de_servidores.dart';
import 'cliente_cuentas.dart';
import 'direccion_del_servidor.dart';
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
/// También guarda la dirección del servidor, por si la PC cambia de red. Si
/// el servidor no contesta, lo busca en la red con el [BuscadorDeServidores]:
/// si encuentra uno solo, se cambia a él y vuelve a intentar, sin que el
/// jugador tenga que escribir la IP nueva.
class SesionBloc extends Bloc<SesionEvent, SesionState> {
  final ClienteCuentas _cuentas;
  final AlmacenDeSesion _almacen;
  final BuscadorDeServidores _buscador;

  /// La dirección con la que se creó el cliente: a la que se vuelve al
  /// restablecer.
  final Uri servidorPorDefecto;

  /// La sesión iniciada, con su token. Es `null` sin sesión.
  Sesion? _sesion;

  SesionBloc(this._cuentas, this._almacen, {this._buscador = const SinBuscar()})
      : servidorPorDefecto = _cuentas.servidor,
        super(const SesionState.revisando()) {
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
        ServidorCambiado() => _alCambiarServidor(event, emit),
      },
      transformer: (eventos, atender) => eventos.asyncExpand(atender),
    );
  }

  /// La dirección del servidor con la que se está hablando.
  Uri get servidor => _cuentas.servidor;

  /// Si en esta plataforma se pueden buscar servidores en la red.
  bool get puedeBuscar => _buscador.puedeBuscar;

  /// Los servidores de la red que contestan. Si uno se anuncia con varias
  /// IPs, aparece una vez, con la primera que contesta.
  Future<List<ServidorEncontrado>> buscarServidores() async {
    final anunciados = await _buscador.buscar();
    final contestan = await Future.wait([
      for (final anunciado in anunciados) _contesta(anunciado.direccion),
    ]);

    final porNombre = <String, ServidorEncontrado>{};
    for (final (i, anunciado) in anunciados.indexed) {
      if (contestan[i]) porNombre.putIfAbsent(anunciado.nombre, () => anunciado);
    }
    return [...porNombre.values];
  }

  Future<bool> _contesta(Uri direccion) async {
    try {
      await _cuentas.probarConexion(en: direccion);
      return true;
    } on Exception {
      return false;
    }
  }

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
    final elegido = await _almacen.leerServidor();
    if (elegido != null) _cuentas.servidor = elegido;

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

  Future<void> _alCambiarServidor(ServidorCambiado event, Emitter<SesionState> emit) async {
    // Solo se cambia sin sesión: la sesión es de un servidor en particular.
    if (state.etapa != EtapaDeSesion.sinSesion) return;

    final direccion = event.direccion ?? servidorPorDefecto;
    _cuentas.servidor = direccion;
    await _almacen.guardarServidor(event.direccion);

    emit(state.esperando());
    try {
      await _cuentas.probarConexion();
      emit(SesionState.sinSesion(
        aviso: 'Conectado con el servidor en ${textoDeDireccion(direccion)}.',
      ));
    } on SinConexion {
      emit(SesionState.sinSesion(error: _sinConexion));
    } on ErrorDeCuenta catch (error) {
      emit(SesionState.sinSesion(error: error));
    }
  }

  /// Hace [pedido]; si el servidor no contesta, lo busca en la red, por si la
  /// PC cambió de IP. Si contesta uno solo, se cambia a él, lo recuerda y
  /// vuelve a intentar. Si contestan varios, no elige: el jugador elige en
  /// "Servidor".
  Future<T> _conElServidor<T>(Future<T> Function() pedido) async {
    try {
      return await pedido();
    } on SinConexion {
      if (!puedeBuscar) rethrow;
      final encontrados = await buscarServidores();
      if (encontrados.length > 1) {
        throw ErrorDeCuenta(generales: [
          'No se pudo conectar con el servidor (${textoDeDireccion(servidor)}), y en la red '
              'hay ${encontrados.length}. Elige uno en "Servidor".',
        ]);
      }
      if (encontrados.isEmpty) rethrow;

      final encontrado = encontrados.single.direccion;
      _cuentas.servidor = encontrado;
      await _almacen.guardarServidor(encontrado);
      return pedido();
    }
  }

  Future<void> _iniciar(String usuario, String contrasena) async {
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
