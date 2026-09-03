/// Regla "todos iguales": el nuevo número es válido solo si coincide con
/// los que ya están en la zona (o si la zona sigue vacía).
bool puedeAgregarValorUnico(List<int> numeros, int numero) {
  if (numeros.isEmpty) return true;
  return numeros.every((n) => n == numero);
}
