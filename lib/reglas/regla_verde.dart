import 'regla_color.dart';
import 'regla_cualquiera.dart';

/// Zona verde: sin restricción de valor, cualquier número es válido.
class ReglaVerde implements ReglaColor {
  const ReglaVerde();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarCualquiera(numeros, numero);
  }
}
