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

/// Los mensajes de la sala: cortos, que dicen lo que pasó, y nada cuando la pantalla ya lo
/// muestra.
void main() {
  late SalasFalsas salas;
  late SalaBloc bloc;

  setUp(() {
    salas = SalasFalsas();
    bloc = SalaBloc(salas, intervalo: null);
  });
  tearDown(() => bloc.close());

  Future<void> mandar(SalaEvent evento) async {
    bloc.add(evento);
    await pumpEventQueue();
  }

  Future<String?> errorAlJugar(ErrorDeSala rechazo) async {
    salas.vista = partidaEnJuego();
    await mandar(const SalaCreada());
    salas.errorEnElProximo = rechazo;
    await mandar(const JugadaEnviada(ronda: 1, dadoAncla: 1, casilla: 'D1'));
    return bloc.state.error;
  }

  ErrorDeSala rechazo(String codigo, {String? motivo}) => ErrorDeSala(
    codigo: codigo,
    mensaje: 'texto del servidor',
    estadoHttp: 409,
    motivo: motivo,
  );

  test('Lo que la pantalla ya muestra no se dice', () async {
    for (final codigo in [
      'estado_incorrecto',
      'pocos_jugadores',
      'no_activo',
    ]) {
      expect(await errorAlJugar(rechazo(codigo)), isNull, reason: codigo);
    }
  });

  test('Una jugada rechazada dice por qué, corto', () async {
    expect(
      await errorAlJugar(rechazo('jugada_invalida', motivo: 'ocupada')),
      'Esa casilla ya tiene número.',
    );
    expect(
      await errorAlJugar(rechazo('jugada_invalida', motivo: 'sin_vecino')),
      'Esa casilla no está junto al número del dado ancla.',
    );
    expect(
      await errorAlJugar(rechazo('jugada_invalida', motivo: 'regla_rota')),
      'Esa zona no acepta ese número.',
    );
    expect(
      await errorAlJugar(rechazo('ronda_incorrecta')),
      'La ronda ya cambió.',
    );
  });

  test(
    'Sin conexión en una acción: "Sin conexión. Intenta de nuevo."',
    () async {
      salas.vista = partidaEnJuego();
      await mandar(const SalaCreada());
      salas.sinConexion = true;

      await mandar(const JugadaEnviada(ronda: 1, dadoAncla: 1, casilla: 'D1'));

      expect(bloc.state.error, 'Sin conexión. Intenta de nuevo.');
    },
  );

  group('Lo que contesta el servidor', () {
    ClienteSalasHttp clienteQueContesta(int estado, String cuerpo) {
      final mock = MockClient(
        (_) async => http.Response.bytes(utf8.encode(cuerpo), estado),
      );
      return ClienteSalasHttp(
        ClienteCuentas(mock, Uri.parse('https://servidor.test:8443/')),
        conTokenDePrueba,
      );
    }

    Future<ErrorDeSala> errorDe(Future<Object?> pedido) async {
      try {
        await pedido;
      } on ErrorDeSala catch (error) {
        return error;
      }
      fail('No dio error');
    }

    test(
      'Un rechazo sin código (el de DRF, en inglés) no se muestra tal cual',
      () async {
        final cliente = clienteQueContesta(
          400,
          jsonEncode({
            'detail':
                'JSON parse error - Expecting value: line 1 column 1 (char 0)',
          }),
        );

        final error = await errorDe(cliente.unirse('K7M4QX'));

        expect(
          error.mensaje,
          'El servidor tuvo un problema. Intenta de nuevo.',
        );
      },
    );

    test('Una respuesta que la app no entiende', () async {
      final error = await errorDe(
        clienteQueContesta(200, '<html></html>').estado('K7M4QX'),
      );

      expect(
        error.mensaje,
        'La app no es compatible con este servidor. Actualízala.',
      );
    });
  });
}
