import '../modelo/posicion.dart';

/// Los números que se reparten entre las casillas iniciales: las caras de un
/// dado de 6.
const valoresPosibles = {1, 2, 3, 4, 5, 6};

/// Lo repartido hasta ahora entre las casillas iniciales.
class PreparacionState {
  /// Las casillas que hay que llenar, en el orden en que se muestran.
  final List<Posicion> casillas;

  /// El número anotado en cada casilla ya asignada.
  final Map<Posicion, int> valores;

  /// Verdadero cuando el jugador cerró la preparación.
  final bool confirmada;

  const PreparacionState({
    required this.casillas,
    this.valores = const {},
    this.confirmada = false,
  });

  PreparacionState copiaCon({Map<Posicion, int>? valores, bool? confirmada}) {
    return PreparacionState(
      casillas: casillas,
      valores: valores ?? this.valores,
      confirmada: confirmada ?? this.confirmada,
    );
  }

  /// El número anotado en [casilla], o `null` si sigue vacía.
  int? valorDe(Posicion casilla) => valores[casilla];

  /// Los números que todavía quedan por repartir.
  Set<int> get disponibles =>
      valoresPosibles.difference(valores.values.toSet());

  /// Verdadero cuando todas las casillas tienen número. Como nunca se admite
  /// un número repetido, tenerlas todas llenas implica que los valores son
  /// distintos entre sí.
  bool get completa => valores.length == casillas.length;
}
