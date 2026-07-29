#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
# helpers/termux-build-config.sh — Carga configuración del proyecto
# ═══════════════════════════════════════════════════════════════
# Lee project/.termux-build-config y exporta las variables.
# Este archivo es "sourceado" por build.sh
#
# Formato de project/.termux-build-config:
#   PKG_DEPENDS="libtalloc libandroid-shmem"
#   BUILD_SYSTEM="make"  # make, autotools, cmake, meson
#   EXTRA_MAKE_ARGS="-C src"
#   CPPFLAGS_EXTRA="-DARG_MAX=131072"
#   EXTRA_ENV="PROOT_UNBUNDLE_LOADER=\$PREFIX/libexec/proot"
# ═══════════════════════════════════════════════════════════════

CONFIG_FILE="$TERMUX_PKGS__BUILD__REPO_ROOT_DIR/project/.termux-build-config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "  No .termux-build-config found, using defaults"
    return 0
fi

echo "  Loading config: $CONFIG_FILE"
source "$CONFIG_FILE"

# Aplicar configuraciones
if [ -n "${PKG_DEPENDS:-}" ]; then
    TERMUX_PKG_DEPENDS="$PKG_DEPENDS"
    echo "  Dependencies: $TERMUX_PKG_DEPENDS"
fi

if [ -n "${EXTRA_MAKE_ARGS:-}" ] && [ -z "${TERMUX_PKG_EXTRA_MAKE_ARGS:-}" ]; then
    TERMUX_PKG_EXTRA_MAKE_ARGS="$EXTRA_MAKE_ARGS"
    echo "  Make args: $TERMUX_PKG_EXTRA_MAKE_ARGS"
fi

if [ -n "${CPPFLAGS_EXTRA:-}" ]; then
    CPPFLAGS+=" $CPPFLAGS_EXTRA"
    echo "  Extra CPPFLAGS: $CPPFLAGS_EXTRA"
fi

if [ -n "${EXTRA_ENV:-}" ]; then
    while IFS= read -r env_line; do
        if [ -n "$env_line" ]; then
            export "$env_line"
            echo "  Env: $env_line"
        fi
    done <<< "$EXTRA_ENV"
fi
