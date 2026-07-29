#!/data/data/com.termux/files/usr/bin/bash
# helpers/push-and-build.sh — Commit + Push de project/ → dispara CI
# Uso: bash helpers/push-and-build.sh "mensaje del commit"

set -euo pipefail

SAMPLE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SAMPLE_DIR"

# Verificar que hay cambios en project/
if git diff --quiet HEAD -- project/; then
    echo "⚠️  No hay cambios en project/ para commitear."
    echo "   Edita archivos en project/ primero."
    exit 1
fi

# Mensaje de commit
MSG="${1:-update(project): cambios automáticos}"

# Mostrar qué cambió
echo "📦 Cambios en project/:"
git diff --stat HEAD -- project/

# Commit y push
git add project/
git commit -m "$MSG"
git push

echo ""
echo "🚀 Commit pusheado: $MSG"
echo "📡 Seguimiento en: https://github.com/$(git remote get-url origin 2>/dev/null | sed 's/.*:\(.*\)\.git/\1/')/actions"
