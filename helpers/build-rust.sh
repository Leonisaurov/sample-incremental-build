#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-rust.sh — Build recipe template for Rust projects
# ═══════════════════════════════════════════════════════════════
# Cómo usar:
#   1. Copia este archivo a packages/<tu-paquete>/build.sh
#   2. Personaliza las variables TERMUX_PKG_*
#   3. Pon tu código Rust en project/
#   4. Build: ./build-package.sh -I -a aarch64 <tu-paquete>
#
# Estrategia incremental:
#   - CARGO_INCREMENTAL=1 (compilación incremental de rustc)
#   - CARGO_TARGET_DIR separado (cacheado por Cargo.lock)
#   - rsync --exclude=target/ (preserva artifacts entre builds)
#   - CI: cache dual (toolchain + cargo target/)
# ═══════════════════════════════════════════════════════════════

# ========== PERSONALIZA AQUÍ ==========
TERMUX_PKG_HOMEPAGE=https://github.com/user/project
TERMUX_PKG_DESCRIPTION="Rust project with incremental build"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@yourusername"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_REVISION=0
# ======================================

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# ─── Rust incremental compilation ───
export CARGO_INCREMENTAL=1
# Target dir SEPARADO del source, cacheado por Cargo.lock en CI
export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    # --exclude=target/ preserva el caché incremental entre builds
    rsync -a --delete --exclude=target/ \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    # Configura toolchain Rust (rustup + target aarch64-linux-android)
    termux_setup_rust
    echo "==> Rust incremental: CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
}

# No se necesita termux_step_make ni termux_step_make_install
# El build system detecta Cargo.toml automáticamente y ejecuta:
#   cargo install --target $CARGO_TARGET_NAME --root $TERMUX_PREFIX
