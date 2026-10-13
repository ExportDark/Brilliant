import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/juego/partida_state.dart';

import '../ayudantes.dart';

void main() {
  test('PartidaState: sin dado ancla elegido no evalúa ni resalta nada, haya tirado o no', () {
    final antesDeTirar = PartidaState(tablero: tableroPartida1());
    final yaTirado = PartidaState(tablero: tableroPartida1(), dados: const [4, 3]);

    for (final estado in [antesDeTirar, yaTirado]) {
      expect(estado.valorAncla, isNull);
      expect(estado.valorAColocar, isNull);
      expect(estado.evaluar(pos('B1')), isNull);
      expect(estado.tieneNumeroBuscado(pos('C1')), isFalse);
      expect(estado.sinJugada, isFalse);
    }
  });
}
