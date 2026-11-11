import 'package:flutter/foundation.dart';

/// El puerto en el que escucha el servidor de cuentas (`Brilliant-servidor\iniciar.bat`).
const puertoDelServidor = 8443;

/// La dirección del servidor si el jugador no eligió otra. Se puede fijar al
/// compilar, con `--dart-define=SERVIDOR=https://192.168.137.252:8443`. Sin
/// eso, el emulador de Android lo busca en la PC (`10.0.2.2`), y la web y
/// Windows en `localhost`.
Uri direccionPorDefecto() {
  const definida = String.fromEnvironment('SERVIDOR');
  if (definida.isNotEmpty) return direccionDesdeTexto(definida)!;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return direccionDesdeTexto('10.0.2.2')!;
  }
  return direccionDesdeTexto('localhost')!;
}

/// Convierte lo que escribe el jugador en la dirección del servidor. Acepta
/// "192.168.137.252", "192.168.137.252:8443" o "https://192.168.137.252:8443";
/// sin puerto, usa el [puertoDelServidor].
///
/// Devuelve `null` si no es una dirección, o si es `http://`: con el
/// servidor solo se habla por HTTPS.
Uri? direccionDesdeTexto(String texto) {
  final limpio = texto.trim();
  if (limpio.isEmpty || limpio.contains(' ')) return null;

  final conEsquema = limpio.contains('://') ? limpio : 'https://$limpio';
  final Uri direccion;
  try {
    direccion = Uri.parse(conEsquema);
  } on FormatException {
    return null;
  }
  if (direccion.scheme != 'https' || direccion.host.isEmpty) return null;

  return Uri(
    scheme: 'https',
    host: direccion.host,
    port: direccion.hasPort ? direccion.port : puertoDelServidor,
    path: '/',
  );
}

/// La dirección como la escribiría el jugador: solo la IP (o el nombre) si
/// usa el puerto de siempre, y con el puerto si no.
String textoDeDireccion(Uri direccion) =>
    direccion.port == puertoDelServidor ? direccion.host : '${direccion.host}:${direccion.port}';
