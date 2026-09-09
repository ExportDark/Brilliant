import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color5.dart';
import 'package:brilliant/modelo/tipo_region.dart';
import 'package:brilliant/reglas/regla_amarillo.dart';
import 'package:brilliant/reglas/regla_azul.dart';
import 'package:brilliant/reglas/regla_morado.dart';
import 'package:brilliant/reglas/regla_rojo.dart';
import 'package:brilliant/reglas/regla_verde.dart';

void main() {
  group('Tipos de región del mapa actual', () {
    test('tipoAmarillo: color y cantidadCeldas correctos', () {
      expect(tipoAmarillo.color, Color5.amarillo);
      expect(tipoAmarillo.cantidadCeldas, 5);
      expect(tipoAmarillo.regla, isA<ReglaAmarillo>());
    });

    test('tipoVerde: color y cantidadCeldas correctos', () {
      expect(tipoVerde.color, Color5.verde);
      expect(tipoVerde.cantidadCeldas, 6);
      expect(tipoVerde.regla, isA<ReglaVerde>());
    });

    test('tipoMorado: color y cantidadCeldas correctos', () {
      expect(tipoMorado.color, Color5.morado);
      expect(tipoMorado.cantidadCeldas, 6);
      expect(tipoMorado.regla, isA<ReglaMorado>());
    });

    test('tipoAzul: color y cantidadCeldas correctos', () {
      expect(tipoAzul.color, Color5.azul);
      expect(tipoAzul.cantidadCeldas, 4);
      expect(tipoAzul.regla, isA<ReglaAzul>());
    });

    test('tipoRojo: color y cantidadCeldas correctos', () {
      expect(tipoRojo.color, Color5.rojo);
      expect(tipoRojo.cantidadCeldas, 6);
      expect(tipoRojo.regla, isA<ReglaRojo>());
    });
  });
}
