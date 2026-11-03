import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cliente_http_web.dart' if (dart.library.io) 'cliente_http_io.dart' as plataforma;

/// El certificado público de la autoridad local del servidor de cuentas. Lo
/// copia ahí `servidor/generar_certificados.py`.
const certificadoDeLaAutoridad = 'assets/certificados/brilliant_ca.pem';

/// El cliente HTTP para hablar con el servidor de cuentas. En Android y en
/// Windows solo confía en la autoridad local del servidor, y en ninguna otra:
/// es como fijar el certificado. En la web usa el del navegador, que tiene
/// que confiar en esa autoridad.
Future<http.Client> crearClienteHttp() => plataforma.crearClienteHttp();

/// La dirección del servidor de cuentas. Se elige al compilar, con
/// `--dart-define=SERVIDOR=https://192.168.100.5:8443` (para el celular).
/// Sin eso, el emulador de Android lo busca en la PC (`10.0.2.2`), y la web y
/// Windows en `localhost`.
Uri direccionDelServidor() {
  const definida = String.fromEnvironment('SERVIDOR');
  if (definida.isNotEmpty) return Uri.parse(definida.endsWith('/') ? definida : '$definida/');
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return Uri.parse('https://10.0.2.2:8443/');
  }
  return Uri.parse('https://localhost:8443/');
}
