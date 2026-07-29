#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/build-rust.sh — Build recipe for Rust projects
# ═══════════════════════════════════════════════════════════════
# Estrategia incremental:
#   - CARGO_INCREMENTAL=1 (compilación incremental de rustc)
#   - CARGO_TARGET_DIR separado (cacheado por Cargo.lock)
#   - rsync --exclude=target/ (preserva artifacts entre builds)
# ═══════════════════════════════════════════════════════════════

TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

# ─── Rust incremental compilation ───
export CARGO_INCREMENTAL=1
export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    rsync -a --delete --exclude=target/ \
        "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    termux_setup_rust
    echo "  Rust incremental: CARGO_TARGET_DIR=$CARGO_TARGET_DIR"
}
