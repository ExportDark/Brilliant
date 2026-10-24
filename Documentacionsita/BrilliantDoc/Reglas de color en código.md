# Reglas de color en código

Todo lo que vive en `lib/reglas/`. Las reglas del juego en sí están en
[[Reglas del juego]]; esto es cómo están implementadas.

Ver también: [[Modelo de dominio]] · [[Arquitectura general]]

## El patrón

Hay dos niveles, a propósito:

1. **Funciones puras**, sin estado, que implementan un *tipo* de restricción genérica.
   Reciben `(List<int> numeros, int numero)` y devuelven un bool. Son trivialmente
   testeables en aislado.
2. **Una clase por color**, delgada, que implementa el contrato `ReglaColor` y delega en
   la función pura correspondiente. Le pone nombre de dominio a la regla.

Esto permite que dos colores compartan la misma lógica subyacente sin duplicar código
(rojo y amarillo usan la misma función) y que cada color siga siendo una cosa nombrada
e independiente.

## El contrato

```dart
abstract class ReglaColor {
  bool puedeAgregar(List<int> numeros, int numero);
  String get descripcion;
}
```

Dado lo que ya está anotado en la región, `puedeAgregar` decide si un nuevo valor se puede
agregar. `descripcion` es la regla dicha en una frase (por ejemplo, *"Todos iguales: todas
las casillas llevan el mismo número"*), y es lo que la pantalla de partida le muestra al
jugador cuando una casilla no acepta su número. Ver [[Turnos y jugadas]].

Las descripciones **no dicen cuántas casillas tiene la zona**, porque eso cambia según el
mapa. Hasta el 2026-10-24 decían "las 4 casillas" o "las 6 casillas"; un test
(`no_dicen_cuantas_casillas_test`) cuida que no vuelva a pasar.

## Las funciones puras

| Archivo | Función | Qué valida |
|---|---|---|
| `regla_numeros_distintos.dart` | `puedeAgregarManteniendoDistintos` | Que no se repita ningún número |
| `regla_cualquiera.dart` | `puedeAgregarCualquiera` | Nada: siempre `true` |
| `regla_valor_unico.dart` | `puedeAgregarValorUnico` | Que todos los valores sean iguales |
| `regla_maximo_valores_distintos.dart` | `puedeAgregarConMaximoValoresDistintos` | Que no se superen N valores distintos (parametrizable) |
| `regla_rango.dart` | `puedeAgregarEnRango` | Que el número esté entre un mínimo y un máximo. No mira lo que ya tiene la zona |

## Las clases por color

| Clase | Delega en | Regla del juego |
|---|---|---|
| `ReglaRojo` | `puedeAgregarManteniendoDistintos` | Sin repetir en la zona |
| `ReglaAmarillo` | `puedeAgregarManteniendoDistintos` | Sin repetir entre las casillas dispersas |
| `ReglaVerde` | `puedeAgregarCualquiera` | Sin restricción |
| `ReglaAzul` | `puedeAgregarValorUnico` | Todas las casillas con el mismo valor |
| `ReglaMorado` | `puedeAgregarConMaximoValoresDistintos` (máx. 2) | Máximo 2 valores distintos |
| `ReglaGris` | `puedeAgregarValorUnico` | Todas las casillas con el mismo valor, como el azul |
| `ReglaNaranja(minimo, maximo)` | `puedeAgregarEnRango` | Solo números del rango. Se describe como "Solo del 4 al 6" |

El naranja es el único color con dos reglas: cada zona naranja trae su rango. Por eso
hay dos tipos, `tipoNaranjaBajo` (1-3) y `tipoNaranjaAlto` (4-6), con la misma clase y
distinto rango. Ver [[Mapas]].

## Cómo se usan

No hay ningún dispatcher ni `switch` por color. Cada `Region` llega a su regla a través
de su tipo:

```dart
region.tipo.regla.puedeAgregar(extraerValores(region), valor)
```

El porqué de esto está en [[Modelado de regiones]].

## Por qué este patrón

Separar la función pura de la clase por color permite que dos colores con la misma
restricción (rojo y amarillo, ambos "todos diferentes") compartan una única
implementación probada, y que cada función se pueda testear sola, sin construir una
región ni un tablero. Ver [[Decisiones de extracción del manual]].
