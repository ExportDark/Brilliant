/// Una posición fija en la grilla del tablero (fila, columna).
class Posicion {
  final int fila;
  final int columna;

  const Posicion({required this.fila, required this.columna});

  @override
  bool operator ==(Object other) {
    return other is Posicion && other.fila == fila && other.columna == columna;
  }

  @override
  int get hashCode => Object.hash(fila, columna);

  @override
  String toString() => 'Posicion(fila: $fila, columna: $columna)';
}
