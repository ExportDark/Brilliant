/// Una hora que solo avanza: la del sistema al crearse, más lo que mide un cronómetro.
///
/// La usa el multijugador para contar la cuenta regresiva y cuánto lleva el servidor sin
/// contestar. Con `DateTime.now` a secas, si el teléfono ajusta su reloj a mitad de la
/// partida (por la red, o a mano), la cuenta saltaba y podía aparecer "se perdió la
/// conexión" sin razón.
DateTime Function() relojMonotono({Stopwatch? cronometro, DateTime? inicio}) {
  final medido = (cronometro ?? Stopwatch())..start();
  final base = inicio ?? DateTime.now();
  return () => base.add(medido.elapsed);
}
