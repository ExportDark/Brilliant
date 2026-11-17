import 'package:flutter/material.dart';

import '../tema.dart';

/// Pregunta antes de algo que no tiene vuelta (salir de la partida, rendirse) y devuelve
/// si dijo que sí. El botón de hacerlo va en rojo; el de quedarse, como texto.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String si,
  String no = 'Seguir jugando',
  Key? claveSi,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actionsOverflowAlignment: accionesApiladas.alineacion,
      actionsOverflowDirection: accionesApiladas.direccion,
      actionsOverflowButtonSpacing: accionesApiladas.separacion,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: Text(no),
        ),
        FilledButton(
          key: claveSi,
          style: estiloDePeligro.merge(estiloDeBotonDeDialogo),
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(si),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}

/// Cómo se acomodan los botones de un diálogo cuando no caben en una fila (un celular
/// angosto): uno sobre otro, centrados, y el principal (el último) arriba.
const accionesApiladas = (
  alineacion: OverflowBarAlignment.center,
  direccion: VerticalDirection.up,
  separacion: 8.0,
);

/// El botón principal de un diálogo, más bajo que el de las pantallas.
final estiloDeBotonDeDialogo = FilledButton.styleFrom(
  minimumSize: const Size(0, 44),
  padding: const EdgeInsets.symmetric(horizontal: 20),
);
