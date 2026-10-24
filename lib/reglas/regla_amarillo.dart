import 'regla_color.dart';
import 'regla_numeros_distintos.dart';

/// Zona amarilla: sus celdas pueden estar dispersas por el tablero, pero
/// cuentan como una única región lógica — no se puede repetir ningún valor entre
/// ninguna de ellas, igual que la zona roja.
class ReglaAmarillo implements ReglaColor {
  const ReglaAmarillo();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarManteniendoDistintos(numeros, numero);
  }

  @override
  String get descripcion =>
      'Todos diferentes: ningún número se repite entre las casillas amarillas';
}
