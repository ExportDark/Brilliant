import 'regla_color.dart';
import 'regla_rango.dart';

/// Zona naranja: solo acepta números de un rango, como "1-3" o "4-6". Cada
/// zona naranja trae su propio rango.
class ReglaNaranja implements ReglaColor {
  final int minimo;
  final int maximo;

  const ReglaNaranja({required this.minimo, required this.maximo});

  @override
  bool puedeAgregar(List<int> numeros, int numero) {
    return puedeAgregarEnRango(numero, minimo, maximo);
  }

  @override
  String get descripcion => 'Solo del $minimo al $maximo';
}
