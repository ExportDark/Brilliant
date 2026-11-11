// Genera los archivos que comparten la app y el servidor (repo
// Brilliant-servidor): los mapas y casos de jugadas con la respuesta de las
// reglas en Dart. El servidor valida las jugadas del multijugador con las
// mismas reglas portadas a Python, y sus tests exigen dar lo mismo que aquí.
//
//   dart run tool/exportar_para_el_servidor.dart
//
// Escribe en tool/exportado/, y de ahí se copian a mano a
// Brilliant-servidor/juego/datos/. Un test de la app falla si lo que está en
// tool/exportado/ no es lo que generaría el código actual: así cambiar una
// regla sin volver a exportar no pasa desapercibido.

import 'dart:convert';
import 'dart:io';

import 'package:brilliant/juego/validacion_jugada.dart';
import 'package:brilliant/modelo/mapa.dart';
import 'package:brilliant/modelo/posicion.dart';
import 'package:brilliant/modelo/tablero.dart';
import 'package:brilliant/modelo/tipo_region.dart';

/// Cuántas partidas al azar se simulan por mapa, y cada cuántas casillas
/// anotadas se saca una foto del tablero.
const partidasPorMapa = 10;
const casillasEntreFotos = 7;
const jugadasPorFoto = 30;

/// El nombre de cada tipo de zona en los archivos compartidos.
String nombreDelTipo(TipoRegion tipo) {
  if (identical(tipo, tipoAmarillo)) return 'amarillo';
  if (identical(tipo, tipoVerde)) return 'verde';
  if (identical(tipo, tipoMorado)) return 'morado';
  if (identical(tipo, tipoAzul)) return 'azul';
  if (identical(tipo, tipoRojo)) return 'rojo';
  if (identical(tipo, tipoGris)) return 'gris';
  if (identical(tipo, tipoNaranjaBajo)) return 'naranja_bajo';
  if (identical(tipo, tipoNaranjaAlto)) return 'naranja_alto';
  throw StateError('Tipo de zona sin nombre: $tipo');
}

/// Un generador de números al azar propio (congruencial lineal), para que los
/// archivos no cambien con la versión de Dart.
class _Azar {
  int _estado;

  _Azar(int semilla) : _estado = semilla & 0x7fffffff;

  int siguiente(int limite) {
    _estado = (_estado * 1103515245 + 12345) & 0x7fffffff;
    return (_estado >> 8) % limite;
  }

  T elegir<T>(List<T> lista) => lista[siguiente(lista.length)];
}

String generarMapas() {
  final datos = {
    'mapas': [
      for (final mapa in mapas)
        {
          'nivel': mapa.nivel,
          'iniciales': mapa.casillasIniciales,
          'zonas': [
            for (final (indice, zona) in mapa.zonas.indexed)
              {'id': indice + 1, 'tipo': nombreDelTipo(zona.tipo), 'casillas': zona.casillas},
          ],
        },
    ],
  };
  return '${const JsonEncoder.withIndent(' ').convert(datos)}\n';
}

String generarCasos() {
  final casos = <Map<String, Object>>[];
  for (final mapa in mapas) {
    for (var partida = 0; partida < partidasPorMapa; partida++) {
      final azar = _Azar(mapa.nivel * 1000 + partida);
      casos.addAll(_fotosDeUnaPartida(mapa, azar));
    }
  }
  return '${jsonEncode({'casos': casos})}\n';
}

/// Juega una partida al azar y saca fotos del tablero cada pocas casillas.
List<Map<String, Object>> _fotosDeUnaPartida(Mapa mapa, _Azar azar) {
  var tablero = _tableroInicial(mapa, azar);
  final fotos = <Map<String, Object>>[_foto(mapa, tablero, azar)];

  var anotadas = 0;
  for (var intento = 0; intento < 400; intento++) {
    final a = azar.siguiente(6) + 1;
    final b = azar.siguiente(6) + 1;
    // Se prueba con cada dado como ancla, en orden al azar.
    final orden = azar.siguiente(2) == 0 ? [(a, b), (b, a)] : [(b, a), (a, b)];
    Posicion? elegida;
    int? valor;
    for (final (ancla, aColocar) in orden) {
      final legales = [
        for (final celda in tablero.celdas)
          if (evaluarJugada(tablero, celda.posicion, ancla: ancla, valor: aColocar)
              is JugadaValida)
            celda.posicion,
      ];
      if (legales.isNotEmpty) {
        elegida = azar.elegir(legales);
        valor = aColocar;
        break;
      }
    }
    if (elegida == null) continue;

    tablero = tablero.conValor(elegida, valor!);
    anotadas++;
    if (anotadas % casillasEntreFotos == 0) fotos.add(_foto(mapa, tablero, azar));
  }
  fotos.add(_foto(mapa, tablero, azar));
  return fotos;
}

/// El tablero con un reparto al azar de los números del 1 al 6 en las casillas
/// iniciales, en el que cada número cabe en su casilla.
Tablero _tableroInicial(Mapa mapa, _Azar azar) {
  final vacio = Tablero.desdeMapa(mapa);
  final casillas = [for (final notacion in mapa.casillasIniciales) Posicion.desdeNotacion(notacion)];
  while (true) {
    final numeros = [1, 2, 3, 4, 5, 6];
    for (var i = numeros.length - 1; i > 0; i--) {
      final j = azar.siguiente(i + 1);
      final temporal = numeros[i];
      numeros[i] = numeros[j];
      numeros[j] = temporal;
    }
    final cabe = [
      for (final (i, casilla) in casillas.indexed) vacio.aceptaComoInicial(casilla, numeros[i]),
    ].every((c) => c);
    if (cabe) {
      return vacio.conValores({for (final (i, casilla) in casillas.indexed) casilla: numeros[i]});
    }
  }
}

Map<String, Object> _foto(Mapa mapa, Tablero tablero, _Azar azar) {
  final celdas = tablero.celdas.toList();
  String nombre(JugadaValida _) => 'valida';

  final jugadas = <Map<String, Object>>[];
  for (var i = 0; i < jugadasPorFoto; i++) {
    final celda = azar.elegir(celdas);
    final ancla = azar.siguiente(6) + 1;
    final valor = azar.siguiente(6) + 1;
    final resultado = evaluarJugada(tablero, celda.posicion, ancla: ancla, valor: valor);
    jugadas.add({
      'casilla': celda.posicion.notacion,
      'ancla': ancla,
      'valor': valor,
      'resultado': switch (resultado) {
        JugadaValida() => nombre(resultado),
        CasillaOcupada() => 'ocupada',
        SinVecinoConNumero() => 'sin_vecino',
        ReglaRota() => 'regla_rota',
      },
    });
  }

  return {
    'nivel': mapa.nivel,
    'valores': {
      for (final celda in celdas)
        if (celda.valor != null) celda.posicion.notacion: celda.valor!,
    },
    'jugadas': jugadas,
    // Para cada pareja (ancla, valor), si hay alguna casilla donde se pueda
    // anotar: es la regla del fin de partida.
    'hay_jugada': {
      for (var ancla = 1; ancla <= 6; ancla++)
        for (var valor = 1; valor <= 6; valor++)
          '$ancla-$valor': hayJugada(tablero, ancla: ancla, valor: valor),
    },
    // Las zonas que ya están llenas.
    'zonas_llenas': [
      for (final region in tablero.regiones)
        if (region.completada) region.identificador,
    ],
  };
}

void main() {
  final carpeta = Directory('tool/exportado')..createSync(recursive: true);
  File('${carpeta.path}/mapas.json').writeAsStringSync(generarMapas());
  File('${carpeta.path}/casos_de_jugadas.json').writeAsStringSync(generarCasos());
  stdout.writeln('Escrito en ${carpeta.path}: mapas.json y casos_de_jugadas.json');
}
