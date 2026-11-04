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

/// La app sigue abierta: con sesión, se le avisa al servidor. Una cuenta tiene
/// una sola sesión activa, y "activa" es usada hace poco: este aviso, que la
/// app manda cada 2 minutos mientras está en primer plano, la mantiene así.
final class SesionLatido extends SesionEvent {
  const SesionLatido();
}
