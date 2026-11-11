import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/servidor_cubit.dart';
import '../../cuenta/servidor_state.dart';
import '../tema.dart';
import 'lista_de_servidores.dart';

/// Si ya se puede entrar o crear la cuenta: solo con un servidor que contesta.
bool servidorListo(BuildContext context) => context.select(
  (ServidorCubit cubit) =>
      cubit.state.disponibilidad == Disponibilidad.disponible,
);

/// Lo que falta del servidor para poder entrar, en las pantallas de entrar y crear cuenta:
/// con varios en la red, la lista para elegir uno; sin servidor, qué hacer. Con el servidor
/// disponible no muestra nada.
class ServidorParaEntrar extends StatelessWidget {
  const ServidorParaEntrar({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<ServidorCubit, ServidorState>(
      builder: (context, servidor) {
        final cubit = context.read<ServidorCubit>();

        switch (servidor.disponibilidad) {
          case Disponibilidad.disponible:
            return const SizedBox.shrink();
          case Disponibilidad.revisando:
            return Text(
              'Buscando el servidor…',
              key: const ValueKey('falta-servidor'),
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
            );
          case Disponibilidad.noDisponible:
            return Text(
              cubit.puedeBuscar
                  ? 'No hay servidor. Enciéndelo y toca "Buscar de nuevo", o elige otro abajo.'
                  : 'No hay servidor. Escribe su dirección tocando el cuadro de abajo.',
              key: const ValueKey('falta-servidor'),
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
            );
          case Disponibilidad.variosEncontrados:
            return Column(
              key: const ValueKey('varios-servidores'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hay varios servidores en tu red. Elige uno:',
                  style: textos.titleSmall,
                ),
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
