// Ayudantes de los tests de la lista de servidores. No termina en `_test.dart`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

/// Una red con varios servidores (uno por cada nombre de [nombres]), y la app con elegida
/// una dirección que ya no contesta: no puede escoger sola. La cuenta 'ana' existe en todos.
Future<ServidorFalso> abrirConVariosServidores(
  WidgetTester tester, {
  Size tamano = const Size(1000, 1400),
  List<String> nombres = const ['ORION', 'VEGA'],
  AlmacenEnMemoria? almacen,
}) async {
  final direcciones = [for (var i = 0; i < nombres.length; i++) '192.168.137.${40 + i}'];
  final servidor = ServidorFalso()
    ..direccion = direcciones.first
    ..cuentas['ana'] = contrasenaDePrueba;
  servidor.otrasDirecciones.addAll(direcciones.skip(1));
  final buscador = BuscadorFalso([
    for (final (i, nombre) in nombres.indexed) anunciado(direcciones[i], pc: nombre),
  ]);
  final elAlmacen = almacen ?? AlmacenEnMemoria();
  elAlmacen.servidor = Uri.parse('https://192.168.137.99:8443/');
  await abrirApp(
    tester,
    servidor: servidor,
    conSesion: false,
    buscador: buscador,
    almacen: elAlmacen,
    tamano: tamano,
  );
  return servidor;
}

final listaDeVarios = find.byKey(const ValueKey('varios-servidores'));
