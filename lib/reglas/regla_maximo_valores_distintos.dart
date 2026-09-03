/// Regla "solo N números diferentes": el nuevo número es válido solo si,
/// sumado a los que ya están en la zona, la cantidad de valores distintos
/// no supera el máximo permitido.
bool puedeAgregarConMaximoValoresDistintos(
  List<int> numeros,
  int numero,
  int maximoValoresDistintos,
) {
  final conNuevo = [...numeros, numero];
  return conNuevo.toSet().length <= maximoValoresDistintos;
}
