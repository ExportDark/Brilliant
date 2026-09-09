import 'region.dart';

/// Extrae los valores de las celdas ya llenas de [region].
/// Las celdas vacías (valor `null`) se excluyen del resultado.
List<int> extraerValores(Region region) {
  return region.casillas.map((celda) => celda.valor).whereType<int>().toList();
}
