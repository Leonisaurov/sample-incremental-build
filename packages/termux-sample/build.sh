# ═══════════════════════════════════════════════════════════════
# Auto-detect build — selecciona script según lenguaje
# y carga configuración del proyecto
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_HOMEPAGE=https://github.com/Leonisaurov/sample-incremental-build
TERMUX_PKG_DESCRIPTION="Universal template (auto-detect Rust/C)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libtalloc"

# Cargar configuración del proyecto
source "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/helpers/termux-build-config.sh"

# Detectar lenguaje y cargar script optimizado
if [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/Cargo.toml" ]; then
    echo "═══════════════════════════════════════════════"
    echo "  DETECTED: Rust project"
    echo "  Strategy: CARGO_INCREMENTAL + cargo target cache"
    echo "═══════════════════════════════════════════════"
    source "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/helpers/build-rust.sh"
else
    echo "═══════════════════════════════════════════════"
    echo "  DETECTED: C project"
    echo "  Strategy: ccache + make incremental"
    echo "═══════════════════════════════════════════════"
    source "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/helpers/build-c.sh"
fi
