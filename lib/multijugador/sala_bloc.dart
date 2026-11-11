import 'dart:async';

import 'package:bloc/bloc.dart';

import '../cuenta/cliente_cuentas.dart';
import 'cliente_salas.dart';
import 'modelos.dart';
import 'sala_event.dart';
import 'sala_state.dart';

/// Lleva al jugador por el multijugador: crear o unirse a una sala, el lobby, la
/// preparación, las rondas y el resultado.
///
/// El servidor manda: este bloc no valida jugadas ni calcula puntos, solo manda los
/// pedidos y guarda la sala tal cual la devuelve el servidor. Cada [intervalo]
/// (un segundo) le pregunta cómo va; eso es también lo que le dice al servidor que este
/// jugador sigue conectado, y quien pasa 10 segundos sin preguntar queda fuera.
///
/// Por eso, si no hay respuesta, avisa antes de que pase: a los [segundosParaReconectar]
/// dice "reconectando" y a los [segundosParaPerder], que la conexión se perdió.
class SalaBloc extends Bloc<SalaEvent, SalaState> {
  static const segundosParaReconectar = 3;
  static const segundosParaPerder = 10;

  final ClienteSalas _cliente;
  final Duration? _intervalo;
  final DateTime Function() _ahora;

  Timer? _reloj;
  bool _preguntaEnCola = false;

  /// La última vez que el servidor contestó.
  late DateTime _ultimaRespuesta = _ahora();

  /// Con [intervalo] en `null` no se pregunta solo: los tests mandan [Preguntar].
  SalaBloc(
    this._cliente, {
    this._intervalo = const Duration(seconds: 1),
    DateTime Function()? ahora,
  })  : _ahora = ahora ?? DateTime.now,
        super(const SalaState()) {
    // Un solo manejador, de a uno: un toque mientras llega la respuesta del anterior no
    // se cruza con él.
    on<SalaEvent>(
      (event, emit) => switch (event) {
        SalaCreada() => _accion(emit, _cliente.crear),
        UnirseConCodigo() => _alUnirse(event, emit),
        MapaElegido() => _enSala(emit, (sala) => _cliente.elegirMapa(sala.codigo, event.nivel)),
        PartidaEmpezada() => _enSala(emit, (sala) => _cliente.empezar(sala.codigo)),
        PreparacionEnviada() =>
          _enSala(emit, (sala) => _cliente.preparar(sala.codigo, event.valores)),
        JugadaEnviada() => _enSala(
            emit,
            (sala) => _cliente.jugar(
              sala.codigo,
              ronda: sala.ronda,
              dadoAncla: event.dadoAncla,
              casilla: event.casilla,
            ),
          ),
        RondaPasada() => _enSala(emit, (sala) => _cliente.pasar(sala.codigo, ronda: sala.ronda)),
        Rendirse() => _alRendirse(emit),
        Preguntar() => _alPreguntar(emit),
        ErrorDescartado() => emit(state.copiaCon(error: () => null)),
      },
      transformer: (eventos, atender) => eventos.asyncExpand(atender),
    );
  }


  @override
  Future<void> close() {
    _reloj?.cancel();
    return super.close();
  }

  // ------------------------------------------------------------------ pedidos

  Future<void> _alUnirse(UnirseConCodigo event, Emitter<SalaState> emit) async {
    final codigo = event.codigo.trim().toUpperCase();
    if (codigo.isEmpty) {
      return emit(state.copiaCon(error: () => 'Escribe el código de la sala.'));
    }
    await _accion(emit, () => _cliente.unirse(codigo));
  }

  /// Un pedido que solo tiene sentido dentro de una sala: sin sala, no se hace nada.
  Future<void> _enSala(
    Emitter<SalaState> emit,
    Future<VistaDeSala> Function(VistaDeSala sala) pedido,
  ) async {
    final sala = state.vista;
    if (sala == null) return;
    await _accion(emit, () => pedido(sala));
  }

  /// Hace [pedido] y guarda la sala que devuelve. Si falla, guarda qué decirle al jugador.
  Future<void> _accion(Emitter<SalaState> emit, Future<VistaDeSala> Function() pedido) async {
    if (state.fin != FinDeSala.ninguno) return;
    emit(state.copiaCon(ocupado: true, error: () => null));
    try {
      final vista = await pedido();
      _recibir(vista, emit);
    } on ErrorDeSala catch (error) {
      await _alRechazar(error, emit);
    } on SinConexion {
      emit(state.copiaCon(
        ocupado: false,
        error: () => 'No se pudo conectar con el servidor. Intenta de nuevo.',
      ));
    } on SesionVencida {
      // La sesión se cierra sola (ver SesionBloc.conToken): aquí no queda nada que hacer.
      _pararDePreguntar();
      emit(state.copiaCon(ocupado: false, fin: FinDeSala.saliste));
    }
  }

  Future<void> _alRendirse(Emitter<SalaState> emit) async {
    if (state.vista == null || state.fin != FinDeSala.ninguno) return;
    emit(state.copiaCon(ocupado: true, error: () => null));
    try {
      final vista = await _cliente.rendirse(state.vista!.codigo);
      if (vista == null) {
        // Salió del lobby: ya no está en la sala.
        _pararDePreguntar();
        emit(state.copiaCon(ocupado: false, fin: FinDeSala.saliste));
      } else {
        _recibir(vista, emit);
      }
    } on ErrorDeSala catch (error) {
      await _alRechazar(error, emit);
    } on SinConexion {
      // Sin servidor no se puede avisar. Se deja de preguntar: en unos segundos el
      // servidor lo da por desconectado, que es lo mismo que rendirse.
      _pararDePreguntar();
      emit(state.copiaCon(ocupado: false, fin: FinDeSala.saliste));
    } on SesionVencida {
      _pararDePreguntar();
      emit(state.copiaCon(ocupado: false, fin: FinDeSala.saliste));
    }
  }

  /// Lo que el servidor rechazó. Algunos rechazos no son un error para el jugador.
  Future<void> _alRechazar(ErrorDeSala error, Emitter<SalaState> emit) async {
    switch (error.codigo) {
      case 'sala_no_existe' when state.vista != null:
        // La sala en la que se estaba ya no existe (el servidor se reinició).
        _pararDePreguntar();
        emit(state.copiaCon(ocupado: false, fin: FinDeSala.desaparecio, error: () => null));
      case 'no_eres_parte' when state.vista != null:
        _pararDePreguntar();
        emit(state.copiaCon(ocupado: false, fin: FinDeSala.saliste, error: () => null));
      case 'ya_jugaste':
        // Un doble toque: la primera jugada ya llegó. No hay nada que decir.
        emit(state.copiaCon(ocupado: false));
      default:
        emit(state.copiaCon(ocupado: false, error: () => _mensajeDe(error)));
    }
  }

  String _mensajeDe(ErrorDeSala error) {
    if (error.codigo == 'jugada_invalida') {
      return switch (error.motivo) {
        'ocupada' => 'Esa casilla ya tiene un número.',
        'sin_vecino' => 'Tiene que quedar pegada a una casilla con el número del dado ancla.',
        'regla_rota' => 'La regla de esa zona no permite ese número.',
        _ => error.mensaje,
      };
    }
    if (error.codigo == 'ronda_incorrecta') {
      return 'La ronda ya cambió. Mira la tirada nueva.';
    }
    return error.mensaje;
  }

  // ----------------------------------------------------------------- preguntar

  Future<void> _alPreguntar(Emitter<SalaState> emit) async {
    _preguntaEnCola = false;
    final vista = state.vista;
    if (vista == null || state.fin != FinDeSala.ninguno) return;

    try {
      final nueva = await _cliente.estado(vista.codigo, version: vista.version);
      _ultimaRespuesta = _ahora();
      emit(state.copiaCon(
        vista: nueva,
        conexion: Conexion.conectada,
        ocupado: state.ocupado,
      ));
      if (nueva?.estado == EstadoDeSala.terminada) _pararDePreguntar();
    } on SinConexion {
      final sinRespuesta = _ahora().difference(_ultimaRespuesta).inSeconds;
      final conexion = sinRespuesta >= segundosParaPerder
          ? Conexion.perdida
          : sinRespuesta >= segundosParaReconectar
              ? Conexion.reconectando
              : state.conexion;
      if (conexion != state.conexion) emit(state.copiaCon(conexion: conexion));
    } on ErrorDeSala catch (error) {
      await _alRechazar(error, emit);
    } on SesionVencida {
      _pararDePreguntar();
      emit(state.copiaCon(fin: FinDeSala.saliste));
    }
  }

  /// Guarda la sala que devolvió el servidor y, si es la primera vez, empieza a
  /// preguntar.
  void _recibir(VistaDeSala vista, Emitter<SalaState> emit) {
    final primera = state.vista == null;
    _ultimaRespuesta = _ahora();
    emit(state.copiaCon(
      vista: vista,
      ocupado: false,
      conexion: Conexion.conectada,
      error: () => null,
    ));
    if (vista.estado == EstadoDeSala.terminada) {
      _pararDePreguntar();
    } else if (primera) {
      _empezarAPreguntar();
    }
  }

  void _empezarAPreguntar() {
    final intervalo = _intervalo;
    if (intervalo == null) return;
    _reloj?.cancel();
    _reloj = Timer.periodic(intervalo, (_) {
      // Si todavía hay una pregunta esperando su turno, no se acumulan más.
      if (_preguntaEnCola || isClosed) return;
      _preguntaEnCola = true;
      add(const Preguntar());
    });
  }

  void _pararDePreguntar() {
    _reloj?.cancel();
    _reloj = null;
  }
}
