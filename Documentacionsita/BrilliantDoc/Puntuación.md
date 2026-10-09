# Puntuación

> [!warning] Esta parte no es oficial
> El Excel original del que salió el manual **no incluía tabla de puntos**. Lo que sigue
> es la propuesta razonable que el documento planteó a partir de la estructura del
> tablero, marcada explícitamente como ajustable.

Ver también: [[Reglas del juego]] · [[Estado del proyecto]] · [[Pruebas]]

## Propuesta actual

- **Región completada Y cumpliendo su regla**: suma puntos según su tamaño — por ejemplo
  1 punto por casilla llenada correctamente.
- **Región incompleta al terminar la partida**: no suma puntos (o resta, si se quiere una
  variante más dura).
- **Región que rompe su regla**: no debería poder darse si se valida cada jugada al
  colocarla, pero podría penalizarse en una variante más relajada donde se permite
  anotar y arriesgarse.
- Gana quien tenga más puntos al final.

## Fin de la partida

En el código, la partida termina cuando ninguna tirada posible tiene jugada: no hay
combinación de dado ancla y número del 1 al 6 que quepa en ninguna casilla libre, pegada a
una casilla con el número del dado ancla, sin romper la regla de su región. Ver
[[Turnos y jugadas]].

> [!important] Con las reglas actuales, el tablero siempre se llena (2026-10-08)
> Las 10 partidas simuladas de [[Pruebas]] terminaron con **49 de 49 casillas**. Lo único
> que varió fue cuántos turnos tardaron, entre 58 y 104, por los turnos pasados. No es
> casualidad:
> - **Ninguna zona se queda sin salida.** A la roja y a la amarilla siempre les falta
>   algún número que todavía no tienen. La morada, una vez que eligió sus dos números,
>   los puede repetir. La azul repite el suyo, y la verde acepta cualquiera.
> - **Toda casilla vacía tarde o temprano queda pegada a una llena**, y cualquier número
>   puede salir en el dado ancla.
>
> **Consecuencia para el puntaje:** "1 punto por casilla llenada correctamente" o "zona
> completada" no distinguiría a nadie, porque todos llegan a llenar todo. Hay que puntuar
> otra cosa. Algunas opciones:
> - **los turnos que se tardó en llenar el tablero**, o los turnos pasados;
> - **un número fijo de rondas**, como en las partidas del PDF, que terminaron con 34 y 31
>   casillas llenas, y entonces sí contar casillas o zonas completas.
>
> Queda por decidir antes de implementar `puntuacion/`.

## Estado en el código

Todavía **no implementado**. Según [[Arquitectura general]], vivirá en su propia capa
(`lib/puntuacion/`): tomará el tablero terminado y, región por región, decidirá los
puntos. Ni las reglas de color ni el `Tablero` calculan puntos — la puntuación es una
capa aparte que solo lee el resultado final.
