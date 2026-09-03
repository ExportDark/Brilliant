import 'regla_color.dart';
import 'regla_numeros_distintos.dart';

/// Zona roja: sus 6 celdas deben terminar con 6 valores todos distintos
/// entre sí (una "corrida" del 1 al 6).
class ReglaRojo implements ReglaColor {
  const ReglaRojo();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarManteniendoDistintos(numeros, numero);
  }
}
