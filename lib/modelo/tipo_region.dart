import '../reglas/regla_amarillo.dart';
import '../reglas/regla_azul.dart';
import '../reglas/regla_color.dart';
import '../reglas/regla_morado.dart';
import '../reglas/regla_rojo.dart';
import '../reglas/regla_verde.dart';
import 'color_zona.dart';

/// Une un color con su regla de colocación. Cuántas celdas tiene cada zona
/// no es parte del tipo: lo decide cada mapa al declarar sus zonas.
class TipoRegion {
  final ColorZona color;
  final ReglaColor regla;

  const TipoRegion({required this.color, required this.regla});
}

const tipoAmarillo = TipoRegion(color: ColorZona.amarillo, regla: ReglaAmarillo());

const tipoVerde = TipoRegion(color: ColorZona.verde, regla: ReglaVerde());

const tipoMorado = TipoRegion(color: ColorZona.morado, regla: ReglaMorado());

const tipoAzul = TipoRegion(color: ColorZona.azul, regla: ReglaAzul());

const tipoRojo = TipoRegion(color: ColorZona.rojo, regla: ReglaRojo());
