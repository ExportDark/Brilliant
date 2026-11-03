import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_event.dart';
import '../../cuenta/sesion_state.dart';
import '../tema.dart';
import '../widgets/campo_de_contrasena.dart';
import '../widgets/recuadro_de_aviso.dart';

/// "Crear cuenta": usuario y contraseña, escrita dos veces. Al crearla se
/// inicia sesión sola y se pasa a elegir el mapa.
///
/// Aquí se revisa solo lo básico (que no falte nada, el largo y que las dos
/// contraseñas coincidan). El resto lo decide el servidor, y sus mensajes
/// aparecen debajo de cada campo.
class PantallaCrearCuenta extends StatefulWidget {
  const PantallaCrearCuenta({super.key});

  /// El largo mínimo de la contraseña, el mismo que pide el servidor.
  static const largoMinimo = 8;

  @override
  State<PantallaCrearCuenta> createState() => _PantallaCrearCuentaState();
}

class _PantallaCrearCuentaState extends State<PantallaCrearCuenta> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  final _repetida = TextEditingController();

  SesionBloc get _sesion => context.read<SesionBloc>();

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    _repetida.dispose();
    super.dispose();
  }

  void _crear() {
    if (!_formulario.currentState!.validate()) return;
    _sesion.add(CuentaPedida(
      usuario: _usuario.text.trim(),
      contrasena: _contrasena.text,
      repetida: _repetida.text,
    ));
  }

  void _alCambiar(String _) {
    if (_sesion.state.error != null) _sesion.add(const AvisosDescartados());
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return PopScope(
      // Al volver a "Iniciar sesión", los errores de aquí ya no aplican.
      onPopInvokedWithResult: (salio, _) {
        if (salio) _sesion.add(const AvisosDescartados());
      },
      child: BlocBuilder<SesionBloc, SesionState>(
        builder: (context, state) {
          final error = state.error;

          return Scaffold(
            appBar: AppBar(title: const Text('Crear cuenta')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formulario,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Elige tu nombre de usuario y una contraseña.',
                              textAlign: TextAlign.center,
                              style: textos.bodyLarge?.copyWith(color: Paleta.tintaSuave),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              key: const ValueKey('campo-usuario-nuevo'),
                              controller: _usuario,
                              enabled: !state.ocupado,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newUsername],
                              onChanged: _alCambiar,
                              validator: (texto) => (texto ?? '').trim().isEmpty
                                  ? 'Elige un nombre de usuario'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                errorText: error?.de('username'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            CampoDeContrasena(
                              key: const ValueKey('campo-contrasena-nueva'),
                              controlador: _contrasena,
                              etiqueta: 'Contraseña',
                              ayuda: 'Al menos ${PantallaCrearCuenta.largoMinimo} caracteres. '
                                  'Que no sea común, ni solo números, ni parecida a tu usuario.',
                              error: error?.de('password'),
                              habilitado: !state.ocupado,
                              accion: TextInputAction.next,
                              pistasDeAutocompletado: const [AutofillHints.newPassword],
                              alCambiar: _alCambiar,
                              validar: (texto) {
                                if ((texto ?? '').isEmpty) return 'Elige una contraseña';
                                if (texto!.length < PantallaCrearCuenta.largoMinimo) {
                                  return 'Al menos ${PantallaCrearCuenta.largoMinimo} caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            CampoDeContrasena(
                              key: const ValueKey('campo-contrasena-repetida'),
                              controlador: _repetida,
                              etiqueta: 'Repite la contraseña',
                              error: error?.de('re_password'),
                              habilitado: !state.ocupado,
                              pistasDeAutocompletado: const [AutofillHints.newPassword],
                              alCambiar: _alCambiar,
                              alTerminar: _crear,
                              validar: (texto) =>
                                  texto != _contrasena.text ? 'Las contraseñas no coinciden' : null,
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
                              onPressed: state.ocupado ? null : _crear,
                              child: state.ocupado
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  : const Text('Crear cuenta'),
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
      ),
    );
  }
}
