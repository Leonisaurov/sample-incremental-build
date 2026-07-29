#!/data/data/com.termux/files/usr/bin/bash
# helpers/setup-env.sh — Verifica entorno Termux para desarrollo local
# Ejecutar: bash helpers/setup-env.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check() {
    if [ -n "$2" ]; then
        echo -e "${GREEN}  ✓${NC} $1 = $2"
    else
        echo -e "${RED}  ✗${NC} $1 = (no definida)"
    fi
}

echo "=== Entorno Termux ==="
check "PREFIX" "${PREFIX:-}"
check "HOME" "${HOME:-}"
check "TMPDIR" "${TMPDIR:-}"
check "TERMUX_VERSION" "${TERMUX_VERSION:-}"

echo ""
echo "=== Sistema ==="
uname -a

echo ""
echo "=== Proyecto Sample ==="
SAMPLE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "  Ruta: $SAMPLE_DIR"

if [ -f "$SAMPLE_DIR/build-package.sh" ]; then
    echo -e "${GREEN}  ✓${NC} build-package.sh existe"
else
    echo -e "${RED}  ✗${NC} build-package.sh NO existe"
fi

if [ -f "$SAMPLE_DIR/packages/termux-sample/build.sh" ]; then
    echo -e "${GREEN}  ✓${NC} packages/termux-sample/build.sh existe"
else
    echo -e "${RED}  ✗${NC} packages/termux-sample/build.sh NO existe"
fi

if [ -d "$SAMPLE_DIR/project" ]; then
    echo -e "${GREEN}  ✓${NC} project/ existe"
else
    echo -e "${RED}  ✗${NC} project/ NO existe"
fi

echo ""
echo "=== Build (local) ==="
echo "  make -C project/  → compila localmente"
echo "  project/termux-sysinfo  → ejecuta el binario"
echo ""
echo "=== CI (GitHub Actions) ==="
echo "  git add project/"
echo "  git commit -m \"update(project): mensaje\""
echo "  git push"
echo "  → Actions compila automáticamente"
