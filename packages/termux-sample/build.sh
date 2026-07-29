# Rust project maintained in project/ (content-7z — TUI 7z content viewer)
TERMUX_PKG_HOMEPAGE=https://github.com/Leonisaurov/content-7z
TERMUX_PKG_DESCRIPTION="TUI tool to visualize and navigate 7z archive contents (incremental build test)"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-user"
TERMUX_PKG_VERSION="0.1.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true

export CARGO_INCREMENTAL=1
export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    rsync -a --delete --exclude=target/ "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
}

termux_step_pre_configure() {
    termux_setup_rust
}
