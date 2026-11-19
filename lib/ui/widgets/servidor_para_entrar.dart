import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/servidor_cubit.dart';
import '../../cuenta/servidor_state.dart';
import 'lista_de_servidores.dart';

/// Lo mismo que [servidorListo], para leerlo una vez (al tocar Enter en el teclado), sin
/// redibujar cuando cambia.
bool servidorDisponibleAhora(BuildContext context) =>
    context.read<ServidorCubit>().state.disponibilidad == Disponibilidad.disponible;

/// Si ya se puede entrar o crear la cuenta: solo con un servidor que contesta.
bool servidorListo(BuildContext context) => context.select(
  (ServidorCubit cubit) =>
      cubit.state.disponibilidad == Disponibilidad.disponible,
);

/// Lo que falta del servidor para poder entrar, en las pantallas de entrar y crear cuenta:
/// con varios en la red, la lista para elegir uno. Lo demás (buscando, sin servidor) ya lo
/// dice el indicador del servidor: no se repite.
class ServidorParaEntrar extends StatelessWidget {
  const ServidorParaEntrar({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<ServidorCubit, ServidorState>(
      builder: (context, servidor) {
        final cubit = context.read<ServidorCubit>();

        switch (servidor.disponibilidad) {
          // Disponible, buscando o sin servidor: ya lo dice el indicador de abajo.
          case Disponibilidad.disponible ||
              Disponibilidad.revisando ||
              Disponibilidad.noDisponible:
            return const SizedBox.shrink();
          case Disponibilidad.variosEncontrados:
            return Column(
              key: const ValueKey('varios-servidores'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Elige un servidor:', style: textos.titleSmall),
                const SizedBox(height: 8),
                ListaDeServidores(
                  encontrados: servidor.encontrados,
                  actual: servidor.direccion,
                  alElegir: (encontrado) => cubit.elegir(
                    encontrado.direccion,
                    nombre: encontrado.nombre,
                  ),
                  alBuscarDeNuevo: cubit.buscarEnLaRed,
                ),
              ],
            );
        }
      },
    );
  }
}
