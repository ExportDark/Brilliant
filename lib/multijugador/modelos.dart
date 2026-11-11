/// Lo que la app sabe de una sala del multijugador: exactamente lo que le manda el
/// servidor (`GET /salas/<código>/`). El servidor manda: la app no calcula puntos ni
/// valida jugadas, solo dibuja esto.
///
/// Nadie ve el tablero de otro jugador: [MiVista] trae el del jugador que pregunta, y de
/// los demás ([JugadorEnSala]) solo llega lo público.
library;

enum EstadoDeSala {
  esperando,
  preparando,
  jugando,
  terminada;

  static EstadoDeSala desde(String texto) => values.firstWhere(
        (estado) => estado.name == texto,
        orElse: () => throw FormatException('Estado de sala desconocido: $texto'),
      );
}

/// Un pedido que el servidor rechazó. [codigo] es estable (la app decide qué decirle al
/// jugador con él); [motivo] explica una jugada inválida.
class ErrorDeSala implements Exception {
  final String codigo;
  final String mensaje;
  final int estadoHttp;
  final String? motivo;

  const ErrorDeSala({
    required this.codigo,
    required this.mensaje,
    required this.estadoHttp,
    this.motivo,
  });

  @override
  String toString() => 'ErrorDeSala($codigo, $estadoHttp)';
}

/// Una jugada que se puede hacer ahora: anotar [valor] en alguna de [casillas], pegada
/// a una casilla con [ancla].
class JugadaLegal {
  final int ancla;
  final int valor;
  final List<String> casillas;

  const JugadaLegal({required this.ancla, required this.valor, required this.casillas});

  factory JugadaLegal.desdeJson(Map<String, dynamic> json) => JugadaLegal(
        ancla: json['ancla'] as int,
        valor: json['valor'] as int,
        casillas: [for (final c in json['casillas'] as List<dynamic>) c as String],
      );
}

/// Lo que ve el jugador de sí mismo.
class MiVista {
  final String usuario;
  final String estado; // activo, se_rindio, desconectado
  final bool preparado;
  final String accion; // pendiente, coloco, paso

  /// Su propio tablero: casilla -> número.
  final Map<String, int> tablero;
  final List<String> iniciales;
  final List<JugadaLegal> jugadas;
  final bool puedePasar;

  const MiVista({
    required this.usuario,
    required this.estado,
    required this.preparado,
    required this.accion,
    required this.tablero,
    required this.iniciales,
    required this.jugadas,
    required this.puedePasar,
  });

  bool get activo => estado == 'activo';

  /// Si puede anotar ahora: la partida está en juego, no ha jugado y tiene jugadas.
  bool get puedeJugar => activo && accion == 'pendiente' && jugadas.any((j) => j.casillas.isNotEmpty);

  factory MiVista.desdeJson(Map<String, dynamic> json) => MiVista(
        usuario: json['usuario'] as String,
        estado: json['estado'] as String,
        preparado: json['preparado'] as bool,
        accion: json['accion'] as String,
        tablero: {
          for (final MapEntry(:key, :value) in (json['tablero'] as Map<String, dynamic>).entries)
            key: value as int,
        },
        iniciales: [for (final c in json['iniciales'] as List<dynamic>) c as String],
        jugadas: [
          for (final j in json['jugadas'] as List<dynamic>)
            JugadaLegal.desdeJson(j as Map<String, dynamic>),
        ],
        puedePasar: json['puede_pasar'] as bool,
      );
}

/// Lo público de cada jugador de la sala.
class JugadorEnSala {
  final String usuario;
  final String estado;
  final bool anfitrion;

  /// En la preparación, si ya repartió; en la partida, si ya jugó la ronda.
  final bool listo;
  final int puntos;
  final int primeros;

  /// Los ids de las zonas que llenó, sin casillas ni números.
  final List<int> zonas;

  const JugadorEnSala({
    required this.usuario,
    required this.estado,
    required this.anfitrion,
    required this.listo,
    required this.puntos,
    required this.primeros,
    required this.zonas,
  });

  bool get activo => estado == 'activo';

  factory JugadorEnSala.desdeJson(Map<String, dynamic> json) => JugadorEnSala(
        usuario: json['usuario'] as String,
        estado: json['estado'] as String,
        anfitrion: json['anfitrion'] as bool,
        listo: json['listo'] as bool,
        puntos: json['puntos'] as int,
        primeros: json['primeros'] as int,
        zonas: [for (final z in json['zonas'] as List<dynamic>) z as int],
      );
}

/// Quién llenó una zona, en qué puesto y en qué ronda.
class PuestoTomado {
  final String usuario;
  final int puesto;
  final int ronda;

  const PuestoTomado({required this.usuario, required this.puesto, required this.ronda});

  factory PuestoTomado.desdeJson(Map<String, dynamic> json) => PuestoTomado(
        usuario: json['usuario'] as String,
        puesto: json['puesto'] as int,
        ronda: json['ronda'] as int,
      );
}

/// Una zona del mapa y quién la llenó: es lo que dice cuáles zonas siguen dando puntos.
class ZonaEnSala {
  final int id;
  final String tipo;
  final String color;
  final List<String> casillas;
  final List<PuestoTomado> puestos;

  /// Si ya no da puntos a nadie: los tres puestos que pagan están tomados.
  final bool agotada;

  /// Lo que daría llenarla ahora; 0 si está agotada.
  final int puntosSiguiente;

  const ZonaEnSala({
    required this.id,
    required this.tipo,
    required this.color,
    required this.casillas,
    required this.puestos,
    required this.agotada,
    required this.puntosSiguiente,
  });

  factory ZonaEnSala.desdeJson(Map<String, dynamic> json) => ZonaEnSala(
        id: json['id'] as int,
        tipo: json['tipo'] as String,
        color: json['color'] as String,
        casillas: [for (final c in json['casillas'] as List<dynamic>) c as String],
        puestos: [
          for (final p in json['puestos'] as List<dynamic>)
            PuestoTomado.desdeJson(p as Map<String, dynamic>),
        ],
        agotada: json['agotada'] as bool,
        puntosSiguiente: json['puntos_siguiente'] as int,
      );
}

class FilaDelRanking {
  final String usuario;
  final String estado;
  final int puntos;
  final int primeros;

  const FilaDelRanking({
    required this.usuario,
    required this.estado,
    required this.puntos,
    required this.primeros,
  });

  factory FilaDelRanking.desdeJson(Map<String, dynamic> json) => FilaDelRanking(
        usuario: json['usuario'] as String,
        estado: json['estado'] as String,
        puntos: json['puntos'] as int,
        primeros: json['primeros'] as int,
      );
}

/// Cómo terminó la partida.
class ResultadoDePartida {
  /// `tablero_lleno`, `sin_jugadas`, `anfitrion_se_fue`, `ultimo_jugador` o
  /// `todos_se_fueron`.
  final String motivo;
  final List<String> ganadores;
  final List<FilaDelRanking> ranking;

  const ResultadoDePartida({required this.motivo, required this.ganadores, required this.ranking});

  factory ResultadoDePartida.desdeJson(Map<String, dynamic> json) => ResultadoDePartida(
        motivo: json['motivo'] as String,
        ganadores: [for (final g in json['ganadores'] as List<dynamic>) g as String],
        ranking: [
          for (final f in json['ranking'] as List<dynamic>)
            FilaDelRanking.desdeJson(f as Map<String, dynamic>),
        ],
      );
}

/// La sala, como la ve quien preguntó.
class VistaDeSala {
  final String codigo;
  final int version;
  final EstadoDeSala estado;
  final int nivel;
  final String anfitrion;
  final int ronda;

  /// Los dos dados de la ronda, iguales para todos, o `null` fuera de la partida.
  final List<int>? dados;
  final double? segundosRestantes;
  final MiVista yo;
  final List<JugadorEnSala> jugadores;
  final List<ZonaEnSala> zonas;
  final ResultadoDePartida? resultado;

  const VistaDeSala({
    required this.codigo,
    required this.version,
    required this.estado,
    required this.nivel,
    required this.anfitrion,
    required this.ronda,
    required this.dados,
    required this.segundosRestantes,
    required this.yo,
    required this.jugadores,
    required this.zonas,
    required this.resultado,
  });

  bool get soyElAnfitrion => yo.usuario == anfitrion;

  factory VistaDeSala.desdeJson(Map<String, dynamic> json) => VistaDeSala(
        codigo: json['codigo'] as String,
        version: json['version'] as int,
        estado: EstadoDeSala.desde(json['estado'] as String),
        nivel: json['nivel'] as int,
        anfitrion: json['anfitrion'] as String,
        ronda: json['ronda'] as int,
        dados: json['dados'] == null
            ? null
            : [for (final d in json['dados'] as List<dynamic>) d as int],
        segundosRestantes: (json['segundos_restantes'] as num?)?.toDouble(),
        yo: MiVista.desdeJson(json['yo'] as Map<String, dynamic>),
        jugadores: [
          for (final j in json['jugadores'] as List<dynamic>)
            JugadorEnSala.desdeJson(j as Map<String, dynamic>),
        ],
        zonas: [
          for (final z in json['zonas'] as List<dynamic>)
            ZonaEnSala.desdeJson(z as Map<String, dynamic>),
        ],
        resultado: json['resultado'] == null
            ? null
            : ResultadoDePartida.desdeJson(json['resultado'] as Map<String, dynamic>),
      );
}
