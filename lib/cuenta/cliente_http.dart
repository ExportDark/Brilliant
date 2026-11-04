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
