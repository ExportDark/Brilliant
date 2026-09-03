import 'color5.dart';

/// Una celda del tablero: posición fija, color de zona fijo, y un valor
/// (1-6) que se anota durante la partida, o `null` si sigue vacía.
class Celda {
  final int fila;
  final int columna;
  final Color5 color;
  final int? valor;
  final bool esInicial;

  const Celda({
    required this.fila,
    required this.columna,
    required this.color,
    this.valor,
    this.esInicial = false,
  }) : assert(valor == null || (valor >= 1 && valor <= 6));

  bool get estaVacia => valor == null;

  Celda conValor(int nuevoValor) {
    return Celda(
      fila: fila,
      columna: columna,
      color: color,
      valor: nuevoValor,
      esInicial: esInicial,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Celda &&
        other.fila == fila &&
        other.columna == columna &&
        other.color == color &&
        other.valor == valor &&
        other.esInicial == esInicial;
  }

  @override
  int get hashCode => Object.hash(fila, columna, color, valor, esInicial);

  @override
  String toString() =>
      'Celda(fila: $fila, columna: $columna, color: $color, valor: $valor, esInicial: $esInicial)';
}
