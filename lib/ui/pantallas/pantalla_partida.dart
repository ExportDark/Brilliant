import 'package:flutter/material.dart';

import '../../modelo/tablero.dart';
import '../widgets/tablero_widget.dart';

/// Pantalla provisional de la partida: muestra el tablero con los valores
/// iniciales ya fijos. Los dados y los turnos llegan en el siguiente módulo.
class PantallaPartida extends StatelessWidget {
  final Tablero tablero;

  const PantallaPartida({super.key, required this.tablero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant — partida')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableroWidget(tablero: tablero),
              const SizedBox(height: 16),
              const Text(
                'Partida lista. Los dados y los turnos vienen en el siguiente módulo.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
