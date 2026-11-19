import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/servidor_cubit.dart';
import '../../cuenta/servidor_state.dart';
import '../tema.dart';

/// Si el servidor de cuentas está disponible, a la vista: un punto verde y
/// "Servidor disponible", un punto rojo y "Sin servidor", o una ruedita
/// mientras lo busca. Debajo, cómo se llama el servidor, si se sabe (nunca su
/// dirección: es un dato de adentro).
///
/// Se toca para elegir otro servidor ([alTocar]).
class IndicadorDelServidor extends StatelessWidget {
  final VoidCallback? alTocar;

  const IndicadorDelServidor({super.key, this.alTocar});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<ServidorCubit, ServidorState>(
      builder: (context, servidor) {
        final nombre = servidor.nombre;
        final (titulo, detalle) = switch (servidor.disponibilidad) {
          Disponibilidad.revisando => ('Buscando el servidor…', nombre ?? 'Un momento.'),
          Disponibilidad.disponible => (
              'Servidor disponible',
              nombre ?? 'Listo para jugar.',
            ),
          // Deshabilitado (con un pedido en camino), no invita a tocar.
          Disponibilidad.noDisponible => (
              'Sin servidor',
              alTocar == null
                  ? 'No contesta.'
                  : context.read<ServidorCubit>().puedeBuscar
                  ? 'No contesta. Toca para buscar otro.'
                  // En la web no se puede buscar: se escribe la dirección.
                  : 'No contesta. Toca para cambiar la dirección.',
            ),
          Disponibilidad.variosEncontrados => (
              'Hay varios servidores',
              'Elige uno de la lista.',
            ),
        };

        return Material(
          color: Paleta.cartonClaro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Paleta.tinta, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('boton-servidor'),
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 16,
                    child: _Punto(servidor.disponibilidad),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo, style: textos.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          detalle,
                          key: const ValueKey('detalle-del-servidor'),
                          style: textos.bodySmall?.copyWith(color: Paleta.tintaSuave),
                        ),
                      ],
                    ),
                  ),
                  if (alTocar != null)
                    const Icon(Icons.chevron_right_rounded, color: Paleta.tintaSuave),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// El punto de color, o la ruedita mientras revisa.
class _Punto extends StatelessWidget {
  final Disponibilidad disponibilidad;

  const _Punto(this.disponibilidad);

  @override
  Widget build(BuildContext context) {
    final color = switch (disponibilidad) {
      Disponibilidad.revisando => null,
      Disponibilidad.disponible => Paleta.disponible,
      Disponibilidad.noDisponible => Paleta.peligro,
      Disponibilidad.variosEncontrados => Paleta.acento,
    };
    if (color == null) return const CircularProgressIndicator(strokeWidth: 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6)],
      ),
    );
  }
}
