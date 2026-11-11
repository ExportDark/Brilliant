import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../multijugador/sala_bloc.dart';
import '../../../multijugador/sala_event.dart';
import '../../../multijugador/sala_state.dart';
import '../../tema.dart';

/// Antes de estar en una sala: crear una, o unirse con el código que dictó quien la creó.
class VistaSinSala extends StatefulWidget {
  const VistaSinSala({super.key});

  @override
  State<VistaSinSala> createState() => _VistaSinSalaState();
}

class _VistaSinSalaState extends State<VistaSinSala> {
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _unirse() => context.read<SalaBloc>().add(UnirseConCodigo(_codigo.text));

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<SalaBloc, SalaState>(
      builder: (context, state) {
        final libre = !state.ocupado;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Jugar con otros',
              textAlign: TextAlign.center,
              style: textos.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Crea una sala y dicta el código, o entra a la de otro jugador. '
              'Pueden jugar de 2 a 6.',
              textAlign: TextAlign.center,
              style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('boton-crear-sala'),
              onPressed: libre
                  ? () => context.read<SalaBloc>().add(const SalaCreada())
                  : null,
              child: const Text('Crear sala'),
            ),
            const SizedBox(height: 28),
            TextField(
              key: const ValueKey('campo-codigo'),
              controller: _codigo,
              enabled: libre,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.go,
              maxLength: 6,
              inputFormatters: [
                // El código solo tiene letras y números.
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                TextInputFormatter.withFunction(
                  (anterior, nuevo) =>
                      nuevo.copyWith(text: nuevo.text.toUpperCase()),
                ),
              ],
              onSubmitted: (_) => _unirse(),
              decoration: const InputDecoration(
                labelText: 'Código de la sala',
                prefixIcon: Icon(Icons.key_outlined),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const ValueKey('boton-unirse'),
              onPressed: libre ? _unirse : null,
              child: state.ocupado
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Unirme'),
            ),
          ],
        );
      },
    );
  }
}
