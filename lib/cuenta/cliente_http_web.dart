import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// En la web, el navegador decide en qué certificados confía: tiene que
/// confiar en la autoridad local del servidor (ver `Brilliant-servidor/README.md`).
Future<http.Client> crearClienteHttp() async => BrowserClient();
