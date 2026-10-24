import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/modelo/tipo_region.dart';
import 'package:brilliant/reglas/regla_amarillo.dart';
import 'package:brilliant/reglas/regla_azul.dart';
import 'package:brilliant/reglas/regla_morado.dart';
import 'package:brilliant/reglas/regla_rojo.dart';
import 'package:brilliant/reglas/regla_verde.dart';

void main() {
  group('Tipos de región', () {
    test('tipoAmarillo: su color y su regla', () {
      expect(tipoAmarillo.color, ColorZona.amarillo);
      expect(tipoAmarillo.regla, isA<ReglaAmarillo>());
    });

    test('tipoVerde: su color y su regla', () {
      expect(tipoVerde.color, ColorZona.verde);
      expect(tipoVerde.regla, isA<ReglaVerde>());
    });

    test('tipoMorado: su color y su regla', () {
      expect(tipoMorado.color, ColorZona.morado);
      expect(tipoMorado.regla, isA<ReglaMorado>());
    });

    test('tipoAzul: su color y su regla', () {
      expect(tipoAzul.color, ColorZona.azul);
      expect(tipoAzul.regla, isA<ReglaAzul>());
    });

    test('tipoRojo: su color y su regla', () {
      expect(tipoRojo.color, ColorZona.rojo);
      expect(tipoRojo.regla, isA<ReglaRojo>());
    });
  });
}
