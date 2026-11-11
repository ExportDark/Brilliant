// Ayudantes compartidos por los tests de pantallas. No termina en
// `_test.dart`, así que `flutter test` no lo corre: solo lo importan los tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/cuenta/buscador_de_servidores.dart';
import 'package:brilliant/multijugador/cliente_salas.dart';
import 'package:brilliant/multijugador/modelos.dart';
import 'package:brilliant/ui/pantallas/multijugador/pantalla_multijugador.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brilliant/main.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/ui/pantallas/pantalla_partida.dart';
import 'package:brilliant/ui/pantallas/pantalla_preparacion.dart';
import 'package:brilliant/ui/widgets/celda_widget.dart';
import 'package:brilliant/ui/widgets/indicador_del_servidor.dart';

import '../../cuenta/ayudantes_cuenta.dart';
import '../../multijugador/ayudantes_salas.dart';
import '../../juego/ayudantes.dart';

/// Los tamaños de pantalla en los que se prueba que todo quepa, en píxeles
/// lógicos (los que usa Flutter, no los físicos del aparato).
const tamanosDePantalla = {
  'celular chico': Size(320, 568),
  'celular': Size(360, 640),
  'celular grande': Size(412, 915),
  'tablet': Size(768, 1024),
  'escritorio': Size(1280, 800),
};

/// Por defecto, una superficie grande: las pantallas son más altas que la
/// superficie de prueba de Flutter.
void _superficie(WidgetTester tester, Size tamano) {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Abre la app entera, como al lanzarla, con dados que decide [tirarDado]
/// (sin él, al azar). Habla con [servidor] (por defecto, uno falso nuevo).
///
/// Con [conSesion], la app ya tiene guardada una sesión de "ana" y arranca
/// directo en "Elige un mapa"; sin ella, en "Iniciar sesión". Con [almacen],
/// usa ese, con lo que tenga guardado. Con [buscador], busca servidores en la
/// red con ese; sin él, no busca. Con [cambiosDeRed], cada evento es como si
/// el aparato cambiara de red; con [revisarCada], revisa solo el servidor
/// mientras no hay; con [latidoCada], avisa al servidor que la sesión sigue
/// en uso.
Future<void> abrirApp(
  WidgetTester tester, {
  int Function()? tirarDado,
  Size tamano = const Size(1000, 1400),
  ServidorFalso? servidor,
  bool conSesion = true,
  AlmacenEnMemoria? almacen,
  BuscadorDeServidores buscador = const SinBuscar(),
  Stream<Object?>? cambiosDeRed,
  Duration? revisarCada,
  Duration? latidoCada,
  ClienteSalas? salas,
}) async {
  _superficie(tester, tamano);
  final elServidor = servidor ?? ServidorFalso();
  final elAlmacen = almacen ??
      AlmacenEnMemoria(conSesion ? elServidor.sesionIniciada('ana') : null);
  await tester.pumpWidget(
    BrilliantApp(
      cuentas: elServidor.cliente(),
      almacen: elAlmacen,
      buscador: buscador,
      cambiosDeRed: cambiosDeRed,
      revisarCada: revisarCada,
      latidoCada: latidoCada,
      salas: salas,
      tirarDado: tirarDado,
    ),
  );
  await tester.pumpAndSettle();
}

/// Abre la preparación de [mapa] (por defecto, el Nivel 1).
Future<void> abrirPreparacion(
  WidgetTester tester, {
  Mapa mapa = nivel1,
  Size tamano = const Size(1000, 1400),
}) async {
  _superficie(tester, tamano);
  await tester.pumpWidget(MaterialApp(home: PantallaPreparacion(mapa: mapa)));
}

/// Abre la partida de [mapa] (por defecto, el Nivel 1) sobre [tablero] (por
/// defecto, el mapa con los números de la Partida 1) con dados que sacan
/// [caras] (por defecto 4 y 3).
Future<void> abrirPartida(
  WidgetTester tester, {
  Mapa mapa = nivel1,
  Tablero? tablero,
  List<int> caras = const [4, 3],
  Size tamano = const Size(1000, 1400),
}) async {
  _superficie(tester, tamano);
  await tester.pumpWidget(
    MaterialApp(
      home: PantallaPartida(
        tablero: tablero ?? tableroPreparado(mapa),
        mapa: mapa,
        tirarDado: dadoConCaras(caras),
      ),
    ),
  );
}

Future<void> tocar(WidgetTester tester, Finder objetivo) async {
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// La tarjeta de [mapa] en la pantalla de elección.
Finder tarjetaDe(Mapa mapa) => find.byKey(ValueKey('mapa-${mapa.nivel}'));

final botonTirar = find.widgetWithText(FilledButton, 'Tirar dados');

/// Escribe [texto] en el campo de clave [clave] (un `TextFormField` o un
/// `CampoDeContrasena`).
Future<void> escribir(WidgetTester tester, String clave, String texto) async {
  await tester.enterText(find.byKey(ValueKey(clave)), texto);
  await tester.pump();
}

final botonEntrar = find.widgetWithText(FilledButton, 'Entrar');

final botonCrearCuenta = find.widgetWithText(FilledButton, 'Crear cuenta');

final enlaceCrearCuenta = find.widgetWithText(TextButton, '¿No tienes cuenta? Crea una');

/// En "Crear cuenta", escribe [usuario] y [contrasena] (dos veces, o la
/// segunda [repetida]) y toca "Crear cuenta".
Future<void> crearCuentaCon(
  WidgetTester tester,
  String usuario,
  String contrasena, {
  String? repetida,
}) async {
  await escribir(tester, 'campo-usuario-nuevo', usuario);
  await escribir(tester, 'campo-contrasena-nueva', contrasena);
  await escribir(tester, 'campo-contrasena-repetida', repetida ?? contrasena);
  await tocar(tester, botonCrearCuenta);
}

/// El error que muestra el campo de clave [clave], o `null` si no tiene.
String? errorDelCampo(WidgetTester tester, String clave) => tester
    .widget<TextField>(
      find.descendant(of: find.byKey(ValueKey(clave)), matching: find.byType(TextField)),
    )
    .decoration
    ?.errorText;

final botonMiCuenta = find.byKey(const ValueKey('boton-mi-cuenta'));

final botonServidor = find.byKey(const ValueKey('boton-servidor'));

/// Lo que dice el indicador del servidor de "Iniciar sesión", con sus textos
/// unidos por " · ". Por ejemplo, "Servidor disponible · servidor.test".
String indicadorDelServidor(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: find.byType(IndicadorDelServidor), matching: find.byType(Text)),
    )
    .map((texto) => texto.data)
    .join(' · ');

/// Escribe [direccion] en el diálogo del servidor y la guarda.
Future<void> cambiarServidor(WidgetTester tester, String direccion) async {
  await tocar(tester, botonServidor);
  await escribir(tester, 'campo-servidor', direccion);
  await tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
}

/// Inicia sesión desde "Iniciar sesión" con [usuario] y [contrasena].
Future<void> entrarCon(WidgetTester tester, String usuario, String contrasena) async {
  await escribir(tester, 'campo-usuario', usuario);
  await escribir(tester, 'campo-contrasena', contrasena);
  await tocar(tester, botonEntrar);
}

final botonPasar = find.widgetWithText(FilledButton, 'Pasar turno');

final explicacion = find.byKey(const ValueKey('explicacion'));

Finder dadoEn(int indice) => find.byKey(ValueKey('dado-$indice'));

/// La casilla [notacion], solo si responde al toque.
Finder casillaTocable(String notacion) => find.byKey(ValueKey('casilla-$notacion'));

/// El dibujo de la casilla [notacion], responda o no al toque.
Finder dibujoDe(String notacion) => find.byWidgetPredicate(
      (widget) => widget is CeldaWidget && widget.celda.posicion == pos(notacion),
    );

CeldaWidget celdaEn(WidgetTester tester, String notacion) =>
    tester.widget<CeldaWidget>(dibujoDe(notacion));

/// Las casillas dibujadas que cumplen [condicion], en notación del manual.
Set<String> celdasDibujadasDonde(WidgetTester tester, bool Function(CeldaWidget) condicion) => {
      for (final celda in tester.widgetList<CeldaWidget>(find.byType(CeldaWidget)))
        if (condicion(celda)) celda.celda.posicion.notacion,
    };

/// Verdadero si el widget de [objetivo] cabe completo a lo ancho de la pantalla.
bool cabeALoAncho(WidgetTester tester, Finder objetivo) {
  final rect = tester.getRect(objetivo);
  final ancho = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  return rect.left >= 0 && rect.right <= ancho;
}

bool habilitado(WidgetTester tester, Finder boton) =>
    tester.widget<ButtonStyleButton>(boton).onPressed != null;

/// Tira los dados y elige como dado ancla el de [indice].
Future<void> tirarYElegirAncla(WidgetTester tester, int indice) async {
  await tocar(tester, botonTirar);
  await tocar(tester, dadoEn(indice));
}

final botonMultijugador = find.byKey(const ValueKey('boton-multijugador'));

/// Abre la app con [salas] (una sala falsa) y entra al multijugador desde "Elige un mapa".
Future<void> abrirMultijugador(
  WidgetTester tester,
  SalasFalsas salas, {
  Size tamano = const Size(1000, 1400),
}) async {
  await abrirApp(tester, salas: salas, tamano: tamano);
  await tocar(tester, botonMultijugador);
}

/// Abre solo la pantalla del multijugador, sin la app alrededor, para controlar cada
/// cuánto pregunta y la hora ([ahora]).
Future<void> abrirSalaSola(
  WidgetTester tester,
  SalasFalsas salas, {
  Duration? intervalo = const Duration(seconds: 1),
  DateTime Function()? ahora,
  Size tamano = const Size(1000, 1400),
}) async {
  _superficie(tester, tamano);
  await tester.pumpWidget(
    MaterialApp(
      home: RepositoryProvider<ClienteSalas>.value(
        value: salas,
        child: PantallaMultijugador(intervalo: intervalo, ahora: ahora),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Que pase [segundos] de reloj de los tests, preguntándole a la sala cada segundo como
/// hace la app.
Future<void> pasarSegundos(WidgetTester tester, int segundos) async {
  for (var i = 0; i < segundos; i++) {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

final botonCrearSala = find.byKey(const ValueKey('boton-crear-sala'));
final botonUnirse = find.byKey(const ValueKey('boton-unirse'));
final campoCodigo = find.byKey(const ValueKey('campo-codigo'));
final botonEmpezar = find.byKey(const ValueKey('boton-empezar'));
final errorDeSala = find.byKey(const ValueKey('error-de-sala'));

/// Crea una sala desde la pantalla, con [salas] contestando [vista].
Future<void> crearSala(WidgetTester tester, SalasFalsas salas, VistaDeSala vista) async {
  salas.vista = vista;
  await tocar(tester, botonCrearSala);
}
