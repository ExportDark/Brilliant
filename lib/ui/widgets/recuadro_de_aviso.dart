import 'package:flutter/material.dart';

import '../tema.dart';

/// Un aviso suave, con un ícono y el texto: por qué no se puede anotar en una
/// casilla, o qué pasó con la cuenta. Es color arena, no rojo de error.
class RecuadroDeAviso extends StatelessWidget {
  final String texto;
  final IconData icono;

  const RecuadroDeAviso(this.texto, {super.key, this.icono = Icons.info_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Paleta.aviso,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, color: Paleta.avisoTinta),
            const SizedBox(width: 10),
            Expanded(
              child: Text(texto, style: const TextStyle(color: Paleta.avisoTinta, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }
}
