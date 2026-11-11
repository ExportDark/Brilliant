import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/exportar_para_el_servidor.dart';

/// Sin distinguir saltos de línea: git puede cambiarlos entre Windows y Linux.
String _leer(String ruta) => File(ruta).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  group('Los archivos que comparte el servidor', () {
    test('mapas.json es lo que genera el código actual', () {
      expect(
        _leer('tool/exportado/mapas.json'),
        generarMapas(),
        reason: 'Cambió un mapa. Vuelve a exportar con `dart run tool/exportar_para_el_servidor.dart` '
            'y copia tool/exportado/ a Brilliant-servidor/juego/datos/.',
      );
    });

    test('casos_de_jugadas.json es lo que responden las reglas actuales', () {
      expect(
        _leer('tool/exportado/casos_de_jugadas.json'),
        generarCasos(),
        reason: 'Cambió una regla. Vuelve a exportar con `dart run tool/exportar_para_el_servidor.dart` '
            'y copia tool/exportado/ a Brilliant-servidor/juego/datos/.',
      );
    });

    test('los casos cubren los cuatro resultados y todos los mapas', () {
      final casos = generarCasos();
      for (final resultado in ['valida', 'ocupada', 'sin_vecino', 'regla_rota']) {
        expect(casos, contains('"resultado":"$resultado"'));
      }
      for (final nivel in [1, 2, 3, 4]) {
        expect(casos, contains('"nivel":$nivel'));
      }
    });
  });
}
