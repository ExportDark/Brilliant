import 'regla_color.dart';
import 'regla_valor_unico.dart';

/// Zona gris: igual que la azul, todas sus celdas deben terminar con el
/// mismo valor, aunque estén dispersas por el tablero.
class ReglaGris implements ReglaColor {
  const ReglaGris();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarValorUnico(numeros, numero);
  }

  @override
  String get descripcion => 'Todos iguales: todas las casillas llevan el mismo número';
}
