import 'package:flutter/material.dart';

import 'ui/pantallas/pantalla_preparacion.dart';
import 'ui/tema.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant',
      debugShowCheckedModeBanner: false,
      theme: temaBrilliant(),
      home: const PantallaPreparacion(),
    );
  }
}
