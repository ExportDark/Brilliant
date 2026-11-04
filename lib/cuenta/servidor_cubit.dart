import 'dart:async';

import 'package:bloc/bloc.dart';

import 'almacen_de_sesion.dart';
import 'buscador_de_servidores.dart';
import 'cliente_cuentas.dart';
import 'servidor_state.dart';

/// Sabe dónde está el servidor de cuentas y si contesta, para que la app lo
/// muestre ("Servidor disponible", "Sin servidor") y para que la sesión sepa a
/// quién hablarle.
///
/// La IP de la PC cambia con la red, y el celular también puede cambiar de
/// red. Por eso, cuando el servidor no contesta, lo busca en la red con el
/// [BuscadorDeServidores], y si contesta uno solo, se cambia a él. La app le
/// pide [revisar] al abrirse, al volver a primer plano y cuando cambia la red
/// del aparato.
///
/// Es un cubit y no un bloc con eventos porque la sesión necesita la respuesta
/// de [buscarOtro] para saber si puede repetir el pedido.
class ServidorCubit extends Cubit<ServidorState> {
  /// Cuánto se espera a que conteste al revisarlo: para saber si está no hace
  /// falta tanto como para un pedido de verdad.
  static const espera = Duration(seconds: 4);

  final ClienteCuentas _cuentas;
  final AlmacenDeSesion _almacen;
  final BuscadorDeServidores _buscador;

  /// Cada cuánto se vuelve a revisar mientras no hay servidor, para notar
  /// cuando se enciende. Sin él, solo se revisa cuando se pide.
  final Duration? _reintentarCada;

  /// La dirección con la que se creó el cliente: a la que se vuelve al
  /// restablecer.
  final Uri porDefecto;

  Timer? _reintento;

  /// Lo último que se pidió hacer: revisar, buscar y elegir van de a uno.
  Future<void> _cola = Future.value();

  /// Una revisión pedida que todavía no empezó: si se pide otra, es la misma.
  Future<void>? _revisionEnEspera;

  late final Future<void> _cargada = _cargarLaElegida();

  ServidorCubit(
    this._cuentas,
    this._almacen, {
    this._buscador = const SinBuscar(),
    this._reintentarCada,
  })  : porDefecto = _cuentas.servidor,
        super(ServidorState(direccion: _cuentas.servidor));

  /// Si en esta plataforma se pueden buscar servidores en la red.
  bool get puedeBuscar => _buscador.puedeBuscar;

  /// Espera a que se cargue la dirección que eligió el jugador la última vez.
  /// Se carga una sola vez, así que se puede esperar cuantas veces se quiera.
  Future<void> cargar() => _cargada;

  /// Revisa si el servidor contesta. Si no, lo busca en la red, y si contesta
  /// uno solo, se cambia a él y lo recuerda.
  Future<void> revisar() => _revisionEnEspera ??= _enOrden(() {
        // Ya empezó: una revisión que se pida desde ahora va aparte, porque
        // puede ser por algo que pasó mientras tanto, como un cambio de red.
        _revisionEnEspera = null;
        return _revisarAhora();
      });

  /// Para cuando un pedido de la sesión a [intentada] no llegó: busca el
  /// servidor en la red. Si contesta uno solo, se cambia a él. Devuelve los
  /// que contestaron, para que la sesión sepa si puede repetir el pedido.
  Future<List<ServidorEncontrado>> buscarOtro(Uri intentada) => _enOrden(() async {
        // Mientras tanto ya se cambió a otro que contesta: con ese basta.
        if (state.direccion != intentada && state.disponibilidad == Disponibilidad.disponible) {
          return [ServidorEncontrado(nombre: state.nombre ?? '', direccion: state.direccion)];
        }
        _emitir(state.con(disponibilidad: Disponibilidad.revisando));
        return _buscarYCambiar();
      });

  /// Usa la [direccion] que eligió el jugador (con `null`, la de partida), la
  /// recuerda y revisa si contesta. [nombre] es cómo se anuncia, si la eligió
  /// de los encontrados en la red.
  Future<void> elegir(Uri? direccion, {String? nombre}) => _enOrden(() async {
        await cargar();
        _cambiarA(direccion ?? porDefecto, nombre: nombre);
        await _almacen.guardarServidor(direccion);
        _emitir(state.con(
          disponibilidad: await _contesta(state.direccion)
              ? Disponibilidad.disponible
              : Disponibilidad.noDisponible,
        ));
      });

  /// La sesión avisa que el servidor contestó un pedido: está disponible.
  void contesto() {
    if (state.disponibilidad != Disponibilidad.disponible) {
      _emitir(state.con(disponibilidad: Disponibilidad.disponible));
    }
  }

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

  @override
  Future<void> close() {
    _reintento?.cancel();
    return super.close();
  }

  Future<void> _cargarLaElegida() async {
    final elegida = await _almacen.leerServidor();
    if (elegida == null) return;
    _cambiarA(elegida);
  }

  Future<void> _revisarAhora() async {
    await cargar();
    _emitir(state.con(disponibilidad: Disponibilidad.revisando));
    if (await _contesta(state.direccion)) {
      return _emitir(state.con(disponibilidad: Disponibilidad.disponible));
    }
    await _buscarYCambiar();
  }

  /// Busca en la red. Si contesta uno solo, se cambia a él y lo recuerda; si
  /// no, no hay servidor (con varios no se elige: cada uno tiene sus cuentas).
  Future<List<ServidorEncontrado>> _buscarYCambiar() async {
    final encontrados = await buscarServidores();
    if (encontrados.length == 1) {
      final encontrado = encontrados.single;
      _cambiarA(encontrado.direccion, nombre: encontrado.nombre);
      await _almacen.guardarServidor(encontrado.direccion);
      _emitir(state.con(disponibilidad: Disponibilidad.disponible));
    } else {
      _emitir(state.con(disponibilidad: Disponibilidad.noDisponible));
    }
    return encontrados;
  }

  void _cambiarA(Uri direccion, {String? nombre}) {
    _cuentas.servidor = direccion;
    _emitir(ServidorState(direccion: direccion, nombre: nombre));
  }

  Future<bool> _contesta(Uri direccion) async {
    try {
      await _cuentas.probarConexion(en: direccion, espera: espera);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Emite [nuevo], si el cubit sigue abierto y algo cambió. Mientras no hay
  /// servidor, deja programada otra revisión.
  void _emitir(ServidorState nuevo) {
    if (isClosed || nuevo == state) return;
    _reintento?.cancel();
    final cada = _reintentarCada;
    if (nuevo.disponibilidad == Disponibilidad.noDisponible && cada != null) {
      _reintento = Timer(cada, revisar);
    }
    emit(nuevo);
  }

  /// Hace [trabajo] después de lo que ya estaba en curso.
  Future<T> _enOrden<T>(Future<T> Function() trabajo) {
    final hecho = _cola.then((_) => trabajo());
    _cola = hecho.then<void>((_) {}, onError: (Object _) {});
    return hecho;
  }
}
