import 'package:flutter/material.dart';

/// Un campo para escribir una contraseña: oculta lo que se escribe, con un
/// ojo para mostrarlo.
class CampoDeContrasena extends StatefulWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final String? ayuda;

  /// El error que mandó el servidor, si hay. El de [validar] lo reemplaza.
  final String? error;
  final FormFieldValidator<String>? validar;
  final ValueChanged<String>? alCambiar;
  final VoidCallback? alTerminar;
  final bool habilitado;
  final TextInputAction accion;
  final Iterable<String> pistasDeAutocompletado;

  const CampoDeContrasena({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.ayuda,
    this.error,
    this.validar,
    this.alCambiar,
    this.alTerminar,
    this.habilitado = true,
    this.accion = TextInputAction.done,
    this.pistasDeAutocompletado = const [AutofillHints.password],
  });

  @override
  State<CampoDeContrasena> createState() => _CampoDeContrasenaState();
}

class _CampoDeContrasenaState extends State<CampoDeContrasena> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controlador,
      obscureText: !_visible,
      enableSuggestions: false,
      autocorrect: false,
      enabled: widget.habilitado,
      textInputAction: widget.accion,
      autofillHints: widget.pistasDeAutocompletado,
      validator: widget.validar,
      onChanged: widget.alCambiar,
      onFieldSubmitted: (_) => widget.alTerminar?.call(),
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        helperText: widget.ayuda,
        errorText: widget.error,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _visible ? 'Ocultar la contraseña' : 'Mostrar la contraseña',
          icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}
