#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-zig.sh — Build recipe for Zig projects
# ═══════════════════════════════════════════════════════════════
# Estrategia incremental:
#   - ZIG_GLOBAL_CACHE_DIR separado (cachea compilaciones zig)
#   - ZIG_LOCAL_CACHE_DIR por paquete (cachea artifacts locales)
#   - rsync --exclude=zig-cache/ --exclude=zig-out/ (preserva caches)
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# ─── Zig incremental compilation caches ───
export ZIG_GLOBAL_CACHE_DIR="${TERMUX_COMMON_CACHEDIR}/zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/zig-cache"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    # Excluir caches de zig para preservarlos entre builds
    rsync -a --delete --exclude=zig-cache/ --exclude=zig-out/ \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    # Fijar versión de Zig (evita source de packages/zig/build.sh)
    export TERMUX_ZIG_VERSION=${TERMUX_ZIG_VERSION:-0.16.0}
    # Setup Zig toolchain (descarga binario ziglang.org si es necesario)
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

# zig build --prefix ya instala en $TERMUX_PREFIX
termux_step_make_install() {
    :
}
