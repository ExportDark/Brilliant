# Decisiones de extracción del manual

El tablero y las reglas se sacaron del PDF `Brilliant_Imitacion_Manual_y_Partidas.pdf`.
Ese proceso obligó a tomar varias decisiones que no eran obvias. Esta nota documenta
cada una: qué la causó, qué alternativas había, y por qué se eligió lo que se eligió.

Ver también: [[Tablero y regiones]] · [[Modelado de regiones]] · [[Sistema de coordenadas]]

---

## 1. Interpretar la notación "C1", "F2", "B4"...

**Por qué no era obvio:** el manual nombra las 6 casillas iniciales como "C1, F2, B4,
E4, C6, E7" pero nunca define si la letra es la columna o la fila. Ambas lecturas son
gramaticalmente válidas.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Letra = columna, número = fila | Convención estándar en juegos de tablero y hojas de cálculo | Ninguna comprobada sin cruzar contra la imagen |
| Letra = fila, número = columna | También es convención válida en otros contextos | Rompía la coherencia al cruzarla contra la imagen |

**Decisión:** letra = columna, número = fila. Se confirmó cruzando **las 6** casillas
iniciales contra su posición real en la imagen del tablero (ej. "C1" debía caer en la
celda azul con borde grueso de la fila 1 — y en efecto, la columna C de la fila 1 es
azul). Se verificaron las seis, no solo una, antes de asumirlo como regla.

---

## 2. Delimitar las zonas físicas de cada color

**Por qué no era obvio:** el PDF da una grilla de colores y dice "2 zonas verdes de 6
casillas", pero no lista qué casillas concretas forman cada una de esas 2 zonas — solo
se ve el color, no el número de zona.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Componentes conexas por adyacencia ortogonal | No requiere información extra; es el criterio natural de "zona" en un tablero | Podía fallar si la lectura de algún color individual estaba mal |
| Tratar todas las casillas de un color como una sola región | Más simple de codificar | Contradice al manual, que dice "2 zonas" por color |
| Pedir confirmación casilla por casilla | Cero ambigüedad | Lento e innecesario si el patrón visual ya alcanza |

**Decisión:** componentes conexas por adyacencia. Se validó contando las casillas de
cada componente y comparándolas contra los tamaños declarados en el manual (2×6 verde,
2×4 azul, 2×6 morado, 2×6 rojo) — coincidieron exactamente.

---

## 3. La zona amarilla: ¿5 zonas triviales o 1 región dispersa?

**Por qué no era obvio:** el manual dice literalmente "5 zonas amarillas de una sola
casilla", lo que sugiere 5 zonas independientes. Pero eso vuelve la regla "todos
diferentes" trivial: una celda sola siempre la cumple.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| 5 zonas independientes de 1 casilla | Sigue el conteo literal del manual ("13 zonas") | La regla se vuelve inútil para ese color |
| 1 región lógica con las 5 casillas dispersas | La regla cobra sentido real (no repetir entre las 5) | El manual no lo dice explícitamente: es interpretación |

**Decisión:** 1 región. Primero se implementó la opción literal; el usuario corrigió
explícitamente pidiendo tratarlas como una sola región. Se verificó que la
reinterpretación no rompiera los datos: en las Partidas 1 y 2 del PDF, los valores ya
anotados en casillas amarillas resultaron mutuamente distintos en ambos casos.

Esto es lo que baja el conteo de **13 zonas a 9 regiones**.

---

## 4. Cómo verificar que toda la extracción era correcta

**Por qué no era obvio:** no había forma de leer la imagen del PDF con certeza
pixel-perfecta; un error de transcripción (un color mal leído, una celda desplazada) se
propagaría silenciosamente a todo el modelo.

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| Confiar en una sola lectura | Rápido | Sin forma de detectar errores |
| Validación cruzada: contar casillas por color contra los totales del manual (5+12+8+12+12=49) | Detecta errores de conteo sin trabajo extra | No detecta si dos colores se confunden y el total igual cuadra |
| Simular las 2 partidas de ejemplo y verificar que ninguna zona rompe su regla | Valida layout **e** interpretación de reglas contra datos reales jugados | Más laborioso |

**Decisión:** las dos últimas, combinadas. El conteo cruzado como primer chequeo rápido,
y la revisión de los valores reales de las Partidas 1 y 2 para confirmar que ninguna
zona las rompía — esto último fue lo que confirmó que tratar el amarillo como región
única seguía siendo válido (decisión 3).

> [!tip] Esa verificación ahora vive en el código
> `Tablero` re-verifica el layout cada vez que se construye: sin casillas duplicadas,
> sin huecos y sin nada fuera de la grilla. Ver [[Modelo de dominio]].
