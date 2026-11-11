import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../multijugador/modelos.dart';
import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../../../multijugador/sala_state.dart';
import '../../../modelo/mapa.dart';
import '../../tema.dart';
import '../../widgets/tarjeta_de_mapa.dart';
import 'lista_de_jugadores.dart';

/// El lobby: el código para invitar, quiénes ya entraron, el mapa y "Empezar" (solo el
/// anfitrión, con 2 o más jugadores).
class VistaLobby extends StatelessWidget {
  final VistaDeSala sala;

  const VistaLobby({super.key, required this.sala});

  /// Cuántos jugadores hacen falta para empezar.
  static const minimo = 2;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final bloc = context.read<SalaBloc>();
    final suficientes = sala.jugadores.where((j) => j.activo).length >= minimo;

    return BlocBuilder<SalaBloc, SalaState>(
      builder: (context, state) {
        final libre = !state.ocupado;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Código de la sala',
              textAlign: TextAlign.center,
              style: textos.titleMedium?.copyWith(color: Paleta.tintaSuave),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SelectableText(
                      sala.codigo,
                      key: const ValueKey('codigo-de-sala'),
                      style: textos.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: Paleta.acento,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('copiar-codigo'),
                  tooltip: 'Copiar el código',
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: sala.codigo)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Dicta este código a quien quieras invitar. Pueden entrar hasta 6.',
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
            ),
            const SizedBox(height: 24),
            Text(
              'Jugadores (${sala.jugadores.length}/6)',
              style: textos.titleMedium,
            ),
            const SizedBox(height: 6),
            ListaDeJugadores(jugadores: sala.jugadores, yo: sala.yo.usuario),
            const SizedBox(height: 20),
            Text('Mapa', style: textos.titleMedium),
            const SizedBox(height: 6),
            if (sala.soyElAnfitrion)
              TarjetaDeMapa.rejilla(
                tarjeta: (mapa) => TarjetaDeMapa(
                  mapa: mapa,
                  seleccionada: sala.nivel == mapa.nivel,
                  alElegir: libre ? () => bloc.add(MapaElegido(mapa.nivel)) : null,
                ),
              )
            else ...[
              Text(
                'Lo elige el anfitrión.',
                key: const ValueKey('mapa-elegido'),
                style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
              ),
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TarjetaDeMapa(
                    mapa: mapas.firstWhere((m) => m.nivel == sala.nivel),
                    seleccionada: true,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (sala.soyElAnfitrion) ...[
              FilledButton(
                key: const ValueKey('boton-empezar'),
                onPressed: libre && suficientes
                    ? () => bloc.add(const PartidaEmpezada())
                    : null,
                child: const Text('Empezar'),
              ),
              if (!suficientes)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Hacen falta al menos $minimo jugadores.',
                    key: const ValueKey('faltan-jugadores'),
                    textAlign: TextAlign.center,
                    style: textos.bodyMedium?.copyWith(
                      color: Paleta.tintaSuave,
                    ),
                  ),
                ),
            ] else
              Text(
                'Esperando a que el anfitrión empiece…',
                key: const ValueKey('esperando-al-anfitrion'),
                textAlign: TextAlign.center,
                style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
              ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('boton-salir'),
              onPressed: libre ? () => bloc.add(const Rendirse()) : null,
              child: Text(
                sala.soyElAnfitrion ? 'Cerrar la sala' : 'Salir de la sala',
              ),
            ),
          ],
        );
      },
    );
  }
}
