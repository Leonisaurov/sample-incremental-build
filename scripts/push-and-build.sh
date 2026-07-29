#!/bin/bash
# =============================================================================
# scripts/push-and-build.sh — Helper para commitear y pushear cambios en project/
# =============================================================================
#
# Uso:
#   ./scripts/push-and-build.sh "mensaje del commit"
#
# Este script:
#   1. Hace git add project/ (solo el directorio de fuentes trackeadas)
#   2. Hace git commit con el mensaje proporcionado
#   3. Hace git push
#   4. Muestra la URL del workflow de GitHub Actions
#
# Si no hay cambios en project/, el script lo notifica y no hace commit.
#
# Requisitos:
#   - Tener un remote configurado (git remote add origin <url>)
#   - Tener permisos de push al repositorio
# =============================================================================

set -e  # Salir ante cualquier error

# --- Colores para output -----------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Validación --------------------------------------------------------------

# Verificar que se proporcionó un mensaje de commit
if [ $# -lt 1 ]; then
    error "Uso: $0 \"mensaje del commit\""
    echo ""
    echo "  Ejemplo:"
    echo "    $0 \"agrega detección de memoria swap\""
    exit 1
fi

COMMIT_MSG="$1"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

info "Directorio del proyecto: $PROJECT_DIR"
info "Mensaje del commit: $COMMIT_MSG"
echo ""

# --- Verificar cambios en project/ -------------------------------------------

cd "$PROJECT_DIR"

# Verificar si hay cambios (trackeados o no) en project/
if git diff --quiet HEAD -- project/ && git diff --cached --quiet HEAD -- project/; then
    warn "No hay cambios en project/ para commitear."
    warn "Edita los archivos en ./project/ primero."
    exit 0
fi

# --- Git add -----------------------------------------------------------------
info "Agregando cambios en project/..."
git add project/
success "Cambios agregados al stage."

# --- Git commit --------------------------------------------------------------
info "Creando commit: update(project): $COMMIT_MSG"
git commit -m "update(project): $COMMIT_MSG"
success "Commit creado."

# --- Git push ----------------------------------------------------------------
# Verificar que hay un remote configurado
REMOTE_URL=$(git remote get-url origin 2>/dev/null || true)
if [ -z "$REMOTE_URL" ]; then
    error "No hay un remote 'origin' configurado."
    error "Configúralo primero con:"
    error "  git remote add origin <url-del-repositorio>"
    exit 1
fi

info "Haciendo push a origin..."
git push

# --- Mostrar URL del workflow ------------------------------------------------
echo ""
success "Push completado."

# Extraer el repositorio de la URL del remote (formato https o git@github.com)
if echo "$REMOTE_URL" | grep -q 'github.com'; then
    # Extraer "owner/repo" de URLs como:
    #   https://github.com/owner/repo.git
    #   git@github.com:owner/repo.git
    REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's|.*github.com[/:](.*)\.git|\1|')
    echo ""
    echo "  \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
    echo "  CI en: https://github.com/$REPO_PATH/actions"
    echo "  \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
    echo ""
elif echo "$REMOTE_URL" | grep -q 'gitlab'; then
    REPO_PATH=$(echo "$REMOTE_URL" | sed -E 's|.*gitlab.*[/:](.*)\.git|\1|')
    echo "  CI en: https://gitlab.com/$REPO_PATH/-/pipelines"
else
    echo "  Remote: $REMOTE_URL"
    echo "  Revisa la CI en el repositorio remoto."
fi

echo ""
success "\u2713 Proceso completado."
