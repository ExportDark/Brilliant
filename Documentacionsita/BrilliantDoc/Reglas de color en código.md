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
}
```

Dado lo que ya está anotado en la región, decide si un nuevo valor se puede agregar.

## Las funciones puras

| Archivo | Función | Qué valida |
|---|---|---|
| `regla_numeros_distintos.dart` | `puedeAgregarManteniendoDistintos` | Que no se repita ningún número |
| `regla_cualquiera.dart` | `puedeAgregarCualquiera` | Nada: siempre `true` |
| `regla_valor_unico.dart` | `puedeAgregarValorUnico` | Que todos los valores sean iguales |
| `regla_maximo_valores_distintos.dart` | `puedeAgregarConMaximoValoresDistintos` | Que no se superen N valores distintos (parametrizable) |

## Las clases por color

| Clase | Delega en | Regla del juego |
|---|---|---|
| `ReglaRojo` | `puedeAgregarManteniendoDistintos` | Corrida del 1 al 6 en las 6 casillas |
| `ReglaAmarillo` | `puedeAgregarManteniendoDistintos` | Sin repetir entre las 5 casillas dispersas |
| `ReglaVerde` | `puedeAgregarCualquiera` | Sin restricción |
| `ReglaAzul` | `puedeAgregarValorUnico` | Todas las casillas con el mismo valor |
| `ReglaMorado` | `puedeAgregarConMaximoValoresDistintos` (máx. 2) | Máximo 2 valores distintos |

## Cómo se usan

No hay ningún dispatcher ni `switch` por color. Cada `Region` llega a su regla a través
de su tipo:

```dart
region.tipo.regla.puedeAgregar(extraerValores(region), valor)
```

El porqué de esto está en [[Modelado de regiones]].

## Origen del diseño

Este patrón (función pura + wrapper por color) venía de un intento previo del proyecto,
`Brilliant Beta`. Al comparar regla por regla contra el PDF del manual, coincidía
exactamente, así que se reescribió igual en el proyecto nuevo en vez de inventar otra
lógica. Ver [[Decisiones de extracción del manual]].
