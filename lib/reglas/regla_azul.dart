import 'regla_color.dart';
import 'regla_valor_unico.dart';

/// Zona azul: todas las celdas de la zona deben terminar con el mismo valor.
class ReglaAzul implements ReglaColor {
  const ReglaAzul();

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarValorUnico(numeros, numero);
  }

  @override
  String get descripcion => 'Todos iguales: las 4 casillas llevan el mismo número';
}
