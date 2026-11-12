import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Una sesión iniciada: el usuario y el token que la identifica ante el
/// servidor.
class Sesion {
  final String usuario;
  final String token;

  const Sesion({required this.usuario, required this.token});
}

/// Dónde se guarda la sesión entre una vez que se abre la app y la otra, y
/// la dirección del servidor, si el jugador eligió una.
abstract interface class AlmacenDeSesion {
  Future<Sesion?> leer();
  Future<void> guardar(Sesion sesion);
  Future<void> borrar();

  /// Las sesiones que se cerraron en este aparato pero que el servidor todavía no
  /// sabe que se cerraron (el cierre de sesión no llegó). Vacía si no hay.
  Future<List<Sesion>> leerPorCerrar();

  /// Guarda las sesiones por cerrar en el servidor; vacía, ya no hay ninguna.
  Future<void> guardarPorCerrar(List<Sesion> sesiones);

  /// La dirección del servidor que eligió el jugador, o `null` si usa la de
  /// siempre.
  Future<Uri?> leerServidor();

  /// Guarda la dirección del servidor; con `null`, vuelve a la de siempre.
  Future<void> guardarServidor(Uri? servidor);

  /// El último usuario que inició sesión en este aparato, para escribirlo solo en
  /// "Iniciar sesión", o `null` si no hay. Nunca se guarda la contraseña.
  Future<String?> leerUltimoUsuario();

  /// Guarda el último usuario; con `null`, se olvida.
  Future<void> guardarUltimoUsuario(String? usuario);
}

/// Guarda la sesión cifrada: en Android, con una clave del Keystore del
/// sistema. Solo se guarda el usuario y el token, nunca la contraseña.
class AlmacenSeguro implements AlmacenDeSesion {
  static const _usuario = 'sesion.usuario';
  static const _token = 'sesion.token';
  // Antes se guardaba una sola sesión por cerrar, en estas dos claves; se leen una vez
  // para no perderla y pasan a la lista.
  static const _usuarioPorCerrar = 'porcerrar.usuario';
  static const _tokenPorCerrar = 'porcerrar.token';
  static const _listaPorCerrar = 'porcerrar.lista';
  static const _servidor = 'servidor.direccion';
  static const _ultimoUsuario = 'ultimo.usuario';

  final FlutterSecureStorage _almacen;

  const AlmacenSeguro([this._almacen = const FlutterSecureStorage()]);

  @override
  Future<Sesion?> leer() async {
    final usuario = await _almacen.read(key: _usuario);
    final token = await _almacen.read(key: _token);
    if (usuario == null || token == null) return null;
    return Sesion(usuario: usuario, token: token);
  }

  @override
  Future<void> guardar(Sesion sesion) async {
    await _almacen.write(key: _usuario, value: sesion.usuario);
    await _almacen.write(key: _token, value: sesion.token);
  }

  @override
  Future<void> borrar() async {
    await _almacen.delete(key: _usuario);
    await _almacen.delete(key: _token);
  }

  @override
  Future<List<Sesion>> leerPorCerrar() async {
    final sesiones = <Sesion>[];
    final guardada = await _almacen.read(key: _listaPorCerrar);
    if (guardada != null) {
      try {
        for (final s in jsonDecode(guardada) as List<dynamic>) {
          final datos = s as Map<String, dynamic>;
          sesiones.add(Sesion(usuario: datos['usuario'] as String, token: datos['token'] as String));
        }
      } on Object {
        // Si se dañó, no hay nada que rescatar: esas sesiones vencen solas.
      }
    }
    final usuario = await _almacen.read(key: _usuarioPorCerrar);
    final token = await _almacen.read(key: _tokenPorCerrar);
    if (usuario != null && token != null) sesiones.add(Sesion(usuario: usuario, token: token));
    return sesiones;
  }

  @override
  Future<void> guardarPorCerrar(List<Sesion> sesiones) async {
    await _almacen.delete(key: _usuarioPorCerrar);
    await _almacen.delete(key: _tokenPorCerrar);
    if (sesiones.isEmpty) return _almacen.delete(key: _listaPorCerrar);
    await _almacen.write(
      key: _listaPorCerrar,
      value: jsonEncode([
        for (final s in sesiones) {'usuario': s.usuario, 'token': s.token},
      ]),
    );
  }

  @override
  Future<Uri?> leerServidor() async {
    final guardado = await _almacen.read(key: _servidor);
    return guardado == null ? null : Uri.tryParse(guardado);
  }

  @override
  Future<void> guardarServidor(Uri? servidor) async {
    if (servidor == null) return _almacen.delete(key: _servidor);
    await _almacen.write(key: _servidor, value: servidor.toString());
  }

  @override
  Future<String?> leerUltimoUsuario() => _almacen.read(key: _ultimoUsuario);

  @override
  Future<void> guardarUltimoUsuario(String? usuario) async {
    if (usuario == null) return _almacen.delete(key: _ultimoUsuario);
    await _almacen.write(key: _ultimoUsuario, value: usuario);
  }
}
