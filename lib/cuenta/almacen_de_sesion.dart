import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Una sesión iniciada: el usuario y el token que la identifica ante el
/// servidor.
class Sesion {
  final String usuario;
  final String token;

  const Sesion({required this.usuario, required this.token});
}

/// Dónde se guarda la sesión entre una vez que se abre la app y la otra.
abstract interface class AlmacenDeSesion {
  Future<Sesion?> leer();
  Future<void> guardar(Sesion sesion);
  Future<void> borrar();
}

/// Guarda la sesión cifrada: en Android, con una clave del Keystore del
/// sistema. Solo se guarda el usuario y el token, nunca la contraseña.
class AlmacenSeguro implements AlmacenDeSesion {
  static const _usuario = 'sesion.usuario';
  static const _token = 'sesion.token';

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
}
