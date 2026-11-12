import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/ui/tema.dart';

void main() {
  test('tintaSobre: el número va en tinta sobre los colores de zona y en cartón sobre un fondo '
      'oscuro', () {
    // Los colores de zona son medios: la tinta oscura es la que más contrasta.
    for (final color in ColorZona.values) {
      expect(tintaSobre(coloresDeZona[color]!), Paleta.tinta, reason: 'zona ${color.name}');
    }
    // Sobre un fondo oscuro se cambia al color del cartón, para que siempre se lea.
    expect(tintaSobre(const Color(0xFF2B2B3A)), Paleta.carton);
  });
}
