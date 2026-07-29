# ═══════════════════════════════════════════════════════════════
# Auto-detect build — selecciona script según lenguaje
# Soporta: Rust, C, Zig
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_HOMEPAGE=https://github.com/Leonisaurov/sample-incremental-build
TERMUX_PKG_DESCRIPTION="Universal template (auto-detect Rust/C/Zig)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# Cargar configuración del proyecto
source "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/helpers/termux-build-config.sh"

# Detectar lenguaje
if [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/build.zig" ] || [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/build.zig.zon" ]; then
    echo "═══════════════════════════════════════════════"
    echo "  DETECTED: Zig project"
    echo "  Strategy: zig cache + global cache"
    echo "═══════════════════════════════════════════════"
    source "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/helpers/build-zig.sh"

elif [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/Cargo.toml" ]; then
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
