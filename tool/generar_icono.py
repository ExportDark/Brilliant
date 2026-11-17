"""Uso: python tool/generar_icono.py

El ícono de Brilliant: un dado de cartón con borde de tinta y sombra dura, sobre la mesa
de fieltro, que muestra el cinco con un punto de cada color de zona. Genera el ícono adaptable de Android
(vector), los PNG de Android viejos y los de la web, sin librerías: un rasterizador de
rectángulos redondeados con supermuestreo y un escritor de PNG."""
import math
import os
import struct
import zlib

# La carpeta de la app: la de arriba de tool/.
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MESA = (0x2F, 0x5D, 0x50, 255)
TINTA = (0x1F, 0x1A, 0x17, 255)
CARTON = (0xFF, 0xFC, 0xF4, 255)
ROJO = (0xE9, 0x57, 0x3F, 255)
AMARILLO = (0xF7, 0xC5, 0x31, 255)
AZUL = (0x4A, 0x93, 0xE0, 255)
VERDE = (0x55, 0xB6, 0x7C, 255)
MORADO = (0x9B, 0x78, 0xDB, 255)

# Todo en el lienzo de 108 del ícono adaptable; lo que se ve está en el centro.
LADO, RADIO, BORDE, SOMBRA = 42.0, 9.0, 2.5, 3.5
X0 = 54 - LADO / 2
Y0 = 54 - LADO / 2 - SOMBRA / 2
PUNTO, BORDE_PUNTO = 9.5, 1.4
# Dónde va cada punto dentro del dado (el cinco) y de qué color de zona.
PUNTOS = [(0.25, 0.25, ROJO), (0.75, 0.25, AZUL), (0.5, 0.5, AMARILLO),
          (0.25, 0.75, VERDE), (0.75, 0.75, MORADO)]


def dado():
    """Las formas en orden de pintado: (x, y, ancho, alto, radio, color)."""
    formas = [
        (X0, Y0 + SOMBRA, LADO, LADO, RADIO, TINTA),  # la sombra dura
        (X0, Y0, LADO, LADO, RADIO, TINTA),  # el borde
        (X0 + BORDE, Y0 + BORDE, LADO - 2 * BORDE, LADO - 2 * BORDE, RADIO - BORDE, CARTON),
    ]
    for fx, fy, color in PUNTOS:
        cx, cy = X0 + LADO * fx, Y0 + LADO * fy
        formas.append((cx - PUNTO / 2, cy - PUNTO / 2, PUNTO, PUNTO, PUNTO / 2, TINTA))
        interior = PUNTO - 2 * BORDE_PUNTO
        formas.append((cx - interior / 2, cy - interior / 2, interior, interior,
                       interior / 2, color))
    return formas


# ------------------------------------------------------------------ vector de Android
def camino(x, y, w, h, r):
    def n(v):
        return f'{v:.2f}'.rstrip('0').rstrip('.')
    return (f'M{n(x + r)},{n(y)} h{n(w - 2 * r)} a{n(r)},{n(r)} 0 0 1 {n(r)},{n(r)} '
            f'v{n(h - 2 * r)} a{n(r)},{n(r)} 0 0 1 {n(-r)},{n(r)} h{n(-(w - 2 * r))} '
            f'a{n(r)},{n(r)} 0 0 1 {n(-r)},{n(-r)} v{n(-(h - 2 * r))} '
            f'a{n(r)},{n(r)} 0 0 1 {n(r)},{n(-r)} z')


def hexa(c):
    return '#{:02X}{:02X}{:02X}'.format(*c[:3])


def vector(formas, par_impar=False):
    """[par_impar]: un solo camino donde lo que se superpone queda hueco (la silueta)."""
    if par_impar:
        datos = ' '.join(camino(x, y, w, h, r) for x, y, w, h, r, _ in formas)
        caminos = (f'    <path android:fillColor="{hexa(formas[0][5])}" '
                   f'android:fillType="evenOdd" android:pathData="{datos}" />')
    else:
        caminos = '\n'.join(
            f'    <path android:fillColor="{hexa(c)}" android:pathData="{camino(x, y, w, h, r)}" />'
            for x, y, w, h, r, c in formas)
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!-- Generado por tool/generar_icono.py: un dado de cartón con borde de tinta y sombra
     dura, que muestra el cinco con un punto de cada color de zona. -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
{caminos}
</vector>
'''


# ------------------------------------------------------------------ rasterizador
def rasterizar(formas, tam, recorte, fondo=None, ss=4):
    """Pinta las [formas] (en el lienzo de 108) recortando el cuadrado central de lado
    [recorte], en una imagen de [tam] px. [fondo]: (radio relativo, color) o None."""
    paleta = [(0, 0, 0, 0)]
    indices = {}

    def indice(color):
        if color not in indices:
            indices[color] = len(paleta)
            paleta.append(color)
        return indices[color]

    escala = tam / recorte
    origen = 54 - recorte / 2
    w = tam * ss
    buf = bytearray(w * w)

    def pintar(x, y, ancho, alto, r, color):
        i = indice(color)
        # A píxeles de la imagen final.
        x, y, ancho, alto, r = ((x - origen) * escala, (y - origen) * escala,
                                ancho * escala, alto * escala, r * escala)
        fila0 = max(0, math.ceil(y * ss - 0.5))
        fila1 = min(w, math.ceil((y + alto) * ss - 0.5))
        for f in range(fila0, fila1):
            cy = (f + 0.5) / ss
            if cy < y + r:
                dy = y + r - cy
            elif cy > y + alto - r:
                dy = cy - (y + alto - r)
            else:
                dy = 0.0
            if dy > r:
                continue
            dx = r - math.sqrt(r * r - dy * dy)
            c0 = max(0, math.ceil((x + dx) * ss - 0.5))
            c1 = min(w, math.ceil((x + ancho - dx) * ss - 0.5))
            if c1 > c0:
                buf[f * w + c0:f * w + c1] = bytes([i]) * (c1 - c0)

    if fondo is not None:
        radio_rel, color = fondo
        pintar(origen, origen, recorte, recorte, recorte * radio_rel, color)
    for forma in formas:
        pintar(*forma)

    filas = []
    n = ss * ss
    for py in range(tam):
        fila = bytearray([0])  # sin filtro
        for px in range(tam):
            r = g = b = a = 0
            for sy in range(ss):
                base = (py * ss + sy) * w + px * ss
                for i in buf[base:base + ss]:
                    cr, cg, cb, ca = paleta[i]
                    r += cr * ca
                    g += cg * ca
                    b += cb * ca
                    a += ca
            if a:
                fila += bytes((r // a, g // a, b // a, a // n))
            else:
                fila += b'\0\0\0\0'
        filas.append(bytes(fila))
    return b''.join(filas)


def png(ruta, tam, datos):
    def trozo(tipo, contenido):
        return (struct.pack('>I', len(contenido)) + tipo + contenido
                + struct.pack('>I', zlib.crc32(tipo + contenido) & 0xFFFFFFFF))
    cabecera = struct.pack('>IIBBBBB', tam, tam, 8, 6, 0, 0, 0)
    with open(ruta, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + trozo(b'IHDR', cabecera)
                + trozo(b'IDAT', zlib.compress(datos, 9)) + trozo(b'IEND', b''))


def main():
    formas = dado()
    res = os.path.join(RAIZ, 'android', 'app', 'src', 'main', 'res')

    # El ícono adaptable (Android 8 en adelante) y su versión de un color (Android 13).
    open(os.path.join(res, 'drawable', 'ic_launcher_foreground.xml'), 'w',
         encoding='utf-8').write(vector(formas))
    # La silueta: el dado con los puntos huecos.
    x, y, w, h, r, _ = formas[1]
    silueta = [(x, y, w, h, r, TINTA)] + [f for f in formas[3::2]]
    open(os.path.join(res, 'drawable', 'ic_launcher_monochrome.xml'), 'w',
         encoding='utf-8').write(vector(silueta, par_impar=True))

    # Los PNG de Android viejo: un cuadrado de fieltro redondeado con el dado.
    for carpeta, tam in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144),
                         ('xxxhdpi', 192)]:
        ruta = os.path.join(res, f'mipmap-{carpeta}', 'ic_launcher.png')
        png(ruta, tam, rasterizar(formas, tam, 72, fondo=(0.22, MESA)))

    # La web: el ícono normal, el "maskable" (a todo lo ancho, con margen para la
    # máscara redonda) y el favicon.
    web = os.path.join(RAIZ, 'web')
    for tam in (192, 512):
        png(os.path.join(web, 'icons', f'Icon-{tam}.png'), tam,
            rasterizar(formas, tam, 72, fondo=(0.22, MESA), ss=4 if tam < 300 else 2))
        png(os.path.join(web, 'icons', f'Icon-maskable-{tam}.png'), tam,
            rasterizar(formas, tam, 84, fondo=(0.0, MESA), ss=4 if tam < 300 else 2))
    png(os.path.join(web, 'favicon.png'), 32, rasterizar(formas, 32, 60, fondo=(0.2, MESA)))
    print('ok')


main()
