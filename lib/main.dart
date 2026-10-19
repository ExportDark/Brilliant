import 'package:flutter/material.dart';

import 'ui/pantallas/pantalla_preparacion.dart';
import 'ui/tema.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  /// Decide qué sale en los dados. Sin él salen al azar; los tests lo fijan.
  final int Function()? tirarDado;

  const BrilliantApp({super.key, this.tirarDado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant',
      debugShowCheckedModeBanner: false,
      theme: temaBrilliant(),
      home: PantallaPreparacion(tirarDado: tirarDado),
    );
  }
}
