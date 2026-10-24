import 'regla_color.dart';
import 'regla_numeros_distintos.dart';

/// Zona roja: ningún número se repite entre sus celdas. Con 6 celdas, eso
/// es una "corrida" del 1 al 6.
class ReglaRojo implements ReglaColor {
  const ReglaRojo();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarManteniendoDistintos(numeros, numero);
  }

  @override
  String get descripcion => 'Todos diferentes: ningún número se repite en la zona';
}
