import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';

import 'ayudantes_salas.dart';

/// Un servidor que contesta lo que diga [responder], y anota cada pedido.
({ClienteSalasHttp cliente, List<http.Request> pedidos}) _con(
  http.Response Function(http.Request pedido) responder,
) {
  final pedidos = <http.Request>[];
  final mock = MockClient((pedido) async {
    pedidos.add(pedido);
    return responder(pedido);
  });
  final cuentas = ClienteCuentas(mock, Uri.parse('https://servidor.test:8443/'));
  return (cliente: ClienteSalasHttp(cuentas, conTokenDePrueba), pedidos: pedidos);
}

http.Response _json(int estado, Map<String, dynamic> cuerpo) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      estado,
      headers: {'content-type': 'application/json'},
    );

Future<ErrorDeSala> _errorDe(Future<Object?> pedido) async {
  try {
    await pedido;
  } on ErrorDeSala catch (error) {
    return error;
  }
  fail('El servidor no rechazó el pedido');
}

void main() {
  group('ClienteSalasHttp: cada ruta', () {
    test('crear: POST /salas/ con el token, y devuelve la sala', () async {
      final (:cliente, :pedidos) = _con((_) => _json(201, vistaJson()));

      final vista = await cliente.crear();

      expect(vista.codigo, 'K7M4QX');
      expect(pedidos.single.method, 'POST');
      expect(pedidos.single.url.toString(), 'https://servidor.test:8443/salas/');
      expect(pedidos.single.headers['Authorization'], 'Token token-de-prueba');
    });

    test('unirse: el código se manda tal cual, sin espacios', () async {
      final (:cliente, :pedidos) = _con((_) => _json(200, vistaJson()));

      await cliente.unirse('  K7M4QX ');

      expect(pedidos.single.url.path, '/salas/K7M4QX/unirse/');
    });

    test('elegirMapa, empezar y rendirse van a su ruta', () async {
      final (:cliente, :pedidos) = _con(
        (pedido) => pedido.url.path.endsWith('rendirse/')
            ? http.Response('', 204)
            : _json(200, vistaJson()),
      );

      await cliente.elegirMapa('K7M4QX', 3);
      await cliente.empezar('K7M4QX');
      await cliente.rendirse('K7M4QX');

      expect(pedidos.map((p) => p.url.path), [
        '/salas/K7M4QX/mapa/',
        '/salas/K7M4QX/empezar/',
        '/salas/K7M4QX/rendirse/',
      ]);
      expect(jsonDecode(pedidos.first.body), {'nivel': 3});
    });

    test('preparar manda los valores', () async {
      final (:cliente, :pedidos) = _con((_) => _json(200, vistaJson()));

      await cliente.preparar('K7M4QX', {'E1': 1, 'A3': 3});

      expect(pedidos.single.url.path, '/salas/K7M4QX/preparacion/');
      expect(jsonDecode(pedidos.single.body), {
        'valores': {'E1': 1, 'A3': 3},
      });
    });

    test('jugar manda la ronda, el dado ancla y la casilla', () async {
      final (:cliente, :pedidos) = _con((_) => _json(200, vistaJson()));

      await cliente.jugar('K7M4QX', ronda: 2, dadoAncla: 4, casilla: 'D1');

      expect(pedidos.single.url.path, '/salas/K7M4QX/jugada/');
      expect(jsonDecode(pedidos.single.body), {'ronda': 2, 'dado_ancla': 4, 'casilla': 'D1'});
    });

    test('pasar manda la ronda y pasar: true', () async {
      final (:cliente, :pedidos) = _con((_) => _json(200, vistaJson()));

      await cliente.pasar('K7M4QX', ronda: 2);

      expect(jsonDecode(pedidos.single.body), {'ronda': 2, 'pasar': true});
    });

    test('estado: GET con la versión, y un 304 es "no cambió"', () async {
      final (:cliente, :pedidos) = _con((_) => http.Response('', 304));

      final vista = await cliente.estado('K7M4QX', version: 7);

      expect(vista, isNull);
      expect(pedidos.single.method, 'GET');
      expect(pedidos.single.url.toString(), 'https://servidor.test:8443/salas/K7M4QX/?version=7');
    });

    test('estado sin versión pide todo, y un 200 trae la sala', () async {
      final (:cliente, :pedidos) = _con((_) => _json(200, vistaJson(version: 9)));

      final vista = await cliente.estado('K7M4QX');

      expect(vista!.version, 9);
      expect(pedidos.single.url.query, isEmpty);
    });

    test('rendirse: un 204 (se salió del lobby) es null', () async {
      final (:cliente, pedidos: _) = _con((_) => http.Response('', 204));

      expect(await cliente.rendirse('K7M4QX'), isNull);
    });

    test('rendirse en la partida devuelve la sala', () async {
      final (:cliente, pedidos: _) = _con((_) => _json(200, vistaJson(estado: 'terminada')));

      expect((await cliente.rendirse('K7M4QX'))!.estado, EstadoDeSala.terminada);
    });
  });

  group('ClienteSalasHttp: errores', () {
    test('un rechazo del servidor trae su código estable, su mensaje y el código HTTP', () async {
      final (:cliente, pedidos: _) = _con(
        (_) => _json(409, {'codigo': 'sala_llena', 'detail': 'La sala ya tiene 6 jugadores.'}),
      );

      final error = await _errorDe(cliente.unirse('K7M4QX'));

      expect((error.codigo, error.mensaje, error.estadoHttp), (
        'sala_llena',
        'La sala ya tiene 6 jugadores.',
        409,
      ));
    });

    test('una jugada inválida trae su motivo', () async {
      final (:cliente, pedidos: _) = _con(
        (_) => _json(400, {'codigo': 'jugada_invalida', 'detail': 'Ahí no.', 'motivo': 'regla_rota'}),
      );

      final error = await _errorDe(cliente.jugar('K7M4QX', ronda: 1, dadoAncla: 1, casilla: 'D1'));

      expect((error.codigo, error.motivo), ('jugada_invalida', 'regla_rota'));
    });

    test('un 404 es sala_no_existe', () async {
      final (:cliente, pedidos: _) = _con(
        (_) => _json(404, {'codigo': 'sala_no_existe', 'detail': 'No hay sala.'}),
      );

      expect((await _errorDe(cliente.estado('ZZZZZZ'))).codigo, 'sala_no_existe');
    });

    test('un 401 es SesionVencida', () async {
      final (:cliente, pedidos: _) = _con((_) => _json(401, {'detail': 'Token inválido.'}));

      await expectLater(cliente.estado('K7M4QX'), throwsA(isA<SesionVencida>()));
      await expectLater(cliente.crear(), throwsA(isA<SesionVencida>()));
    });

    test('un 500 es error_del_servidor', () async {
      final (:cliente, pedidos: _) = _con((_) => http.Response('boom', 500));

      expect((await _errorDe(cliente.crear())).codigo, 'error_del_servidor');
    });

    test('una respuesta sin código ni mensaje no rompe: es un error genérico', () async {
      final (:cliente, pedidos: _) = _con((_) => _json(400, {}));

      final error = await _errorDe(cliente.crear());

      expect(error.codigo, 'desconocido');
      expect(error.mensaje, isNotEmpty);
    });

    test('sin red es SinConexion', () async {
      final cuentas = ClienteCuentas(
        MockClient((pedido) async => throw http.ClientException('sin red', pedido.url)),
        Uri.parse('https://servidor.test:8443/'),
      );
      final cliente = ClienteSalasHttp(cuentas, conTokenDePrueba);

      await expectLater(cliente.estado('K7M4QX'), throwsA(isA<SinConexion>()));
      await expectLater(cliente.crear(), throwsA(isA<SinConexion>()));
    });

    test('una respuesta que no es lo que se esperaba da un error, no un valor a medias', () async {
      final (:cliente, pedidos: _) = _con((_) => _json(200, {'codigo': 'K7M4QX'}));

      await expectLater(cliente.crear(), throwsA(anything));
    });
  });

  group('ClienteSalasHttp: reintentos', () {
    /// Un servidor cuya primera conexión ya se cerró: el primer intento falla.
    ({ClienteSalasHttp cliente, List<http.Request> intentos}) conexionMuerta() {
      final intentos = <http.Request>[];
      final mock = MockClient((pedido) async {
        intentos.add(pedido);
        if (intentos.length == 1) throw http.ClientException('Connection closed', pedido.url);
        return _json(200, vistaJson());
      });
      final cuentas = ClienteCuentas(mock, Uri.parse('https://servidor.test:8443/'));
      return (cliente: ClienteSalasHttp(cuentas, conTokenDePrueba), intentos: intentos);
    }

    test('preguntar el estado se reintenta una vez: no cambia nada', () async {
      final (:cliente, :intentos) = conexionMuerta();

      await cliente.estado('K7M4QX');

      expect(intentos, hasLength(2));
    });

    test('crear, unirse y jugar no se reintentan solos: el pedido pudo haber llegado', () async {
      for (final pedir in <Future<Object?> Function(ClienteSalasHttp)>[
        (c) => c.crear(),
        (c) => c.unirse('K7M4QX'),
        (c) => c.jugar('K7M4QX', ronda: 1, dadoAncla: 1, casilla: 'D1'),
        (c) => c.rendirse('K7M4QX'),
      ]) {
        final (:cliente, :intentos) = conexionMuerta();

        await expectLater(pedir(cliente), throwsA(isA<SinConexion>()));
        expect(intentos, hasLength(1));
      }
    });
  });

  group('ClienteSalasHttp: el token', () {
    test('cada pedido pasa por conToken: así la sesión se entera si el token no vale', () async {
      final cuenta = ConTokenQueCuenta();
      final mock = MockClient((_) async => _json(200, vistaJson()));
      final cliente = ClienteSalasHttp(
        ClienteCuentas(mock, Uri.parse('https://servidor.test:8443/')),
        cuenta.llamar,
      );

      await cliente.crear();
      await cliente.estado('K7M4QX');
      await cliente.unirse('K7M4QX');

      expect(cuenta.usos, 3);
    });
  });
}
