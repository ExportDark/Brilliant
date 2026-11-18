import 'dart:convert';

import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/multijugador/sala_bloc.dart';
import 'package:brilliant/multijugador/sala_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudantes_salas.dart';

/// Un cliente de salas que habla con un servidor que contesta [cuerpo] con [estado].
ClienteSalasHttp _clienteQueContesta(int estado, String cuerpo) {
  final mock = MockClient((_) async => http.Response.bytes(utf8.encode(cuerpo), estado));
  final cuentas = ClienteCuentas(mock, Uri.parse('https://servidor.test:8443/'));
  return ClienteSalasHttp(cuentas, conTokenDePrueba);
}

/// Una sala con un campo de otro tipo: los puntos como texto, como podría mandarlos un
/// servidor de otra versión.
String _salaConPuntosEnTexto() {
  final sala = vistaJson();
  (sala['jugadores'] as List).first['puntos'] = 'diez';
  return jsonEncode(sala);
}

Future<ErrorDeSala> _errorDe(Future<Object?> pedido) async {
  try {
    await pedido;
  } on ErrorDeSala catch (error) {
    return error;
  }
  fail('No se avisó nada');
}

void main() {
  test('Una sala con un campo de otro tipo se avisa como "respuesta rara", no como un error '
      'que nadie atrapa', () async {
    final cliente = _clienteQueContesta(201, _salaConPuntosEnTexto());

    final error = await _errorDe(cliente.crear());

    expect(error.codigo, 'respuesta_rara');
    expect(error.mensaje, contains('no entiende'));
  });

  test('Una respuesta que no es JSON (una página de un proxy, por ejemplo), también', () async {
    final cliente = _clienteQueContesta(200, '<html>Hola</html>');

    expect((await _errorDe(cliente.estado('K7M4QX'))).codigo, 'respuesta_rara');
  });

  test('Un rechazo con el código de otro tipo, también', () async {
    final cliente = _clienteQueContesta(409, jsonEncode({'codigo': 5, 'detail': 'algo'}));

    expect((await _errorDe(cliente.unirse('K7M4QX'))).codigo, 'respuesta_rara');
  });

  test('Con una respuesta rara, la sala no queda trabada: avisa y se puede volver a tocar', () async {
    final bloc = SalaBloc(
      _clienteQueContesta(201, _salaConPuntosEnTexto()),
      intervalo: null,
    );
    addTearDown(bloc.close);

    bloc.add(const SalaCreada());
    await bloc.stream.firstWhere((estado) => !estado.ocupado && estado.error != null);

    expect(bloc.state.ocupado, isFalse);
    expect(bloc.state.error, contains('no entiende'));
    expect(bloc.state.vista, isNull);
  });
}
