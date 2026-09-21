/// Una posición fija en la grilla del tablero (fila, columna), ambas base 0.
class Posicion {
  final int fila;
  final int columna;

  const Posicion({required this.fila, required this.columna});

  /// Construye la posición desde la notación del manual, donde la letra es la
  /// columna (A, B, C...) y el número es la fila (1, 2, 3...): `"C1"` es la
  /// columna C de la fila 1.
  factory Posicion.desdeNotacion(String notacion) {
    final coincidencia = RegExp(r'^([A-Z])(\d+)$').firstMatch(notacion.toUpperCase());
    if (coincidencia == null) {
      throw FormatException('Notación inválida: "$notacion" (se esperaba algo como "C1").');
    }
    return Posicion(
      fila: int.parse(coincidencia.group(2)!) - 1,
      columna: coincidencia.group(1)!.codeUnitAt(0) - _codigoLetraA,
    );
  }

  static final _codigoLetraA = 'A'.codeUnitAt(0);

  /// La posición escrita como en el manual (ej. `"C1"`).
  String get notacion => '${String.fromCharCode(_codigoLetraA + columna)}${fila + 1}';

  @override
  bool operator ==(Object other) {
    return other is Posicion && other.fila == fila && other.columna == columna;
  }

  @override
  int get hashCode => Object.hash(fila, columna);

  @override
  String toString() => 'Posicion($notacion)';
}
