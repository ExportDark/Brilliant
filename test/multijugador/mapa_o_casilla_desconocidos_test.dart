import 'dart:convert';

import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudantes_salas.dart';

/// Una sala con un mapa que esta app no tiene, o una casilla que no existe, se avisa al
/// leerla como "respuesta rara". Antes pasaba y rompía la pantalla al dibujarla.
ClienteSalasHttp _clienteQueContesta(Map<String, dynamic> sala) {
  final mock = MockClient(
    (_) async => http.Response.bytes(utf8.encode(jsonEncode(sala)), 200),
  );
  final cuentas = ClienteCuentas(
    mock,
    Uri.parse('https://servidor.test:8443/'),
  );
  return ClienteSalasHttp(cuentas, conTokenDePrueba);
}

Future<String?> codigoDelError(Future<Object?> pedido) async {
  try {
    await pedido;
  } on ErrorDeSala catch (error) {
    return error.codigo;
  }
  return null;
}

void main() {
  test('Un mapa que esta app no tiene', () async {
    final cliente = _clienteQueContesta(vistaJson(nivel: 9));

    expect(await codigoDelError(cliente.estado('K7M4QX')), 'respuesta_rara');
  });

  test('Una casilla que no está en el tablero', () async {
    final cliente = _clienteQueContesta(
      vistaJson(estado: 'jugando', tablero: {'Z9': 3}),
    );

    expect(await codigoDelError(cliente.estado('K7M4QX')), 'respuesta_rara');
  });

  test('Una jugada legal en una casilla que no existe', () async {
    final cliente = _clienteQueContesta(
      vistaJson(
        estado: 'jugando',
        jugadas: [
          {
            'ancla': 1,
            'valor': 3,
            'casillas': ['H1'],
          },
        ],
      ),
    );

    expect(await codigoDelError(cliente.estado('K7M4QX')), 'respuesta_rara');
  });

  test('Una sala de verdad se lee sin problema', () async {
    final cliente = _clienteQueContesta(
      vistaJson(estado: 'jugando', tablero: {'D1': 3}),
    );

    expect(await codigoDelError(cliente.estado('K7M4QX')), isNull);
  });
}
