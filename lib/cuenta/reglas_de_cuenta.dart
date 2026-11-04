/// Las reglas del nombre de usuario y de la contraseña: las mismas que revisa
/// el servidor (`servidor/cuentas/serializers.py`), con los mismos mensajes.
/// La app las revisa antes de mandar nada, para avisar al momento.
///
/// Los largos se cuentan en caracteres (runas), como los cuenta Python.
library;

const largoMinimoUsuario = 3;
const largoMaximoUsuario = 20;
const largoMinimoContrasena = 8;
const largoMaximoContrasena = 128;

const usuarioDeOtroLargo =
    'El nombre de usuario debe tener entre $largoMinimoUsuario y $largoMaximoUsuario caracteres.';
const usuarioConCaracteresRaros =
    'Solo puede tener letras sin acento, números, punto, guion y guion bajo.';

/// Solo letras sin acento, números, punto, guion y guion bajo: así no hay
/// letras de otros alfabetos que se parezcan ("аna", en cirílico, no es "ana").
final _caracteresDelUsuario = RegExp(r'^[A-Za-z0-9._-]+$');

/// Qué tiene de malo [usuario], ya sin los espacios del borde, o `null` si
/// cumple las reglas.
String? problemaConElUsuario(String usuario) {
  if (usuario.isEmpty) return 'Elige un nombre de usuario';
  final largo = usuario.runes.length;
  if (largo < largoMinimoUsuario || largo > largoMaximoUsuario) return usuarioDeOtroLargo;
  if (!_caracteresDelUsuario.hasMatch(usuario)) return usuarioConCaracteresRaros;
  return null;
}

/// Qué tiene de malo [contrasena] por su largo, o `null` si está bien. Lo
/// demás (que no sea común, ni solo números, ni parecida al usuario) lo
/// revisa el servidor. La contraseña nunca se recorta: los espacios del borde
/// también son parte de ella.
String? problemaConLaContrasena(String contrasena) {
  if (contrasena.isEmpty) return 'Elige una contraseña';
  final largo = contrasena.runes.length;
  if (largo < largoMinimoContrasena) return 'Al menos $largoMinimoContrasena caracteres';
  if (largo > largoMaximoContrasena) return 'Como mucho $largoMaximoContrasena caracteres';
  return null;
}
