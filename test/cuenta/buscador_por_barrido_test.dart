import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/cuenta/buscador_de_servidores_io.dart';

void main() {
  group('BuscadorPorBarrido', () {
    test('prueba las otras 253 direcciones de la red del aparato y devuelve las que contestan, '
        'en orden y sin nombre', () async {
      final probadas = <String>[];
      final buscador = BuscadorPorBarrido(
        misIps: () async => ['192.168.1.37'],
        puertoAbierto: (ip) async {
          probadas.add(ip);
          return ip == '192.168.1.200' || ip == '192.168.1.10';
        },
      );

      final encontrados = await buscador.buscar();

      expect(probadas, hasLength(253));
      expect(probadas, isNot(contains('192.168.1.37')), reason: 'la propia no');
      expect(probadas.every((ip) => ip.startsWith('192.168.1.')), isTrue);
      expect(encontrados, [
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.1.10:8443/')),
        ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.1.200:8443/')),
      ]);
    });

    test('no recorre redes que no son locales, como la de los datos móviles', () async {
      final probadas = <String>[];
      final buscador = BuscadorPorBarrido(
        misIps: () async => ['100.64.12.7', '8.8.8.8'],
        puertoAbierto: (ip) async {
          probadas.add(ip);
          return true;
        },
      );

      expect(await buscador.buscar(), isEmpty);
      expect(probadas, isEmpty);
    });

    test('sin red no prueba nada', () async {
      var probo = false;
      final buscador = BuscadorPorBarrido(
        misIps: () async => const [],
        puertoAbierto: (_) async => probo = true,
      );

      expect(await buscador.buscar(), isEmpty);
      expect(probo, isFalse);
    });

    test('con dos redes (WiFi y hotspot) recorre las dos; con tres, solo las dos primeras', () async {
      final redes = <String>{};
      final buscador = BuscadorPorBarrido(
        misIps: () async => ['192.168.1.37', '10.0.2.15', '172.20.0.5'],
        puertoAbierto: (ip) async {
          redes.add(ip.substring(0, ip.lastIndexOf('.')));
          return false;
        },
      );

      await buscador.buscar();

      expect(redes, {'192.168.1', '10.0.2'});
    });

    test('no prueba más de ${BuscadorPorBarrido.aLaVez} direcciones a la vez', () async {
      var enCurso = 0;
      var maximo = 0;
      final buscador = BuscadorPorBarrido(
        misIps: () async => ['192.168.1.37'],
        puertoAbierto: (ip) async {
          enCurso++;
          maximo = enCurso > maximo ? enCurso : maximo;
          await Future<void>.delayed(const Duration(milliseconds: 1));
          enCurso--;
          return false;
        },
      );

      await buscador.buscar();

      expect(maximo, BuscadorPorBarrido.aLaVez);
    });

    test('esDeRedLocal: 10.x, 172.16 a 172.31 y 192.168; nada más', () {
      for (final ip in ['10.0.2.15', '172.16.0.1', '172.31.255.9', '192.168.137.1']) {
        expect(BuscadorPorBarrido.esDeRedLocal(ip), isTrue, reason: ip);
      }
      for (final ip in ['172.15.0.1', '172.32.0.1', '100.64.0.1', '8.8.8.8', '192.169.0.1', 'x', '1.2.3']) {
        expect(BuscadorPorBarrido.esDeRedLocal(ip), isFalse, reason: ip);
      }
    });
  });

  group('BuscadorCombinado', () {
    test('junta lo que encuentran todos', () async {
      final mdns = _Fijo([ServidorEncontrado(nombre: 'Brilliant en ORION', direccion: Uri.parse('https://192.168.1.10:8443/'))]);
      final barrido = _Fijo([ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.1.20:8443/'))]);

      final todos = await BuscadorCombinado([mdns, barrido]).buscar();

      expect(todos.map((s) => s.direccion.host), ['192.168.1.10', '192.168.1.20']);
    });

    test('si uno falla, cuentan los demás', () async {
      final barrido = _Fijo([ServidorEncontrado(nombre: '', direccion: Uri.parse('https://192.168.1.20:8443/'))]);

      final todos = await BuscadorCombinado([_QueFalla(), barrido]).buscar();

      expect(todos, hasLength(1));
    });

    test('puede buscar si alguno puede', () {
      expect(const BuscadorCombinado([SinBuscar()]).puedeBuscar, isFalse);
      expect(BuscadorCombinado([const SinBuscar(), _Fijo(const [])]).puedeBuscar, isTrue);
    });
  });
}

class _Fijo implements BuscadorDeServidores {
  final List<ServidorEncontrado> encontrados;

  _Fijo(this.encontrados);

  @override
  bool get puedeBuscar => true;

  @override
  Future<List<ServidorEncontrado>> buscar() async => encontrados;
}

class _QueFalla implements BuscadorDeServidores {
  @override
  bool get puedeBuscar => true;

  @override
  Future<List<ServidorEncontrado>> buscar() => Future.error(StateError('sin permiso'));
}
