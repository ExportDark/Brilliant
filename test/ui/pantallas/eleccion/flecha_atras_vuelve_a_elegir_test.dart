import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';

import '../ayudantes_pantallas.dart';

void main() {
  testWidgets('PantallaPreparacion: la flecha de atrás vuelve a elegir el mapa', (tester) async {
    await abrirApp(tester);
    await tocar(tester, tarjetaDe(nivel2));
    expect(find.text('Nivel 2'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(PantallaPreparacion), findsNothing);
    expect(find.text('Elige un mapa'), findsOneWidget);
  });
}
