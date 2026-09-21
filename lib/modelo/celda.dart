import 'color5.dart';
import 'posicion.dart';

/// Una celda del tablero: posición fija, color de zona fijo, y un valor
/// (1-6) que se anota durante la partida, o `null` si sigue vacía.
class Celda {
  final Posicion posicion;
  final Color5 color;
  final int? valor;
  final bool esInicial;

  const Celda({
    required this.posicion,
    required this.color,
    this.valor,
    this.esInicial = false,
  }) : assert(valor == null || (valor >= 1 && valor <= 6));

  bool get estaVacia => valor == null;

  Celda conValor(int nuevoValor) {
    return Celda(
      posicion: posicion,
      color: color,
      valor: nuevoValor,
      esInicial: esInicial,
    );
  }

  Celda sinValor() {
    return Celda(posicion: posicion, color: color, esInicial: esInicial);
  }

  @override
  bool operator ==(Object other) {
    return other is Celda &&
        other.posicion == posicion &&
        other.color == color &&
        other.valor == valor &&
        other.esInicial == esInicial;
  }

  @override
  int get hashCode => Object.hash(posicion, color, valor, esInicial);

  @override
  String toString() =>
      'Celda(posicion: $posicion, color: $color, valor: $valor, esInicial: $esInicial)';
}
