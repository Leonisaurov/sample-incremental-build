# Universal build script - auto-detects Rust vs C
TERMUX_PKG_HOMEPAGE=https://proot-me.github.io/
TERMUX_PKG_DESCRIPTION="Universal project template (auto-detect Rust/C)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux-user"
TERMUX_PKG_VERSION="1.0.0"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libtalloc"

termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"

    if [ -f "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/Cargo.toml" ]; then
        echo "==> Detected Rust project"
        rsync -a --delete --exclude=target/ \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    else
        echo "==> Detected C project"
        # Preserve existing .o files for make's incremental compilation
        rsync -a --delete --exclude='*.o' --exclude='*.d' --exclude='*.res' \
            --exclude='proot' --exclude='loader/loader' \
            "$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    fi
}

termux_step_pre_configure() {
    if [ -f "$TERMUX_PKG_SRCDIR/Cargo.toml" ]; then
        echo "==> Setting up Rust incremental build"
        termux_setup_rust
        export CARGO_INCREMENTAL=1
        export CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"
    else
        echo "==> Setting up C incremental build"
        # ccache for C compilation caching
        if command -v ccache &>/dev/null; then
            echo "  ccache found"
        else
            echo "  Installing ccache..."
            apt-get update -qq 2>/dev/null || true
            apt-get install -y -qq ccache 2>/dev/null && echo "  ccache installed" || echo "  ccache install failed"
        fi

        if command -v ccache &>/dev/null; then
            export CCACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/ccache"
            export CCACHE_COMPRESS=1
            export CCACHE_COMPRESSLEVEL=6
            export CCACHE_MAXSIZE=500M
            # Use ccache as compiler wrapper
            export PATH="/usr/lib/ccache:$PATH"
            echo "  ccache enabled: $CCACHE_DIR"
        else
            echo "  ccache not available"
        fi

        # Detect build system
        if [ -f src/GNUmakefile ] || [ -f src/Makefile ]; then
            echo "  Makefile found in src/, using -C src"
            export TERMUX_PKG_EXTRA_MAKE_ARGS="-C src"
            CPPFLAGS+=" -DARG_MAX=131072 -DVERSION=\\\"${TERMUX_PKG_VERSION}\\\""
            # Proot-specific: unbundle loader to avoid llvm-objcopy wrapping issues
            if [ -f src/GNUmakefile ]; then
                echo "  Detected proot (GNUmakefile in src/)"
                export PROOT_UNBUNDLE_LOADER=$TERMUX_PREFIX/libexec/proot
            fi
        elif [ -f Makefile ] || [ -f makefile ]; then
            echo "  Makefile found in root"
        fi
    fi
}

termux_step_post_make() {
    if command -v ccache &>/dev/null && [ -n "${CCACHE_DIR-}" ]; then
        echo "==> ccache statistics:"
        ccache -s 2>/dev/null || true
    fi
}
