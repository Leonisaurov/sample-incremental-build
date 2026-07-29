# ═══════════════════════════════════════════════════════════════
# Auto-detect build script — selecciona estrategia incremental
# según el lenguaje detectado en project/
# ═══════════════════════════════════════════════════════════════
# Soporta:
#   - Rust: CARGO_INCREMENTAL + CARGO_TARGET_DIR cacheado
#   - C:    ccache + rsync preserve .o + make incremental
# ═══════════════════════════════════════════════════════════════

# Valores por defecto (se sobrescriben según detección)
TERMUX_PKG_HOMEPAGE=https://github.com/Leonisaurov/sample-incremental-build
TERMUX_PKG_DESCRIPTION="Universal template (auto-detect Rust/C)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# C branch: proot necesita libtalloc
TERMUX_PKG_DEPENDS="libtalloc"

# Detectar lenguaje y cargar script optimizado
if [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/Cargo.toml" ]; then
    echo "═══════════════════════════════════════════════"
    echo "  DETECTED: Rust project"
    echo "  Strategy: CARGO_INCREMENTAL + cargo target cache"
    echo "═══════════════════════════════════════════════"
    
    # Configuración específica Rust
    export CARGO_INCREMENTAL=1
    export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"

    termux_step_get_source() {
        mkdir -p "$TERMUX_PKG_SRCDIR"
        rsync -a --delete --exclude=target/ \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    }

    termux_step_pre_configure() {
        termux_setup_rust
        echo "  CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
    }
else
    echo "═══════════════════════════════════════════════"
    echo "  DETECTED: C project"
    echo "  Strategy: ccache + make incremental"
    echo "═══════════════════════════════════════════════"
    
    termux_step_get_source() {
        mkdir -p "$TERMUX_PKG_SRCDIR"
        rsync -a --delete --exclude='*.o' --exclude='*.d' --exclude='*.res' \
            --exclude='proot' --exclude='loader/loader' --exclude='loader-m32' \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    }

    termux_step_pre_configure() {
        # ccache setup
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

        # Detectar build system
        if [ -f src/GNUmakefile ]; then
            echo "  Detected GNUmakefile in src/"
            export PROOT_UNBUNDLE_LOADER=$TERMUX_PREFIX/libexec/proot
        fi
        if [ -f src/GNUmakefile ] || [ -f src/Makefile ]; then
            export TERMUX_PKG_EXTRA_MAKE_ARGS="-C src"
        fi
    }
fi
