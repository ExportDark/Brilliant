import 'package:flutter/material.dart';

import '../../cuenta/buscador_de_servidores.dart';
import '../../cuenta/direccion_del_servidor.dart';
import '../tema.dart';

/// Los servidores que se encontraron en la red: un renglón por servidor para tocarlo, o
/// que no hay ninguno, y "Buscar de nuevo". Lo usan el diálogo del servidor y las
/// pantallas de entrar y crear cuenta.
class ListaDeServidores extends StatelessWidget {
  final List<ServidorEncontrado> encontrados;

  /// El servidor que se usa ahora, que lleva una palomita.
  final Uri actual;

  final void Function(ServidorEncontrado servidor) alElegir;
  final VoidCallback alBuscarDeNuevo;

  const ListaDeServidores({
    super.key,
    required this.encontrados,
    required this.actual,
    required this.alElegir,
    required this.alBuscarDeNuevo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (encontrados.isEmpty)
          const Text(
            'No se encontró ningún servidor. Revisa que esté encendido y que '
            'estés en la misma WiFi.',
          ),
        for (final servidor in encontrados)
          ListTile(
            key: ValueKey('servidor-${textoDeDireccion(servidor.direccion)}'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dns_rounded, color: Paleta.disponible),
            title: Text(servidor.nombre, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Disponible · ${textoDeDireccion(servidor.direccion)}',
            ),
            trailing: servidor.direccion == actual
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () => alElegir(servidor),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('buscar-de-nuevo'),
            onPressed: alBuscarDeNuevo,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Buscar de nuevo'),
          ),
        ),
      ],
    );
  }
}
