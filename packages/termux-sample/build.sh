# Universal build script - auto-detects Rust vs C
TERMUX_PKG_HOMEPAGE=https://github.com/Leonisaurov/content-7z
TERMUX_PKG_DESCRIPTION="Universal project template (auto-detect Rust/C)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"

    # Detect project type and apply optimal rsync strategy
    if [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/Cargo.toml" ]; then
        echo "==> Detected Rust project"
        # For Rust: exclude target/ to preserve incremental compilation cache
        rsync -a --delete --exclude=target/ \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    else
        echo "==> Detected C project"
        # For C: keep existing .o files (make handles incremental naturally)
        rsync -a --delete --exclude='*.o' --exclude='*.d' \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    fi
}

termux_step_pre_configure() {
    if [ -f "$TERMUX_PKG_SRCDIR/Cargo.toml" ]; then
        # ─── Rust incremental setup ───
        echo "==> Setting up Rust incremental build"
        termux_setup_rust
        export CARGO_INCREMENTAL=1
        export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"
    else
        # ─── C incremental setup with ccache ───
        echo "==> Setting up C incremental build (ccache)"
        # Install ccache if not present
        if ! command -v ccache &>/dev/null; then
            # ccache is usually pre-installed in termux container
            echo "ccache not found, continuing without it"
        else
            export CCACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/ccache"
            export CCACHE_COMPRESS=1
            export CCACHE_COMPRESSLEVEL=6
            export CCACHE_MAXSIZE=500M
            export PATH="/usr/lib/ccache:$PATH"
            echo "ccache enabled (CCACHE_DIR=$CCACHE_DIR)"
        fi
    fi
}

termux_step_post_make() {
    if [ -f "$TERMUX_PKG_SRCDIR/Cargo.toml" ]; then
        echo "==> Rust build complete"
    else
        echo "==> C build complete"
        # Show ccache stats if available
        if command -v ccache &>/dev/null && [ -n "${CCACHE_DIR-}" ]; then
            ccache -s 2>/dev/null || true
        fi
    fi
}
