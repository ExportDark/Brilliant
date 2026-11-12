import 'package:flutter/material.dart';

import '../modelo/color_zona.dart';

/// Los colores de la app, como un juego de mesa: la mesa de fieltro verde, encima
/// bandejas de cartón con borde de tinta, y fichas de colores planos con una sombra dura
/// (sin difuminar), como piezas que se pueden tocar.
abstract final class Paleta {
  /// La mesa: el fondo de todas las pantallas, como un tapete de fieltro.
  static const mesa = Color(0xFF2F5D50);

  /// El texto que va directo sobre la mesa (los títulos de la barra de arriba).
  static const sobreLaMesa = Color(0xFFF6EEDC);

  /// El cartón de las bandejas, donde va casi todo el contenido.
  static const carton = Color(0xFFF6EEDC);

  /// Un cartón más claro, para las piezas que van encima de una bandeja: las tarjetas de
  /// los mapas, el marcador, las fichas de número.
  static const cartonClaro = Color(0xFFFFFCF4);

  /// El fondo de las pantallas: la mesa.
  static const fondo = mesa;

  /// La base sobre la que se apoyan las fichas del tablero, y los divisores: un cartón
  /// más oscuro.
  static const baseTablero = Color(0xFFE2D2B2);

  /// El texto principal y el borde de todas las piezas: tinta casi negra, cálida.
  static const tinta = Color(0xFF1F1A17);

  /// El texto secundario, como las indicaciones.
  static const tintaSuave = Color(0xFF665B50);

  /// El color de acento: el dado ancla, el que va primero, lo elegido. Tinta, para que
  /// no se confunda con ningún color de zona.
  static const acento = tinta;

  /// La ficha amarilla de los botones principales.
  static const ficha = Color(0xFFF2B705);

  /// El recuadro de los avisos: qué pasó con la cuenta, o con la conexión.
  static const aviso = Color(0xFFFFE6A1);
  static const avisoTinta = tinta;

  /// Lo que no se puede deshacer, como borrar la cuenta o rendirse.
  static const peligro = Color(0xFFC8402F);

  /// El punto de "Servidor disponible", y lo que ya está listo.
  static const disponible = Color(0xFF2F8F5B);
}

/// El borde de tinta de las piezas.
const grosorDeTinta = 2.5;

/// La sombra dura de una pieza que está sobre la mesa: desplazada hacia abajo, sin
/// difuminar. Cuanto más [alto], más levantada se ve.
List<BoxShadow> sombraDura([double alto = 4]) => [
  BoxShadow(color: Paleta.tinta, offset: Offset(0, alto), blurRadius: 0),
];

/// El color de cada zona del tablero: planos y saturados, como fichas impresas, pero
/// fáciles de distinguir entre sí.
const coloresDeZona = {
  ColorZona.rojo: Color(0xFFE9573F),
  ColorZona.morado: Color(0xFF9B78DB),
  ColorZona.azul: Color(0xFF4A93E0),
  ColorZona.verde: Color(0xFF55B67C),
  ColorZona.amarillo: Color(0xFFF7C531),
  ColorZona.gris: Color(0xFFB3ACA2),
  // Entre el rojo y el amarillo, para no confundirse con ninguno.
  ColorZona.naranja: Color(0xFFF28A2E),
};

/// El color de texto que se lee mejor sobre [fondo], la tinta o el cartón: el que tiene
/// más contraste. Sobre los colores de zona, que son medios, casi siempre es la tinta.
Color tintaSobre(Color fondo) {
  double contraste(Color a, Color b) {
    final (claro, oscuro) = a.computeLuminance() > b.computeLuminance()
        ? (a.computeLuminance(), b.computeLuminance())
        : (b.computeLuminance(), a.computeLuminance());
    return (claro + 0.05) / (oscuro + 0.05);
  }

  return contraste(fondo, Paleta.tinta) >= contraste(fondo, Paleta.carton)
      ? Paleta.tinta
      : Paleta.carton;
}

/// Las familias de letra: Archivo para todo, y Archivo Black para los títulos y los
/// números del tablero.
const familiaDeTexto = 'Archivo';
const familiaDeTitulos = 'ArchivoBlack';

/// El tema de toda la app.
ThemeData temaBrilliant() {
  final esquema = const ColorScheme.light(
    primary: Paleta.tinta,
    onPrimary: Paleta.carton,
    secondary: Paleta.ficha,
    onSecondary: Paleta.tinta,
    surface: Paleta.carton,
    onSurface: Paleta.tinta,
    error: Paleta.peligro,
  );
  final bordeDeTinta = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
  );

  // La escala de letra, en pasos de una escala clásica (13, 15, 17, 19, 22, 26, 34).
  const textos = TextTheme(
    displaySmall: TextStyle(
      fontFamily: familiaDeTitulos,
      fontSize: 34,
      height: 1.1,
    ),
    headlineSmall: TextStyle(
      fontFamily: familiaDeTitulos,
      fontSize: 26,
      height: 1.15,
    ),
    titleLarge: TextStyle(
      fontFamily: familiaDeTitulos,
      fontSize: 22,
      height: 1.2,
    ),
    titleMedium: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 1.25,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    bodyLarge: TextStyle(fontSize: 17, height: 1.4),
    bodyMedium: TextStyle(fontSize: 15, height: 1.4),
    bodySmall: TextStyle(fontSize: 13, height: 1.35),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  );

  return ThemeData(
    colorScheme: esquema,
    fontFamily: familiaDeTexto,
    textTheme: textos.apply(
      bodyColor: Paleta.tinta,
      displayColor: Paleta.tinta,
    ),
    scaffoldBackgroundColor: Paleta.mesa,
    appBarTheme: const AppBarTheme(
      backgroundColor: Paleta.mesa,
      foregroundColor: Paleta.sobreLaMesa,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: familiaDeTitulos,
        color: Paleta.sobreLaMesa,
        fontSize: 21,
      ),
    ),
    // Los botones principales son fichas amarillas con borde de tinta.
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(bordeDeTinta),
        minimumSize: const WidgetStatePropertyAll(Size(0, 54)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 28),
        ),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: familiaDeTexto,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.disabled)
              ? Paleta.baseTablero
              : Paleta.ficha,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (estados) => estados.contains(WidgetState.disabled)
              ? Paleta.tintaSuave
              : Paleta.tinta,
        ),
        side: WidgetStateProperty.resolveWith(
          (estados) => BorderSide(
            color: estados.contains(WidgetState.disabled)
                ? Paleta.tintaSuave.withValues(alpha: 0.5)
                : Paleta.tinta,
            width: grosorDeTinta,
          ),
        ),
        overlayColor: WidgetStatePropertyAll(
          Paleta.tinta.withValues(alpha: 0.08),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: bordeDeTinta,
        minimumSize: const Size(0, 54),
        backgroundColor: Paleta.carton,
        foregroundColor: Paleta.tinta,
        side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
        textStyle: const TextStyle(
          fontFamily: familiaDeTexto,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: Paleta.tinta,
        textStyle: const TextStyle(
          fontFamily: familiaDeTexto,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFBF2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: _bordeDeCampo(Paleta.tinta, 2),
      focusedBorder: _bordeDeCampo(Paleta.tinta, 3),
      errorBorder: _bordeDeCampo(Paleta.peligro, 2),
      focusedErrorBorder: _bordeDeCampo(Paleta.peligro, 3),
      disabledBorder: _bordeDeCampo(Paleta.baseTablero, 2),
      errorStyle: const TextStyle(
        color: Paleta.peligro,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: const TextStyle(
        color: Paleta.tinta,
        fontWeight: FontWeight.w700,
      ),
      errorMaxLines: 4,
      helperMaxLines: 3,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Paleta.carton,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Paleta.tinta, width: grosorDeTinta),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: familiaDeTitulos,
        fontSize: 22,
        color: Paleta.tinta,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Paleta.carton,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: Paleta.tintaSuave,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: Paleta.tinta, width: grosorDeTinta),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Paleta.tinta,
      linearTrackColor: Paleta.baseTablero,
    ),
    dividerTheme: const DividerThemeData(
      color: Paleta.baseTablero,
      thickness: 1.5,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Paleta.tinta,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Paleta.carton,
        fontFamily: familiaDeTexto,
      ),
    ),
  );
}

/// El borde de los campos de texto: de tinta, como las piezas.
OutlineInputBorder _bordeDeCampo(Color color, double grosor) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: grosor),
    );
