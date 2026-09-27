import 'package:flutter/material.dart';

import 'modelo/tablero.dart';
import 'ui/widgets/tablero_widget.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const PantallaTablero(),
    );
  }
}

/// Pantalla provisional que muestra el mapa original, para comparar a ojo
/// la transcripción del layout con el manual.
class PantallaTablero extends StatelessWidget {
  const PantallaTablero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant — tablero')),
      body: Center(child: TableroWidget(tablero: Tablero.mapaOriginal())),
    );
  }
}
