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

  /// El recuadro de los avisos: por qué no se puede jugar en una casilla, o
  /// qué pasó con la cuenta.
  static const aviso = Color(0xFFFFF1D9);
  static const avisoTinta = Color(0xFF6B4D17);

  /// Lo que no se puede deshacer, como borrar la cuenta.
  static const peligro = Color(0xFFC0473F);
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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: _bordeDeCampo(Paleta.baseTablero, 1.5),
      focusedBorder: _bordeDeCampo(Paleta.acento, 2),
      errorBorder: _bordeDeCampo(Paleta.peligro, 1.5),
      focusedErrorBorder: _bordeDeCampo(Paleta.peligro, 2),
      errorStyle: const TextStyle(color: Paleta.peligro),
      errorMaxLines: 4,
      helperMaxLines: 3,
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

/// El borde redondeado de los campos de texto, como las fichas del tablero.
OutlineInputBorder _bordeDeCampo(Color color, double grosor) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: grosor),
    );
