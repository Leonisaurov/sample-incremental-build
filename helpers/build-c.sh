#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-c.sh — Build recipe for C projects
# ═══════════════════════════════════════════════════════════════
# Estrategia incremental:
#   - ccache (cachea objetos compilados por contenido)
#   - rsync --exclude='*.o' (preserva objetos entre builds)
#   - make natural (solo recompila .c cambiados si .o persisten)
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    rsync -a --delete --exclude='*.o' --exclude='*.d' --exclude='*.res' \
        --exclude='proot' --exclude='loader/loader' --exclude='loader-m32' \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    # ─── ccache ───
    if ! command -v ccache &>/dev/null; then
        apt-get update -qq 2>/dev/null || true
        apt-get install -y -qq ccache 2>/dev/null || true
    fi
    if command -v ccache &>/dev/null; then
        export CCACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/ccache"
        export CCACHE_COMPRESS=1
        export CCACHE_COMPRESSLEVEL=6
        export CCACHE_MAXSIZE=500M
        export PATH="/usr/lib/ccache:$PATH"
        echo "  ccache enabled: $CCACHE_DIR"
    fi
}
