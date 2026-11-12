// Ayudantes de las pruebas de los tiempos del multijugador. No termina en `_test.dart`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../../../../multijugador/ayudantes_salas.dart';
import '../../ayudantes_pantallas.dart';

/// Abre la sala sola con [vista] y una hora que el test adelanta con [pasar].
Future<({SalasFalsas salas, Future<void> Function(int segundos) pasar})> abrirConReloj(
  WidgetTester tester,
  VistaDeSala vista,
) async {
  final salas = SalasFalsas()..vista = vista;
  var ahora = DateTime(2026, 11, 11, 12);
  await abrirSalaSola(tester, salas, ahora: () => ahora);
  await tocar(tester, find.byKey(const ValueKey('boton-crear-sala')));

  Future<void> pasar(int segundos) async {
    for (var i = 0; i < segundos; i++) {
      ahora = ahora.add(const Duration(seconds: 1));
      await pasarSegundos(tester, 1);
    }
  }

  return (salas: salas, pasar: pasar);
}

String textoDe(WidgetTester tester, Finder finder) => tester.widget<Text>(finder).data!;
