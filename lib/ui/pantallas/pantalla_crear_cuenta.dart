import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/reglas_de_cuenta.dart';
import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_event.dart';
import '../../cuenta/sesion_state.dart';
import '../tema.dart';
import '../widgets/campo_de_contrasena.dart';
import '../widgets/indicador_del_servidor.dart';
import '../widgets/recuadro_de_aviso.dart';
import '../widgets/servidor_para_entrar.dart';
import 'dialogo_del_servidor.dart';
import '../widgets/piezas.dart';

/// "Crear cuenta": usuario y contraseña, escrita dos veces. Al crearla se
/// inicia sesión sola y se pasa a elegir el mapa.
///
/// Aquí se revisan las reglas de `reglas_de_cuenta.dart` (el nombre de
/// usuario, el largo de la contraseña) y que las dos contraseñas coincidan,
/// antes de mandar nada. El resto lo decide el servidor (que el usuario no
/// exista, que la contraseña no sea común), y sus mensajes aparecen debajo de
/// cada campo.
class PantallaCrearCuenta extends StatefulWidget {
  const PantallaCrearCuenta({super.key});

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

  /// Si se vuelve a "Iniciar sesión" porque la cuenta se creó: el aviso se queda.
  var _volviendoConLaCuenta = false;

  void _crear() {
    // Enter en el teclado respeta lo mismo que el botón.
    if (_sesion.state.ocupado || !servidorDisponibleAhora(context)) return;
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

    final hayServidor = servidorListo(context);
    final ocupado = context.select((SesionBloc bloc) => bloc.state.ocupado);

    return PopScope(
      // Mientras se crea la cuenta no se sale: se perdería lo que conteste el servidor.
      canPop: !ocupado,
      // Al volver a "Iniciar sesión", los errores de aquí ya no aplican.
      onPopInvokedWithResult: (salio, _) {
        if (salio && !_volviendoConLaCuenta) _sesion.add(const AvisosDescartados());
      },
      child: BlocConsumer<SesionBloc, SesionState>(
        // Si la cuenta se creó pero no se pudo entrar, vuelve a "Iniciar sesión", con el
        // aviso y el usuario escrito.
        listenWhen: (antes, ahora) =>
            antes.aviso != ahora.aviso && ahora.aviso == SesionBloc.cuentaCreada,
        listener: (context, _) {
          _volviendoConLaCuenta = true;
          Navigator.of(context).pop(_usuario.text.trim());
        },
        builder: (context, state) {
          final error = state.error;

          return Scaffold(
            appBar: AppBar(title: const Text('Crear cuenta')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Center(
                  child: Bandeja(
                    anchoMaximo: 420,
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
                              maxLength: largoMaximoUsuario,
                              onChanged: _alCambiar,
                              validator: (texto) => problemaConElUsuario((texto ?? '').trim()),
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                helperText: 'De $largoMinimoUsuario a $largoMaximoUsuario caracteres: '
                                    'letras sin acento, números, punto, guion y guion bajo.',
                                helperMaxLines: 3,
                                errorMaxLines: 3,
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                errorText: error?.de('username'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            CampoDeContrasena(
                              key: const ValueKey('campo-contrasena-nueva'),
                              controlador: _contrasena,
                              etiqueta: 'Contraseña',
                              ayuda: 'Al menos $largoMinimoContrasena caracteres. '
                                  'Que no sea común, ni solo números, ni parecida a tu usuario.',
                              error: error?.de('password'),
                              habilitado: !state.ocupado,
                              accion: TextInputAction.next,
                              pistasDeAutocompletado: const [AutofillHints.newPassword],
                              alCambiar: _alCambiar,
                              validar: (texto) => problemaConLaContrasena(texto ?? ''),
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
                            PiezaPresionable(child: FilledButton(
                              key: const ValueKey('boton-crear-cuenta'),
                              onPressed: state.ocupado || !hayServidor ? null : _crear,
                              child: state.ocupado
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    )
                                  : const Text('Crear cuenta'),
                            )),
                            const SizedBox(height: 16),
                            const ServidorParaEntrar(),
                            const SizedBox(height: 12),
                            IndicadorDelServidor(
                              alTocar: state.ocupado
                                  ? null
                                  : () => showDialog<void>(
                                        context: context,
                                        builder: (_) => const DialogoDelServidor(),
                                      ),
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
