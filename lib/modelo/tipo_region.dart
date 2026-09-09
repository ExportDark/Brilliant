import '../reglas/regla_amarillo.dart';
import '../reglas/regla_azul.dart';
import '../reglas/regla_color.dart';
import '../reglas/regla_morado.dart';
import '../reglas/regla_rojo.dart';
import '../reglas/regla_verde.dart';
import 'color5.dart';

/// Une un color con su regla de colocación y con cuántas celdas debe tener
/// cada región de ese tipo EN ESTE MAPA (otro mapa podría declarar otros
/// tamaños para el mismo color — no es una ley universal del color).
class TipoRegion {
  final Color5 color;
  final ReglaColor regla;
  final int cantidadCeldas;

  const TipoRegion({
    required this.color,
    required this.regla,
    required this.cantidadCeldas,
  });
}

/// Tipos de región de este mapa (el layout 7x7 documentado en docs/REGLAS.md).
const tipoAmarillo = TipoRegion(
  color: Color5.amarillo,
  regla: ReglaAmarillo(),
  cantidadCeldas: 5,
);

const tipoVerde = TipoRegion(
  color: Color5.verde,
  regla: ReglaVerde(),
  cantidadCeldas: 6,
);

const tipoMorado = TipoRegion(
  color: Color5.morado,
  regla: ReglaMorado(),
  cantidadCeldas: 6,
);

const tipoAzul = TipoRegion(
  color: Color5.azul,
  regla: ReglaAzul(),
  cantidadCeldas: 4,
);

const tipoRojo = TipoRegion(
  color: Color5.rojo,
  regla: ReglaRojo(),
  cantidadCeldas: 6,
);
