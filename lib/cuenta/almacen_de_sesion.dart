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

  /// La sesión que se cerró en este aparato pero que el servidor todavía no
  /// sabe que se cerró (el cierre de sesión no llegó), o `null` si no hay.
  Future<Sesion?> leerPorCerrar();

  /// Guarda la sesión por cerrar en el servidor; con `null`, ya no hay ninguna.
  Future<void> guardarPorCerrar(Sesion? sesion);

  /// La dirección del servidor que eligió el jugador, o `null` si usa la de
  /// siempre.
  Future<Uri?> leerServidor();

  /// Guarda la dirección del servidor; con `null`, vuelve a la de siempre.
  Future<void> guardarServidor(Uri? servidor);
}

/// Guarda la sesión cifrada: en Android, con una clave del Keystore del
/// sistema. Solo se guarda el usuario y el token, nunca la contraseña.
class AlmacenSeguro implements AlmacenDeSesion {
  static const _usuario = 'sesion.usuario';
  static const _token = 'sesion.token';
  static const _usuarioPorCerrar = 'porcerrar.usuario';
  static const _tokenPorCerrar = 'porcerrar.token';
  static const _servidor = 'servidor.direccion';

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
  Future<Sesion?> leerPorCerrar() async {
    final usuario = await _almacen.read(key: _usuarioPorCerrar);
    final token = await _almacen.read(key: _tokenPorCerrar);
    if (usuario == null || token == null) return null;
    return Sesion(usuario: usuario, token: token);
  }

  @override
  Future<void> guardarPorCerrar(Sesion? sesion) async {
    if (sesion == null) {
      await _almacen.delete(key: _usuarioPorCerrar);
      await _almacen.delete(key: _tokenPorCerrar);
      return;
    }
    await _almacen.write(key: _usuarioPorCerrar, value: sesion.usuario);
    await _almacen.write(key: _tokenPorCerrar, value: sesion.token);
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
}
