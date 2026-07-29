#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-c.sh — Build recipe template for C projects
# ═══════════════════════════════════════════════════════════════
# Cómo usar:
#   1. Copia este archivo a packages/<tu-paquete>/build.sh
#   2. Personaliza las variables TERMUX_PKG_*
#   3. Pon tu código C en project/
#   4. Build: ./build-package.sh -I -a aarch64 <tu-paquete>
#
# Estrategia incremental:
#   - ccache (cachea objetos compilados por preprocesado)
#   - rsync --exclude='*.o' (preserva objetos entre builds)
#   - make natural (solo recompila .c cambiados si .o persisten)
#   - CI: cache de toolchain + ccache dir
# ═══════════════════════════════════════════════════════════════

# ========== PERSONALIZA AQUÍ ==========
TERMUX_PKG_HOMEPAGE=https://github.com/user/project
TERMUX_PKG_DESCRIPTION="C project with ccache incremental build"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@yourusername"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_REVISION=0
# ======================================

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# ─── C / Make incremental compilation ───
# ccache cachea objetos compilados por contenido preprocesado
# make solo recompila .c cambiados si los .o persisten

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    # Excluir objetos para preservar el build incremental de make
    rsync -a --delete --exclude='*.o' --exclude='*.d' --exclude='*.res' \
        --exclude='proot' --exclude='loader/loader' --exclude='loader-m32' \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    # ─── ccache setup ───
    if ! command -v ccache &>/dev/null; then
        echo "==> Installing ccache..."
        apt-get update -qq 2>/dev/null || true
        apt-get install -y -qq ccache 2>/dev/null && echo "  ccache installed" || echo "  ccache not available (proceeding without)"
    fi

    if command -v ccache &>/dev/null; then
        export CCACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/ccache"
        export CCACHE_COMPRESS=1
        export CCACHE_COMPRESSLEVEL=6
        export CCACHE_MAXSIZE=500M
        # Anteponer ccache al PATH para interceptar el compilador
        export PATH="/usr/lib/ccache:$PATH"
        echo "==> ccache enabled: $CCACHE_DIR"
        # Mostrar estadísticas al final
        trap 'echo "==> ccache stats:"; ccache -s 2>/dev/null || true' EXIT
    else
        echo "==> ccache not available (compilación sin cache de objetos)"
    fi

    # ─── Detección de build system ───
    if [ -f src/GNUmakefile ] || [ -f src/Makefile ]; then
        echo "  Makefile detected in src/, using -C src"
        export TERMUX_PKG_EXTRA_MAKE_ARGS="-C src"
    fi
}

# NOTA: Si tu proyecto necesita autotools (./configure), 
# el build system lo maneja automáticamente en termux_step_configure
# 
# Si necesitas flags específicos, define termux_step_configure() aquí
