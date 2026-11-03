import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/main.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/ui/pantallas/pantalla_entrar.dart';

import '../../cuenta/ayudantes_cuenta.dart';
import '../../juego/ayudantes.dart';
import '../pantallas/ayudantes_pantallas.dart';

void main() {
  testWidgets('Camino feliz de las cuentas: crear la cuenta, jugar, cerrar sesión, volver a '
      'entrar, reabrir la app y borrar la cuenta', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final servidor = ServidorFalso();
    final almacen = AlmacenEnMemoria();
    Future<void> abrirLaApp() async {
      await tester.pumpWidget(
        BrilliantApp(cuentas: servidor.cliente(), almacen: almacen, tirarDado: dadoConCaras([4, 3])),
      );
      await tester.pumpAndSettle();
    }

    // 1. Sin cuenta, la app pide iniciar sesión.
    await abrirLaApp();
    expect(find.byType(PantallaEntrar), findsOneWidget);

    // 2. Crear la cuenta lleva directo a elegir el mapa.
    await tocar(tester, enlaceCrearCuenta);
    await escribir(tester, 'campo-usuario-nuevo', 'carla');
    await escribir(tester, 'campo-contrasena-nueva', contrasenaDePrueba);
    await escribir(tester, 'campo-contrasena-repetida', contrasenaDePrueba);
    await tocar(tester, botonCrearCuenta);
    expect(find.text('Elige un mapa'), findsOneWidget);

    // 3. Con la sesión iniciada se juega: un turno del Nivel 1, y se sale.
    await tocar(tester, tarjetaDe(nivel1));
    await tocar(tester, find.widgetWithText(TextButton, 'Aleatorio'));
    await tocar(tester, find.widgetWithText(FilledButton, 'Inicio'));
    await tocar(tester, botonTirar);
    expect(find.text('Turno 1'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.widgetWithText(FilledButton, 'Salir'));
    expect(find.text('Elige un mapa'), findsOneWidget);

    // 4. Cerrar sesión vuelve a "Iniciar sesión".
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(FilledButton, 'Cerrar sesión'));
    expect(find.text('Cerraste sesión.'), findsOneWidget);

    // 5. Volver a entrar con la misma cuenta.
    await entrarCon(tester, 'carla', contrasenaDePrueba);
    expect(find.text('Elige un mapa'), findsOneWidget);

    // 6. Al reabrir la app, la sesión se recuerda: no hay que volver a entrar.
    await tester.pumpWidget(const SizedBox());
    await abrirLaApp();
    expect(find.text('Elige un mapa'), findsOneWidget);
    expect(find.byType(PantallaEntrar), findsNothing);

    // 7. Borrar la cuenta, confirmando con la contraseña.
    await tocar(tester, botonMiCuenta);
    await tocar(tester, find.widgetWithText(TextButton, 'Borrar cuenta'));
    await escribir(tester, 'campo-contrasena-borrar', contrasenaDePrueba);
    await tocar(tester, find.widgetWithText(FilledButton, 'Borrar cuenta'));
    expect(find.text('Tu cuenta se borró.'), findsOneWidget);
    expect(servidor.cuentas, isEmpty);
    expect(almacen.sesion, isNull);

    // 8. Con la cuenta borrada ya no se puede entrar.
    await entrarCon(tester, 'carla', contrasenaDePrueba);
    expect(
      find.text('No puede iniciar sesión con las credenciales proporcionadas.'),
      findsOneWidget,
    );
  });
}
