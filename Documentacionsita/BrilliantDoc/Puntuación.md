# Puntuación

> [!warning] Esta parte no es oficial
> El Excel original del que salió el manual **no incluía tabla de puntos**. Lo que sigue
> es la propuesta razonable que el documento planteó a partir de la estructura del
> tablero, marcada explícitamente como ajustable.

Ver también: [[Reglas del juego]] · [[Estado del proyecto]]

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

La partida termina cuando los tableros se llenan o ya no hay jugadas legales — es decir,
cuando ninguno de los dos valores de los dados puede colocarse en ninguna casilla libre
sin romper la regla de su región.

## Estado en el código

Todavía **no implementado**. Según [[Arquitectura general]], vivirá en su propia capa
(`lib/puntuacion/`): tomará el tablero terminado y, región por región, decidirá los
puntos. Ni las reglas de color ni el `Tablero` calculan puntos — la puntuación es una
capa aparte que solo lee el resultado final.
