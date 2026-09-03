import 'regla_color.dart';
import 'regla_maximo_valores_distintos.dart';

/// Zona morada: dentro de toda la zona (6 celdas) solo puede haber, como
/// máximo, dos números distintos repetidos entre sí.
class ReglaMorado implements ReglaColor {
  static const _maximoValoresDistintos = 2;

  const ReglaMorado();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarConMaximoValoresDistintos(
      numeros,
      numero,
      _maximoValoresDistintos,
    );
  }
}
