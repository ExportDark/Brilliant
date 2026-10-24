import '../reglas/regla_amarillo.dart';
import '../reglas/regla_azul.dart';
import '../reglas/regla_color.dart';
import '../reglas/regla_gris.dart';
import '../reglas/regla_morado.dart';
import '../reglas/regla_naranja.dart';
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

const tipoGris = TipoRegion(color: ColorZona.gris, regla: ReglaGris());

/// La zona naranja "1-3".
const tipoNaranjaBajo = TipoRegion(
  color: ColorZona.naranja,
  regla: ReglaNaranja(minimo: 1, maximo: 3),
);

/// La zona naranja "4-6".
const tipoNaranjaAlto = TipoRegion(
  color: ColorZona.naranja,
  regla: ReglaNaranja(minimo: 4, maximo: 6),
);
