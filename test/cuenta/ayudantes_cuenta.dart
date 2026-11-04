// Ayudantes compartidos por los tests de cuentas. No termina en `_test.dart`,
// así que `flutter test` no lo corre: solo lo importan los tests.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brilliant/cuenta/almacen_de_sesion.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';

/// Una contraseña que el servidor acepta.
const contrasenaDePrueba = 'gema-brillante-73';

/// Un almacén de sesión en memoria, en lugar del cifrado del aparato.
class AlmacenEnMemoria implements AlmacenDeSesion {
  Sesion? sesion;

  /// La dirección del servidor que eligió el jugador, si eligió una.
  Uri? servidor;

  AlmacenEnMemoria([this.sesion]);

  @override
  Future<Sesion?> leer() async => sesion;

  @override
  Future<void> guardar(Sesion sesion) async => this.sesion = sesion;

  @override
  Future<void> borrar() async => sesion = null;

  @override
  Future<Uri?> leerServidor() async => servidor;

  @override
  Future<void> guardarServidor(Uri? servidor) async => this.servidor = servidor;
}

/// Un buscador de servidores que "encuentra" los [anunciados], como si se
/// anunciaran en la red.
class BuscadorFalso implements BuscadorDeServidores {
  /// Los que se anuncian en la red.
  final List<ServidorEncontrado> anunciados;

  /// Cuánto tarda cada búsqueda.
  final Duration espera;

  /// Cuántas veces se buscó.
  var busquedas = 0;

  BuscadorFalso([List<ServidorEncontrado>? anunciados, this.espera = Duration.zero])
      : anunciados = anunciados ?? [];

  @override
  bool get puedeBuscar => true;

  @override
  Future<List<ServidorEncontrado>> buscar() async {
    busquedas++;
    await Future<void>.delayed(espera);
    return [...anunciados];
  }
}

/// Un servidor de "Brilliant en [pc]" anunciado en [ip].
ServidorEncontrado anunciado(String ip, {String pc = 'ORION'}) => ServidorEncontrado(
      nombre: 'Brilliant en $pc',
      direccion: Uri.parse('https://$ip:8443/'),
    );

/// Un servidor de cuentas en memoria, que contesta como el de verdad: las
/// mismas rutas, los mismos códigos y los mismos mensajes en español. Sirve
/// para probar la app sin levantar el servidor.
///
/// Solo contesta en su [direccion], como el de verdad solo está en la IP de
/// la PC: un pedido a otra dirección no llega.
class ServidorFalso {
  /// Dónde contesta. Cambiarla es como si la PC cambiara de red.
  var direccion = 'servidor.test';

  /// Otras direcciones donde también contesta: como otra PC con su servidor
  /// en la misma red.
  final otrasDirecciones = <String>{};

  /// Usuario → contraseña.
  final cuentas = <String, String>{};

  /// Token → usuario.
  final sesiones = <String, String>{};

  /// Los pedidos que llegaron, en orden.
  final pedidos = <http.Request>[];

  /// Si está apagado, ningún pedido llega.
  var apagado = false;

  var _siguienteToken = 0;

  /// Una cuenta [usuario] ya creada, con una sesión iniciada.
  Sesion sesionIniciada(String usuario, {String contrasena = contrasenaDePrueba}) {
    cuentas[usuario] = contrasena;
    final token = _nuevoToken();
    sesiones[token] = usuario;
    return Sesion(usuario: usuario, token: token);
  }

  /// El cliente HTTP que habla con este servidor.
  late final http.Client clienteHttp = MockClient(_atender);

  /// Un [ClienteCuentas] que habla con este servidor, en la dirección que
  /// tiene ahora.
  ClienteCuentas cliente() => ClienteCuentas(clienteHttp, Uri.parse('https://$direccion:8443/'));

  String _nuevoToken() => 'token-${_siguienteToken++}'.padRight(64, 'x');

  Future<http.Response> _atender(http.Request pedido) async {
    if (apagado) throw http.ClientException('El servidor está apagado', pedido.url);
    if (pedido.url.host != direccion && !otrasDirecciones.contains(pedido.url.host)) {
      throw http.ClientException('Ahí no hay ningún servidor', pedido.url);
    }
    pedidos.add(pedido);

    final datos = pedido.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(pedido.body) as Map<String, dynamic>;
    final usuarioDelToken = sesiones[pedido.headers['Authorization']?.replaceFirst('Token ', '')];
    final ruta = '${pedido.method} ${pedido.url.path}';

    switch (ruta) {
      case 'POST /auth/users/':
        return _crearCuenta(datos);
      case 'POST /auth/token/login/':
        final usuario = datos['username'] as String?;
        if (usuario == null || cuentas[usuario] != datos['password']) {
          return _json(400, {
            'non_field_errors': ['No puede iniciar sesión con las credenciales proporcionadas.'],
          });
        }
        final token = _nuevoToken();
        sesiones[token] = usuario;
        return _json(200, {'token': token, 'expiry': '2026-11-09T00:00:00Z'});
      case 'GET /auth/users/me/' when usuarioDelToken != null:
        return _json(200, {'username': usuarioDelToken, 'id': 1, 'email': ''});
      case 'POST /auth/token/logout/' when usuarioDelToken != null:
        sesiones.removeWhere((token, _) => pedido.headers['Authorization'] == 'Token $token');
        return http.Response('', 204);
      case 'DELETE /auth/users/me/' when usuarioDelToken != null:
        if (datos['current_password'] != cuentas[usuarioDelToken]) {
          return _json(400, {
            'current_password': ['Contraseña inválida.'],
          });
        }
        cuentas.remove(usuarioDelToken);
        sesiones.removeWhere((_, usuario) => usuario == usuarioDelToken);
        return http.Response('', 204);
      case 'GET /auth/users/me/' || 'POST /auth/token/logout/' || 'DELETE /auth/users/me/':
        return _json(401, {'detail': 'Las credenciales de autenticación no se proveyeron.'});
    }
    return _json(404, {'detail': 'No encontrado.'});
  }

  http.Response _crearCuenta(Map<String, dynamic> datos) {
    final usuario = datos['username'] as String? ?? '';
    final contrasena = datos['password'] as String? ?? '';
    if (cuentas.containsKey(usuario)) {
      return _json(400, {
        'username': ['Ya existe un usuario con este nombre.'],
      });
    }
    if (contrasena.length < 8) {
      return _json(400, {
        'password': [
          'Esta contraseña es demasiado corta. Debe contener al menos 8 caracteres.',
        ],
      });
    }
    if (contrasena != datos['re_password']) {
      return _json(400, {
        'non_field_errors': ['El contenido de los dos campos de contraseña no coincide.'],
      });
    }
    cuentas[usuario] = contrasena;
    return _json(201, {'username': usuario, 'id': cuentas.length, 'email': ''});
  }

  static http.Response _json(int estado, Map<String, dynamic> cuerpo) => http.Response.bytes(
        utf8.encode(jsonEncode(cuerpo)),
        estado,
        headers: {'content-type': 'application/json'},
      );
}
