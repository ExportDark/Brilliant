import 'package:flutter/material.dart';

import '../modelo/color_zona.dart';

/// Los colores de la app: un fondo crema, un acento lavanda oscuro y tonos
/// suaves para todo lo demás.
abstract final class Paleta {
  /// El fondo de las pantallas.
  static const fondo = Color(0xFFFAF7F2);

  /// La base sobre la que se apoyan las fichas del tablero.
  static const baseTablero = Color(0xFFEDE6DB);

  /// El texto principal: casi negro, un poco cálido.
  static const tinta = Color(0xFF2F2A3B);

  /// El texto secundario, como las indicaciones.
  static const tintaSuave = Color(0xFF6E6879);

  /// El color de acento: botones, el dado ancla, la barra de progreso.
  static const acento = Color(0xFF6A5FB0);

  /// El recuadro que explica por qué no se puede jugar en una casilla.
  static const aviso = Color(0xFFFFF1D9);
  static const avisoTinta = Color(0xFF6B4D17);
}

/// El color de cada zona del tablero, en tonos suaves pero fáciles de
/// distinguir entre sí.
const coloresDeZona = {
  ColorZona.rojo: Color(0xFFF28B82),
  ColorZona.morado: Color(0xFFB79CED),
  ColorZona.azul: Color(0xFF7FB7F0),
  ColorZona.verde: Color(0xFF8FCB9B),
  ColorZona.amarillo: Color(0xFFF6D365),
  ColorZona.gris: Color(0xFFC9C2B8),
  // Entre el coral y la mantequilla, para no confundirse con ninguno.
  ColorZona.naranja: Color(0xFFF5A65B),
};

/// El color de texto que se lee bien sobre [fondo]: oscuro sobre colores
/// claros y blanco sobre colores oscuros.
Color tintaSobre(Color fondo) {
  return ThemeData.estimateBrightnessForColor(fondo) == Brightness.dark
      ? Colors.white
      : Paleta.tinta;
}

/// El tema de toda la app.
ThemeData temaBrilliant() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Paleta.acento,
    primary: Paleta.acento,
    surface: Paleta.fondo,
  );
  const forma = StadiumBorder();

  return ThemeData(
    colorScheme: esquema,
    scaffoldBackgroundColor: Paleta.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: Paleta.fondo,
      foregroundColor: Paleta.tinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Paleta.tinta,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: forma,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: forma,
        foregroundColor: Paleta.tintaSuave,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
