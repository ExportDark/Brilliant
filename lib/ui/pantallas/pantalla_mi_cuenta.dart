import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_event.dart';
import '../../cuenta/sesion_state.dart';
import '../tema.dart';
import '../widgets/campo_de_contrasena.dart';
import '../widgets/recuadro_de_aviso.dart';

/// "Mi cuenta": el usuario de la sesión, cerrar sesión y borrar la cuenta.
/// Se abre desde el ícono de persona de "Elige un mapa".
///
/// Borrar la cuenta pide la contraseña en un diálogo, porque no se puede
/// deshacer. Al cerrar sesión o borrar la cuenta, la app vuelve sola a
/// "Iniciar sesión".
class PantallaMiCuenta extends StatelessWidget {
  const PantallaMiCuenta({super.key});

  Future<void> _preguntarSiBorrar(BuildContext context) {
    context.read<SesionBloc>().add(const AvisosDescartados());
    return showDialog<void>(
      context: context,
      builder: (_) => const _DialogoBorrarCuenta(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<SesionBloc, SesionState>(
      builder: (context, state) {
        final usuario = state.usuario ?? '';

        return Scaffold(
          appBar: AppBar(title: const Text('Mi cuenta')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Paleta.acento,
                          child: Text(
                            usuario.isEmpty ? '?' : usuario.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        usuario,
                        key: const ValueKey('usuario-de-la-sesion'),
                        textAlign: TextAlign.center,
                        style: textos.headlineSmall?.copyWith(
                          color: Paleta.tinta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tienes la sesión iniciada en este aparato.',
                        textAlign: TextAlign.center,
                        style: textos.bodyMedium?.copyWith(color: Paleta.tintaSuave),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.tonal(
                        onPressed: state.ocupado
                            ? null
                            : () => context.read<SesionBloc>().add(const SalidaPedida()),
                        child: const _TextoConIcono(Icons.logout_rounded, 'Cerrar sesión'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Paleta.peligro),
                        onPressed: state.ocupado ? null : () => _preguntarSiBorrar(context),
                        child: const _TextoConIcono(Icons.delete_forever_rounded, 'Borrar cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// El diálogo que confirma el borrado con la contraseña. Si el servidor la
/// rechaza, el error aparece en el campo y la cuenta sigue.
class _DialogoBorrarCuenta extends StatefulWidget {
  const _DialogoBorrarCuenta();

  @override
  State<_DialogoBorrarCuenta> createState() => _DialogoBorrarCuentaState();
}

class _DialogoBorrarCuentaState extends State<_DialogoBorrarCuenta> {
  final _formulario = GlobalKey<FormState>();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _contrasena.dispose();
    super.dispose();
  }

  void _borrar() {
    if (!_formulario.currentState!.validate()) return;
    context.read<SesionBloc>().add(BorradoPedido(contrasena: _contrasena.text));
  }

  void _cancelar() {
    context.read<SesionBloc>().add(const AvisosDescartados());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SesionBloc, SesionState>(
      builder: (context, state) {
        final error = state.error;

        return AlertDialog(
          // En un celular bajo, con el teclado abierto, el diálogo se desplaza
          // en vez de desbordarse.
          scrollable: true,
          icon: const Icon(Icons.warning_amber_rounded, color: Paleta.peligro, size: 36),
          title: const Text('¿Borrar tu cuenta?'),
          content: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Se borra para siempre, con todas sus sesiones. No se puede deshacer. '
                  'Escribe tu contraseña para confirmar.',
                ),
                const SizedBox(height: 16),
                CampoDeContrasena(
                  key: const ValueKey('campo-contrasena-borrar'),
                  controlador: _contrasena,
                  etiqueta: 'Tu contraseña',
                  error: error?.de('current_password'),
                  habilitado: !state.ocupado,
                  pistasDeAutocompletado: const [],
                  alTerminar: _borrar,
                  validar: (texto) =>
                      (texto ?? '').isEmpty ? 'Escribe tu contraseña para confirmar' : null,
                ),
                if (error != null && error.generales.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  RecuadroDeAviso(
                    error.generales.join('\n'),
                    key: const ValueKey('error-de-cuenta'),
                    icono: Icons.error_outline_rounded,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.ocupado ? null : _cancelar,
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Paleta.peligro,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: state.ocupado ? null : _borrar,
              child: const Text('Borrar cuenta'),
            ),
          ],
        );
      },
    );
  }
}

/// Un ícono y un texto, uno al lado del otro, para el contenido de un botón.
/// Si no cabe (un celular angosto con la letra agrandada), el texto se corta
/// con puntos suspensivos en vez de desbordarse.
class _TextoConIcono extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _TextoConIcono(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
