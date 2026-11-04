/// Lo que la app le pide al [SesionBloc].
sealed class SesionEvent {
  const SesionEvent();
}

/// Al abrir la app: si hay una sesión guardada, revisa con el servidor que
/// todavía sirva.
final class SesionRevisada extends SesionEvent {
  const SesionRevisada();
}

/// Iniciar sesión con usuario y contraseña.
final class EntradaPedida extends SesionEvent {
  final String usuario;
  final String contrasena;

  const EntradaPedida({required this.usuario, required this.contrasena});
}

/// Crear una cuenta, y con ella iniciar sesión.
final class CuentaPedida extends SesionEvent {
  final String usuario;
  final String contrasena;
  final String repetida;

  const CuentaPedida({required this.usuario, required this.contrasena, required this.repetida});
}

/// Cerrar la sesión.
final class SalidaPedida extends SesionEvent {
  const SalidaPedida();
}

/// Borrar la cuenta, confirmando con la contraseña actual.
final class BorradoPedido extends SesionEvent {
  final String contrasena;

  const BorradoPedido({required this.contrasena});
}

/// Olvidar el error y el aviso del último pedido, al pasar de una pantalla
/// de cuenta a otra.
final class AvisosDescartados extends SesionEvent {
  const AvisosDescartados();
}

/// Cambiar la dirección del servidor, por ejemplo porque la PC cambió de red.
/// Con `null`, vuelve a la de siempre. Después prueba que el servidor
/// conteste ahí.
final class ServidorCambiado extends SesionEvent {
  final Uri? direccion;

  const ServidorCambiado(this.direccion);
}
