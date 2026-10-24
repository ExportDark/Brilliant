/// Regla "solo un rango": el nuevo número es válido solo si está entre
/// [minimo] y [maximo], los dos incluidos. No depende de lo que ya tenga la
/// zona: un número fuera del rango no cabe ni en una zona vacía.
bool puedeAgregarEnRango(int numero, int minimo, int maximo) {
  return numero >= minimo && numero <= maximo;
}
