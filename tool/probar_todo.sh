#!/usr/bin/env bash
# Todas las pruebas de la app y del servidor, en orden, con Git Bash:
#
#   bash tool/probar_todo.sh
#
# 1. Las del servidor (pytest), en la carpeta hermana ../Brilliant-servidor.
# 2. Levanta el servidor (si ya hay uno en el puerto 8443, usa ese y no lo apaga).
# 3. Las de la app (flutter test).
# 4. Las que juegan contra el servidor de verdad (CON_SERVIDOR): cuentas y multijugador.
# 5. Apaga el servidor que levantó y dice qué pasó con cada paso.
#
# Termina con 0 si todo pasó. Las del paso 4 son las que nadie corría: una quedó vieja
# varios días sin que se notara (ver "Revisión de lógica" en el vault).

set -u

APP="$(cd "$(dirname "$0")/.." && pwd)"
SERVIDOR="$(cd "$APP/../Brilliant-servidor" && pwd)"
FLUTTER="${FLUTTER:-/c/src/flutter/bin/flutter.bat}"
# Un .bat no cuenta como ejecutable para `-x` en Git Bash: basta con que exista.
[ -f "$FLUTTER" ] || FLUTTER=flutter
PYTHON="$SERVIDOR/.venv/Scripts/python.exe"
REGISTRO="$(mktemp)"

resumen=()
fallo=0

paso() {
  # paso "nombre" comando...: corre el comando y anota si pasó.
  local nombre="$1"
  shift
  echo
  echo "=== $nombre"
  if "$@"; then
    resumen+=("pasó   $nombre")
  else
    resumen+=("FALLÓ  $nombre")
    fallo=1
  fi
}

paso "Servidor: pytest" bash -c "cd '$SERVIDOR' && SKIP_CYTHON=1 '$PYTHON' -m pytest -q -p no:cacheprovider"

# El servidor de verdad, para el paso 4.
levantado=""
if (echo > /dev/tcp/127.0.0.1/8443) 2>/dev/null; then
  echo
  echo "=== Ya hay un servidor en el puerto 8443: se usa ese."
else
  (cd "$SERVIDOR" && "$PYTHON" manage.py cerrar_sesiones > /dev/null)
  (cd "$SERVIDOR" && SKIP_CYTHON=1 exec "$PYTHON" servir.py > "$REGISTRO" 2>&1) &
  levantado=$!
  for _ in $(seq 1 60); do
    grep -q "Uvicorn running" "$REGISTRO" && break
    sleep 1
  done
  grep -q "Uvicorn running" "$REGISTRO" || { echo "El servidor no arrancó:"; cat "$REGISTRO"; }
fi

apagar() {
  if [ -n "$levantado" ]; then
    local winpid
    winpid="$(cat "/proc/$levantado/winpid" 2>/dev/null)"
    kill "$levantado" 2> /dev/null
    [ -n "$winpid" ] && taskkill //PID "$winpid" //T //F > /dev/null 2>&1
    levantado=""
  fi
  rm -f "$REGISTRO"
}
trap apagar EXIT

cd "$APP" || exit 1
paso "App: flutter test" "$FLUTTER" test
paso "App contra el servidor: cuentas" "$FLUTTER" test --dart-define=CON_SERVIDOR=true \
  test/cuenta/contra_el_servidor_test.dart
paso "App contra el servidor: multijugador" "$FLUTTER" test --dart-define=CON_SERVIDOR=true \
  test/multijugador/contra_el_servidor_test.dart

apagar
echo
echo "=== Resumen"
printf '%s\n' "${resumen[@]}"
exit $fallo
