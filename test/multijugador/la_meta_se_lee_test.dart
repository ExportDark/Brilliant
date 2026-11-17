import 'package:brilliant/multijugador/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes_salas.dart';

void main() {
  test('La sala trae la meta de puntos que manda el servidor', () {
    expect(VistaDeSala.desdeJson(vistaJson(meta: 24)).meta, 24);
  });

  test('Con un servidor viejo, que no la manda, la meta queda en null', () {
    final json = vistaJson()..remove('meta');

    expect(VistaDeSala.desdeJson(json).meta, isNull);
  });
}
