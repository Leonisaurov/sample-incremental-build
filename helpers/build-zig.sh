#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-zig.sh — Build recipe for Zig projects
# ═══════════════════════════════════════════════════════════════
# Part of termux-incremental-build-template
#
# USE:   Auto-cargado por packages/<pkg>/build.sh cuando
#        detecta project/build.zig o project/build.zig.zon
#
# DEPS:  termux_setup_zig() (en scripts/build/setup/)
#
# CACHE: zig-cache cacheado por hash de build.zig + src/*.zig
#
# ESTRATEGIA INCREMENTAL:
#   - ZIG_GLOBAL_CACHE_DIR (cachel nivell global, persiste)
#   - ZIG_LOCAL_CACHE_DIR (cachel local por paquete, persiste)
#   - rsync --exclude=zig-cache/ --exclude=zig-out/
#   - NOTA: Zig no tiene soporte nativo para Android (usa linux-musl)
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

export ZIG_GLOBAL_CACHE_DIR="${TERMUX_COMMON_CACHEDIR}/zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/zig-cache"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    rsync -a --delete --exclude=zig-cache/ --exclude=zig-out/ \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    export TERMUX_ZIG_VERSION=${TERMUX_ZIG_VERSION:-0.16.0}
    termux_setup_zig
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR" "$ZIG_LOCAL_CACHE_DIR"
    echo "  Zig version: $(zig version)"
    echo "  Target: $ZIG_TARGET_NAME"
}

termux_step_make() {
    cd "$TERMUX_PKG_SRCDIR"
    zig build \
        --cache-dir "$ZIG_LOCAL_CACHE_DIR" \
        --global-cache-dir "$ZIG_GLOBAL_CACHE_DIR" \
        --prefix "$TERMUX_PREFIX" \
        -Dtarget="$ZIG_TARGET_NAME" \
        -Doptimize=ReleaseSafe
}

termux_step_make_install() {
    :
}
