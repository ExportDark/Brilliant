import 'package:flutter_test/flutter_test.dart';

import '../../../../cuenta/ayudantes_cuenta.dart';
import '../../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaEntrar: si el servidor está apagado, lo dice antes de intentar entrar',
      (tester) async {
    final servidor = ServidorFalso()..apagado = true;
    await abrirApp(tester, servidor: servidor, conSesion: false, buscador: BuscadorFalso());

    expect(
      indicadorDelServidor(tester),
      'Sin servidor · No contesta en servidor.test. Toca para buscar otro.',
    );
  });
}
