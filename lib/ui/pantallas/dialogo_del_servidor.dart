import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cuenta/buscador_de_servidores.dart';
import '../../cuenta/direccion_del_servidor.dart';
import '../../cuenta/sesion_bloc.dart';
import '../../cuenta/sesion_event.dart';

/// El diálogo para elegir el servidor de cuentas. Al abrirse busca los que
/// hay en la red, y basta con tocar uno. Si no aparece (por ejemplo, en la
/// web, donde no se puede buscar), se escribe la IP de la PC donde corre
/// `servidor\iniciar.bat`, que la muestra al arrancar.
///
/// Al elegir o guardar, el bloc la guarda en el aparato y prueba que el
/// servidor conteste ahí; el resultado aparece en "Iniciar sesión".
class DialogoDelServidor extends StatefulWidget {
  const DialogoDelServidor({super.key});

  @override
  State<DialogoDelServidor> createState() => _DialogoDelServidorState();
}

class _DialogoDelServidorState extends State<DialogoDelServidor> {
  final _formulario = GlobalKey<FormState>();
  late final _bloc = context.read<SesionBloc>();
  late final _direccion = TextEditingController(text: textoDeDireccion(_bloc.servidor));

  /// La búsqueda en la red en curso o la última; `null` si no se puede buscar.
  Future<List<ServidorEncontrado>>? _busqueda;

  @override
  void initState() {
    super.initState();
    if (_bloc.puedeBuscar) _busqueda = _bloc.buscarServidores();
  }

  @override
  void dispose() {
    _direccion.dispose();
    super.dispose();
  }

  void _buscarDeNuevo() {
    // Con llaves: setState no acepta una función que devuelva un Future.
    setState(() {
      _busqueda = _bloc.buscarServidores();
    });
  }

  void _usar(Uri? direccion) {
    _bloc.add(ServidorCambiado(direccion));
    Navigator.of(context).pop();
  }

  void _guardar() {
    if (!_formulario.currentState!.validate()) return;
    _usar(direccionDesdeTexto(_direccion.text));
  }

  @override
  Widget build(BuildContext context) {
    final busqueda = _busqueda;

    return AlertDialog(
      scrollable: true,
      icon: const Icon(Icons.dns_outlined, size: 32),
      title: const Text('Servidor'),
      content: Form(
        key: _formulario,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (busqueda != null) ...[
              Text('En tu red', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _ServidoresDeLaRed(
                busqueda: busqueda,
                actual: _bloc.servidor,
                alElegir: _usar,
                alBuscarDeNuevo: _buscarDeNuevo,
              ),
              const SizedBox(height: 16),
              const Text(
                'O escribe la dirección de la PC. Al arrancar, servidor\\iniciar.bat '
                'muestra cuál.',
              ),
            ] else
              const Text(
                'La dirección de la PC donde corre el servidor. Al arrancar, '
                'servidor\\iniciar.bat muestra cuál escribir.',
              ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('campo-servidor'),
              controller: _direccion,
              // Si se puede buscar, el teclado no tapa lo que se encontró.
              autofocus: busqueda == null,
              autocorrect: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _guardar(),
              validator: (texto) => direccionDesdeTexto(texto ?? '') == null
                  ? 'Escribe una dirección como 192.168.137.252'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                hintText: '192.168.137.252',
                prefixIcon: Icon(Icons.computer_rounded),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_bloc.servidor != _bloc.servidorPorDefecto)
          TextButton(onPressed: () => _usar(null), child: const Text('Restablecer')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Lo que encontró la búsqueda en la red: mientras busca, que está buscando;
/// después, un renglón por servidor para tocarlo, o que no hay ninguno.
class _ServidoresDeLaRed extends StatelessWidget {
  final Future<List<ServidorEncontrado>> busqueda;

  /// El servidor que se usa ahora, que lleva una palomita.
  final Uri actual;

  final void Function(Uri direccion) alElegir;
  final VoidCallback alBuscarDeNuevo;

  const _ServidoresDeLaRed({
    required this.busqueda,
    required this.actual,
    required this.alElegir,
    required this.alBuscarDeNuevo,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: busqueda,
      builder: (context, resultado) {
        if (resultado.connectionState != ConnectionState.done) {
          return const Row(
            key: ValueKey('buscando-servidores'),
            children: [
              SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Flexible(child: Text('Buscando servidores…')),
            ],
          );
        }

        final encontrados = resultado.data ?? const <ServidorEncontrado>[];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (encontrados.isEmpty)
              const Text('No se encontró ningún servidor. Revisa que esté encendido y que '
                  'estés en la misma WiFi.'),
            for (final servidor in encontrados)
              ListTile(
                key: ValueKey('servidor-${textoDeDireccion(servidor.direccion)}'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dns_rounded),
                title: Text(servidor.nombre, overflow: TextOverflow.ellipsis),
                subtitle: Text(textoDeDireccion(servidor.direccion)),
                trailing: servidor.direccion == actual ? const Icon(Icons.check_rounded) : null,
                onTap: () => alElegir(servidor.direccion),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: alBuscarDeNuevo,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Buscar de nuevo'),
              ),
            ),
          ],
        );
      },
    );
  }
}
