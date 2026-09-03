import 'package:flutter/material.dart';

import 'modelo/celda.dart';
import 'modelo/color5.dart';
import 'ui/widgets/celda_widget.dart';

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
      home: const PantallaDemoCeldas(),
    );
  }
}

/// Pantalla provisional para verificar visualmente el widget de celda,
/// mientras se construye el resto del tablero.
class PantallaDemoCeldas extends StatelessWidget {
  const PantallaDemoCeldas({super.key});

  @override
  Widget build(BuildContext context) {
    const celdasDeMuestra = [
      Celda(fila: 0, columna: 0, color: Color5.amarillo, valor: 3),
      Celda(fila: 0, columna: 1, color: Color5.verde),
      Celda(fila: 0, columna: 2, color: Color5.azul, valor: 4, esInicial: true),
      Celda(fila: 0, columna: 3, color: Color5.morado),
      Celda(fila: 0, columna: 4, color: Color5.rojo, valor: 6),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant — demo de celdas')),
      body: Center(
        child: Wrap(
          spacing: 8,
          children: [
            for (final celda in celdasDeMuestra) CeldaWidget(celda: celda),
          ],
        ),
      ),
    );
  }
}
