import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/cliente_cuentas.dart';
import 'package:brilliant/cuenta/cliente_http_io.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';

import '../cuenta/ayudantes_cuenta.dart';

/// Estas pruebas juegan partidas de verdad contra el servidor, por HTTPS, con varios
/// jugadores que son clientes distintos. No corren con el `flutter test` de siempre: hay que
/// levantar el servidor (`Brilliant-servidor\iniciar.bat`) y pedirlas con
/// `flutter test --dart-define=CON_SERVIDOR=true test/multijugador/contra_el_servidor_test.dart`.
const _conServidor = bool.fromEnvironment('CON_SERVIDOR');
const _sinServidor = 'Necesita el servidor corriendo y --dart-define=CON_SERVIDOR=true';

final _servidor = Uri.parse('https://localhost:8443/');

/// Un jugador: su sesión y su cliente de salas.
class Jugador {
  final String usuario;
  final ClienteCuentas cuentas;
  String? _token;
  String get token => _token!;
  set token(String valor) => _token = valor;
  late final ClienteSalas salas;

  Jugador(this.usuario, this.cuentas);

  /// El servidor limita los inicios de sesión (5 por minuto): si regula, se espera.
  Future<String> _entrarSinPrisa() async {
    for (var intento = 0; intento < 3; intento++) {
      try {
        return await cuentas.entrar(usuario: usuario, contrasena: contrasenaDePrueba);
      } on ErrorDeCuenta catch (error) {
        if (!error.toString().contains('regulada') || intento == 2) rethrow;
        await Future<void>.delayed(const Duration(seconds: 61));
      }
    }
    throw StateError('inalcanzable');
  }

  Future<void> entrar() async {
    try {
      token = await _entrarSinPrisa();
    } on ErrorDeCuenta {
      await cuentas.crearCuenta(
        usuario: usuario,
        contrasena: contrasenaDePrueba,
        repetida: contrasenaDePrueba,
      );
      token = await _entrarSinPrisa();
    }
    salas = ClienteSalasHttp(cuentas, <T>(pedido) => pedido(token));
  }

  Future<void> salir() async {
    if (_token != null) await cuentas.salir(token);
  }

  /// Reparte mis números iniciales: se prueban repartos al azar hasta que el servidor
  /// acepta uno (cada mapa tiene sus reglas).
  Future<VistaDeSala> repartir(VistaDeSala sala, Random azar) async {
    for (var intento = 0; intento < 500; intento++) {
      final numeros = [1, 2, 3, 4, 5, 6]..shuffle(azar);
      final valores = {
        for (final (i, casilla) in sala.yo.iniciales.indexed) casilla: numeros[i],
      };
      try {
        return await salas.preparar(sala.codigo, valores);
      } on ErrorDeSala catch (error) {
        if (error.codigo != 'preparacion_invalida') rethrow;
      }
    }
    fail('El servidor no aceptó ningún reparto para $usuario');
  }

  /// Hace lo que me toca en la ronda: anotar en la primera casilla legal, o pasar.
  Future<VistaDeSala> jugarLaRonda(VistaDeSala sala) async {
    if (!sala.yo.activo || sala.yo.accion != 'pendiente') return sala;
    try {
      if (sala.yo.puedeJugar) {
        final jugada = sala.yo.jugadas.firstWhere((j) => j.casillas.isNotEmpty);
        return await salas.jugar(
          sala.codigo,
          ronda: sala.ronda,
          dadoAncla: jugada.ancla,
          casilla: jugada.casillas.first,
        );
      }
      return await salas.pasar(sala.codigo, ronda: sala.ronda);
    } on ErrorDeSala catch (error) {
      // La ronda cambió justo en medio: no pasa nada, se vuelve a preguntar.
      if (error.codigo == 'ronda_incorrecta' || error.codigo == 'ya_jugaste') return sala;
      rethrow;
    }
  }
}

late Jugador ana, beto, carla;

/// Juega hasta que la partida termina, con cada jugador de [activos] haciendo lo suyo.
Future<VistaDeSala> jugarHastaElFinal(
  String codigo,
  List<Jugador> activos, {
  Future<void> Function(int ronda)? alEmpezarRonda,
}) async {
  var ronda = 0;
  final limite = DateTime.now().add(const Duration(minutes: 3));
  while (DateTime.now().isBefore(limite)) {
    VistaDeSala? ultima;
    for (final jugador in List.of(activos)) {
      var sala = (await jugador.salas.estado(codigo))!;
      if (sala.estado == EstadoDeSala.terminada) return sala;
      if (sala.ronda != ronda) {
        ronda = sala.ronda;
        await alEmpezarRonda?.call(ronda);
      }
      sala = await jugador.jugarLaRonda(sala);
      ultima = sala;
    }
    if (ultima?.estado == EstadoDeSala.terminada) return ultima!;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('La partida $codigo no terminó en 3 minutos');
}

/// Una sala con [jugadores] ya en la partida, con todos repartidos.
Future<String> empezarPartida(List<Jugador> jugadores, int nivel, Random azar) async {
  final anfitrion = jugadores.first;
  final codigo = (await anfitrion.salas.crear()).codigo;
  for (final otro in jugadores.skip(1)) {
    await otro.salas.unirse(codigo);
  }
  await anfitrion.salas.elegirMapa(codigo, nivel);
  var sala = await anfitrion.salas.empezar(codigo);
  expect(sala.estado, EstadoDeSala.preparando);
  for (final jugador in jugadores) {
    sala = (await jugador.salas.estado(codigo))!;
    await jugador.repartir(sala, azar);
  }
  sala = (await anfitrion.salas.estado(codigo))!;
  expect(sala.estado, EstadoDeSala.jugando);
  return codigo;
}

Future<ErrorDeSala> errorDe(Future<Object?> pedido) async {
  try {
    await pedido;
  } on ErrorDeSala catch (error) {
    return error;
  }
  fail('El servidor no rechazó el pedido');
}

void main() {
  setUpAll(() async {
    if (!_conServidor) return;
    final ca = File('assets/certificados/brilliant_ca.pem').readAsBytesSync();
    Jugador nuevo(String usuario) => Jugador(usuario, ClienteCuentas(clienteQueSoloConfiaEn(ca), _servidor));
    ana = nuevo('prueba_sala_ana');
    beto = nuevo('prueba_sala_beto');
    carla = nuevo('prueba_sala_carla');
    for (final jugador in [ana, beto, carla]) {
      await jugador.entrar();
    }
  });

  tearDownAll(() async {
    if (!_conServidor) return;
    for (final jugador in [ana, beto, carla]) {
      await jugador.salir();
    }
  });

  for (final nivel in [1, 2, 3, 4]) {
    test(
      'Una partida entera de 2 jugadores en el mapa $nivel termina bien, y se puede jugar otra '
      'enseguida con las mismas sesiones',
      () async {
        final azar = Random(nivel);
        for (var partida = 1; partida <= 2; partida++) {
          final codigo = await empezarPartida([ana, beto], nivel, azar);

          final fin = await jugarHastaElFinal(codigo, [ana, beto]);

          expect(fin.resultado, isNotNull, reason: 'partida $partida');
          expect(fin.resultado!.ranking.map((f) => f.usuario), unorderedEquals([ana.usuario, beto.usuario]));
          expect(fin.resultado!.ganadores, isNotEmpty);
          for (final fila in fin.resultado!.ranking) {
            expect(fila.puntos, greaterThanOrEqualTo(0));
          }
          // Al terminar ya se puede crear otra sala sin salir de la anterior.
          final otra = await ana.salas.crear();
          await ana.salas.rendirse(otra.codigo);
        }
      },
      timeout: const Timeout(Duration(minutes: 8)),
      skip: _conServidor ? false : _sinServidor,
    );
  }

  test(
    'Con 3 jugadores, uno se rinde a mitad de la partida: la partida sigue y él no gana',
    () async {
      final codigo = await empezarPartida([ana, beto, carla], 2, Random(5));

      final activos = [ana, beto, carla];
      final fin = await jugarHastaElFinal(
        codigo,
        activos,
        alEmpezarRonda: (ronda) async {
          if (ronda == 3 && activos.remove(carla)) await carla.salas.rendirse(codigo);
        },
      );

      final carlaFila = fin.resultado!.ranking.firstWhere((f) => f.usuario == carla.usuario);
      expect(carlaFila.estado, 'se_rindio');
      expect(fin.resultado!.ganadores, isNot(contains(carla.usuario)));
    },
    timeout: const Timeout(Duration(minutes: 8)),
    skip: _conServidor ? false : _sinServidor,
  );

  test(
    'Si un jugador deja de preguntar 10 segundos queda fuera, y con 2 jugadores gana el otro',
    () async {
      final codigo = await empezarPartida([ana, beto], 2, Random(6));

      // Beto desaparece (se le fue la señal). Ana sigue preguntando cada segundo.
      final limite = DateTime.now().add(const Duration(seconds: 40));
      VistaDeSala sala = (await ana.salas.estado(codigo))!;
      while (sala.estado != EstadoDeSala.terminada && DateTime.now().isBefore(limite)) {
        sala = await ana.jugarLaRonda(sala);
        await Future<void>.delayed(const Duration(seconds: 1));
        sala = (await ana.salas.estado(codigo)) ?? sala;
      }

      expect(sala.estado, EstadoDeSala.terminada);
      expect(sala.resultado!.ganadores, [ana.usuario]);
      expect(
        sala.resultado!.ranking.firstWhere((f) => f.usuario == beto.usuario).estado,
        'desconectado',
      );
      // Beto vuelve a preguntar y se entera, sin errores.
      final vistaDeBeto = await beto.salas.estado(codigo);
      expect(vistaDeBeto?.estado ?? EstadoDeSala.terminada, EstadoDeSala.terminada);
    },
    timeout: const Timeout(Duration(minutes: 2)),
    skip: _conServidor ? false : _sinServidor,
  );

  test(
    'Si el anfitrión se va en el lobby, la sala termina para todos; y los errores de salas',
    () async {
      final codigo = (await ana.salas.crear()).codigo;
      await beto.salas.unirse(codigo);

      // Una persona no puede estar en dos salas, ni unirse dos veces.
      expect((await errorDe(ana.salas.crear())).estadoHttp, 409);
      expect((await errorDe(beto.salas.unirse(codigo))).estadoHttp, 409);
      // Un código que no existe, o mal escrito.
      expect((await errorDe(carla.salas.unirse('ZZZZZZ'))).estadoHttp, 404);
      expect((await errorDe(carla.salas.unirse('  '))).estadoHttp, anyOf(404, 400));
      // Quien no es el anfitrión no empieza, y con uno solo tampoco.
      expect((await errorDe(beto.salas.empezar(codigo))).estadoHttp, 403);
      // Quien no está en la sala no la ve.
      expect((await errorDe(carla.salas.estado(codigo))).estadoHttp, 403);

      final cerrada = await ana.salas.rendirse(codigo);
      expect(cerrada?.resultado?.motivo, 'anfitrion_se_fue');
      final vistaDeBeto = await beto.salas.estado(codigo);
      expect(vistaDeBeto?.estado, anyOf(EstadoDeSala.terminada, isNull));
    },
    skip: _conServidor ? false : _sinServidor,
  );

  test(
    'Una sala que ya empezó no deja entrar a nadie más, y jugar fuera de turno o con una casilla '
    'inventada se rechaza sin romper la partida',
    () async {
      final codigo = await empezarPartida([ana, beto], 2, Random(8));

      expect((await errorDe(carla.salas.unirse(codigo))).estadoHttp, 409);

      final sala = (await ana.salas.estado(codigo))!;
      // Una casilla que no existe, otra ronda y un dado que no es.
      await errorDe(ana.salas.jugar(codigo, ronda: sala.ronda, dadoAncla: 1, casilla: 'Z9'));
      expect(
        (await errorDe(ana.salas.jugar(codigo, ronda: sala.ronda + 5, dadoAncla: 1, casilla: 'A1'))).codigo,
        'ronda_incorrecta',
      );
      await errorDe(ana.salas.jugar(codigo, ronda: sala.ronda, dadoAncla: 99, casilla: 'A1'));

      // La partida sigue sana: se juega hasta el final.
      final fin = await jugarHastaElFinal(codigo, [ana, beto]);
      expect(fin.estado, EstadoDeSala.terminada);
    },
    timeout: const Timeout(Duration(minutes: 8)),
    skip: _conServidor ? false : _sinServidor,
  );
}
