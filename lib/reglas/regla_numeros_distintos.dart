/// Regla "todos diferentes": el nuevo número es válido solo si, sumado a
/// los que ya están en la zona, todos los valores siguen siendo distintos
/// entre sí (no se permite repetir ningún número).
bool puedeAgregarManteniendoDistintos(List<int> numeros, int numero) {
  final conNuevo = [...numeros, numero];
  return conNuevo.length == conNuevo.toSet().length;
}
