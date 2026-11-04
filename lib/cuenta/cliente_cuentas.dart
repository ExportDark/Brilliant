import 'dart:convert';

import 'package:http/http.dart' as http;

/// Lo que el servidor rechazó, con sus mensajes tal como los manda (en
/// español). [porCampo] tiene los de cada campo del formulario (`username`,
/// `password`, `re_password`, `current_password`); [generales], los que no
/// son de un campo, como "No puede iniciar sesión con las credenciales
/// proporcionadas."
class ErrorDeCuenta implements Exception {
  final Map<String, List<String>> porCampo;
  final List<String> generales;

  const ErrorDeCuenta({this.porCampo = const {}, this.generales = const []});

  /// Los mensajes de [campo], o `null` si no tiene.
  String? de(String campo) => porCampo[campo]?.join('\n');

  @override
  String toString() => 'ErrorDeCuenta($porCampo, $generales)';
}

/// El token ya no sirve: venció, se cerró la sesión o se borró la cuenta.
class SesionVencida implements Exception {
  const SesionVencida();
}

/// No se pudo hablar con el servidor: está apagado, no hay red, o su
/// certificado no es el de la autoridad de Brilliant.
class SinConexion implements Exception {
  const SinConexion();
}

/// Habla con el servidor de cuentas por HTTPS. Cada método hace un pedido a
/// la API (ver `servidor/README.md`) y convierte la respuesta en un valor o
/// en uno de los errores de arriba.
///
/// Recibe el [http.Client] para que los tests lo cambien por uno falso; en
/// la app es uno que solo confía en la autoridad local del servidor.
class ClienteCuentas {
  static const _espera = Duration(seconds: 10);

  final http.Client _http;

  /// La dirección del servidor. Se puede cambiar: si la PC cambia de red, el
  /// jugador escribe la nueva en la app.
  Uri servidor;

  ClienteCuentas(this._http, this.servidor);

  /// Crea la cuenta. La contraseña va dos veces: [repetida] es la que el
  /// jugador escribió para confirmarla.
  Future<void> crearCuenta({
    required String usuario,
    required String contrasena,
    required String repetida,
  }) async {
    await _pedir('POST', 'auth/users/', cuerpo: {
      'username': usuario,
      'password': contrasena,
      're_password': repetida,
    });
  }

  /// Inicia sesión y devuelve el token de la sesión nueva.
  Future<String> entrar({required String usuario, required String contrasena}) async {
    final respuesta = await _pedir('POST', 'auth/token/login/', cuerpo: {
      'username': usuario,
      'password': contrasena,
    });
    return respuesta['token'] as String;
  }

  /// El nombre de usuario de la sesión de [token]. Sirve para saber si un
  /// token guardado todavía vale.
  Future<String> quienSoy(String token) async {
    final respuesta = await _pedir('GET', 'auth/users/me/', token: token);
    return respuesta['username'] as String;
  }

  /// Revisa que el servidor conteste en [en] (por defecto, en [servidor]).
  /// Sin token, el servidor responde 401 a `quién soy`: eso es que está ahí.
  ///
  /// Como el cliente solo confía en la autoridad de Brilliant, un servidor
  /// ajeno que se haga pasar por el de Brilliant no contesta: da [SinConexion].
  /// Espera la respuesta hasta [espera]: para revisar si está, no hace falta
  /// tanto como para un pedido de verdad.
  Future<void> probarConexion({Uri? en, Duration espera = _espera}) async {
    try {
      await _pedir('GET', 'auth/users/me/', en: en, espera: espera);
    } on SesionVencida {
      return;
    }
  }

  /// Cierra la sesión de [token] en el servidor: el token deja de servir.
  Future<void> salir(String token) async {
    await _pedir('POST', 'auth/token/logout/', token: token);
  }

  /// Borra la cuenta de la sesión de [token]. El servidor pide la
  /// [contrasena] actual para confirmarlo.
  Future<void> borrarCuenta({required String token, required String contrasena}) async {
    await _pedir('DELETE', 'auth/users/me/', token: token, cuerpo: {
      'current_password': contrasena,
    });
  }

  Future<Map<String, dynamic>> _pedir(
    String metodo,
    String ruta, {
    String? token,
    Map<String, String>? cuerpo,
    Uri? en,
    Duration espera = _espera,
  }) async {
    final pedido = http.Request(metodo, (en ?? servidor).resolve(ruta))
      ..headers['Accept'] = 'application/json';
    if (token != null) pedido.headers['Authorization'] = 'Token $token';
    if (cuerpo != null) {
      pedido.headers['Content-Type'] = 'application/json';
      pedido.body = jsonEncode(cuerpo);
    }

    final http.Response respuesta;
    try {
      respuesta = await http.Response.fromStream(await _http.send(pedido).timeout(espera));
    } on Exception {
      // Sin red, servidor apagado, certificado ajeno o tiempo agotado: para
      // el jugador es lo mismo, no hay con quién hablar.
      throw const SinConexion();
    }

    final datos = _leerJson(respuesta);
    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) return datos;
    if (respuesta.statusCode == 401) throw const SesionVencida();
    if (respuesta.statusCode >= 500) {
      throw const ErrorDeCuenta(generales: ['El servidor tuvo un problema. Intenta de nuevo.']);
    }
    throw _errorDe(datos);
  }

  static Map<String, dynamic> _leerJson(http.Response respuesta) {
    if (respuesta.bodyBytes.isEmpty) return const {};
    try {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      return datos is Map<String, dynamic> ? datos : const {};
    } on FormatException {
      return const {};
    }
  }

  /// Los errores de DRF vienen como `{"campo": ["mensaje", ...]}`; los que no
  /// son de un campo, en `non_field_errors` o en `detail`.
  static ErrorDeCuenta _errorDe(Map<String, dynamic> datos) {
    List<String> mensajes(Object? valor) => switch (valor) {
          final List<dynamic> lista => [for (final mensaje in lista) '$mensaje'],
          null => const [],
          _ => ['$valor'],
        };

    final porCampo = <String, List<String>>{};
    final generales = <String>[];
    for (final MapEntry(key: campo, :value) in datos.entries) {
      if (campo == 'non_field_errors' || campo == 'detail') {
        generales.addAll(mensajes(value));
      } else {
        porCampo[campo] = mensajes(value);
      }
    }
    if (porCampo.isEmpty && generales.isEmpty) {
      generales.add('El servidor rechazó el pedido.');
    }
    return ErrorDeCuenta(porCampo: porCampo, generales: generales);
  }
}
