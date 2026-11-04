import 'buscador_de_servidores.dart';

/// En la web el navegador no deja buscar en la red local.
BuscadorDeServidores crearBuscador() => const SinBuscar();
