import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/color_zona.dart';
import 'package:brilliant/ui/tema.dart';

void main() {
  test('tintaSobre: el número va oscuro sobre los colores suaves y blanco sobre un fondo oscuro', () {
    // Los 5 colores de zona son claros, aun sin iluminar: el número va oscuro.
    for (final color in ColorZona.values) {
      expect(tintaSobre(coloresDeZona[color]!), Paleta.tinta, reason: 'zona ${color.name}');
    }
    // Sobre un fondo oscuro se cambia a blanco, para que siempre se lea.
    expect(tintaSobre(const Color(0xFF2B2B3A)), Colors.white);
  });
}
