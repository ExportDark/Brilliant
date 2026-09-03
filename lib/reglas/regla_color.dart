/// Contrato para la regla de colocación de una zona de color: dado lo que
/// ya está anotado en la zona, decide si un nuevo valor se puede agregar.
abstract class ReglaColor {
  bool puedeAgregar(List<int> numeros, int numero);
}
