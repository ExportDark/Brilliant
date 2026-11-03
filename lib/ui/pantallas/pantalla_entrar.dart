import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_event.dart';
import '../../cuenta/sesion_state.dart';
import '../tema.dart';
import '../widgets/campo_de_contrasena.dart';
import '../widgets/logo_brilliant.dart';
import '../widgets/recuadro_de_aviso.dart';
import 'pantalla_crear_cuenta.dart';

/// "Iniciar sesión": la pantalla con la que arranca la app si no hay sesión.
/// Sin sesión no se puede jugar; desde aquí también se crea la cuenta.
class PantallaEntrar extends StatefulWidget {
  const PantallaEntrar({super.key});

  @override
  State<PantallaEntrar> createState() => _PantallaEntrarState();
}

class _PantallaEntrarState extends State<PantallaEntrar> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();

  SesionBloc get _sesion => context.read<SesionBloc>();

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _entrar() {
    if (!_formulario.currentState!.validate()) return;
    _sesion.add(EntradaPedida(usuario: _usuario.text.trim(), contrasena: _contrasena.text));
  }

  /// Al escribir de nuevo, el error del intento anterior ya no aplica.
  void _alCambiar(String _) {
    if (_sesion.state.error != null || _sesion.state.aviso != null) {
      _sesion.add(const AvisosDescartados());
    }
  }

  void _irACrearCuenta() {
    _sesion.add(const AvisosDescartados());
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaCrearCuenta()));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return BlocBuilder<SesionBloc, SesionState>(
      builder: (context, state) {
        final error = state.error;
        final aviso = state.aviso;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formulario,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LogoBrilliant(),
                          const SizedBox(height: 6),
                          Text(
                            'Inicia sesión para jugar.',
                            textAlign: TextAlign.center,
                            style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
                          ),
                          if (aviso != null) ...[
                            const SizedBox(height: 18),
                            RecuadroDeAviso(
                              aviso,
                              key: const ValueKey('aviso-de-sesion'),
                              icono: Icons.check_circle_outline_rounded,
                            ),
                          ],
                          const SizedBox(height: 28),
                          TextFormField(
                            key: const ValueKey('campo-usuario'),
                            controller: _usuario,
                            enabled: !state.ocupado,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            onChanged: _alCambiar,
                            validator: (texto) =>
                                (texto ?? '').trim().isEmpty ? 'Escribe tu usuario' : null,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                              errorText: error?.de('username'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          CampoDeContrasena(
                            key: const ValueKey('campo-contrasena'),
                            controlador: _contrasena,
                            etiqueta: 'Contraseña',
                            error: error?.de('password'),
                            habilitado: !state.ocupado,
                            alCambiar: _alCambiar,
                            alTerminar: _entrar,
                            validar: (texto) =>
                                (texto ?? '').isEmpty ? 'Escribe tu contraseña' : null,
                          ),
                          if (error != null && error.generales.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            RecuadroDeAviso(
                              error.generales.join('\n'),
                              key: const ValueKey('error-de-cuenta'),
                              icono: Icons.error_outline_rounded,
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: state.ocupado ? null : _entrar,
                            child: state.ocupado ? const _Esperando() : const Text('Entrar'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: state.ocupado ? null : _irACrearCuenta,
                            child: const Text('¿No tienes cuenta? Crea una'),
                          ),
                        ],
                      ),
                    ),
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

/// La ruedita del botón mientras el servidor contesta.
class _Esperando extends StatelessWidget {
  const _Esperando();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}
