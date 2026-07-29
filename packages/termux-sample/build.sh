#!/bin/bash

# =============================================================================
# build.sh — Termux package build script (fuente local trackeada)
# =============================================================================
#
# Este script compila termux-sysinfo usando termux-pkg-builder.
#
# DIFERENCIA CLAVE con el template estándar:
#   En lugar de descargar un tarball desde TERMUX_PKG_SRCURL, este script
#   usa fuente LOCAL trackeada en el directorio ./project/ del repositorio.
#
#   La función termux_step_get_source() se overridea para copiar el contenido
#   de $TERMUX_PKG_BUILDER_DIR/project/ al directorio de compilación usando
#   rsync. Esto permite:
#     - Compilar con caché incremental (solo cambia lo editado)
#     - Sin dependencia de servidores externos para obtener la fuente
#     - El usuario edita el código en ./project/, hace commit, y CI compila
#
# Para uso local en Termux (sin termux-pkg-builder):
#   cd project/ && make && make install PREFIX=$PREFIX
#
# Referencia: https://github.com/termux/termux-packages
# =============================================================================

# --- Metadatos del paquete ---------------------------------------------------

# URL del proyecto o repositorio
TERMUX_PKG_HOMEPAGE=https://github.com/user/termux-sample

# Descripción breve del paquete (se muestra en `pkg show`)
TERMUX_PKG_DESCRIPTION="System info utility for Termux (tracked source)"

# Identificador SPDX de la licencia (ver https://spdx.org/licenses/)
TERMUX_PKG_LICENSE="MIT"

# Mantenedor del paquete (usar nombre de GitHub con prefijo @)
TERMUX_PKG_MAINTAINER="@termux-user"

# Versión del paquete (semver). Incrementar en cada release.
# Esta versión se inyecta en el binario como constante VERSION
# a través de CFLAGS en el Makefile.
TERMUX_PKG_VERSION=1.0.0

# URL del tarball de fuentes.
# Se deja VACÍO porque NO descargamos nada externo;
# la fuente está trackeada localmente en ./project/.
TERMUX_PKG_SRCURL=

# SHA-256 del tarball de fuentes.
# Se deja VACÍO porque no hay tarball que verificar.
TERMUX_PKG_SHA256=

# Dependencias en tiempo de ejecución (se instalan automáticamente
# cuando el usuario instala el paquete con `pkg install`).
# libandroid-support proporciona funciones de libc compatibles
# con Android (útil para ciertas funciones de stdlib).
# TERMUX_PKG_DEPENDS=""   # Sin dependencias

# Dependencias en tiempo de compilación (solo necesarias para compilar,
# no para ejecutar). Comentar si no se necesitan.
# TERMUX_PKG_BUILD_DEPENDS=""

# Paquetes recomendados (opcionales, se sugieren al instalar).
# TERMUX_PKG_RECOMMENDS=""

# --- Configuración de compilación --------------------------------------------

# Si es true, la compilación ocurre dentro del directorio fuente
# en lugar de un directorio de build separado.
# Necesario para proyectos con Makefile simple (como este).
TERMUX_PKG_BUILD_IN_SRC=true

# NO extraer tarball de fuentes.
# Como TERMUX_PKG_SRCURL está vacío, esta bandera evita que el
# builder intente descargar y extraer un tarball inexistente.
TERMUX_PKG_SKIP_SRC_EXTRACT=true

# Arquitectura destino (aarch64, arm, i686, x86_64).
# Dejar sin definir para autodetección. Descomentar para forzar:
# TERMUX_PKG_HOSTARCH=aarch64

# Banderas adicionales para configure (solo autotools).
# TERMUX_PKG_EXTRA_CONFIGURE_ARGS=""

# Banderas adicionales para make.
# TERMUX_PKG_EXTRA_MAKE_ARGS=""

# -----------------------------------------------------------------------------
# termux_step_get_source — OVERRIDE: obtener fuente local
#
# En lugar de descargar un tarball, copiamos el contenido del directorio
# ./project/ (que está trackeado en el repositorio) al directorio de
# compilación ($TERMUX_PKG_SRCDIR).
#
# Variables disponibles:
#   $TERMUX_PKG_BUILDER_DIR : Directorio donde está este build.sh
#                             (dentro del árbol de termux-packages)
#   $TERMUX_PKG_SRCDIR      : Directorio donde se espera la fuente
#                             (generalmente $TERMUX_PKG_BUILDER_DIR/src)
#
# Nota: TERMUX_PKG_SKIP_SRC_EXTRACT=true evita que el builder intente
# descargar/extaer el tarball antes de llamar a este hook.
# -----------------------------------------------------------------------------
termux_step_get_source() {
    echo "=> Obteniendo fuente local desde $TERMUX_PKG_BUILDER_DIR/project/"

    # Crear el directorio destino si no existe
    mkdir -p "$TERMUX_PKG_SRCDIR"

    # Copiar todo el contenido de project/ al directorio de compilación
    # usando rsync:
    #   -a  : modo archivo (preserva permisos, timestamps, etc.)
    #   --delete : elimina archivos en destino que ya no existen en origen
    #             (útil cuando se renombran o eliminan fuentes)
    rsync -a --delete "$TERMUX_PKG_BUILDER_DIR/project/" "$TERMUX_PKG_SRCDIR/"

    echo "=> Fuente local copiada: $(find "$TERMUX_PKG_SRCDIR" -type f | wc -l) archivos"
}

# -----------------------------------------------------------------------------
# NOTA: No es necesario overr Idea termux_step_configure(), termux_step_make()
# o termux_step_make_install() porque:
#   - TERMUX_PKG_BUILD_IN_SRC=true hace que el builder compile desde $TERMUX_PKG_SRCDIR
#   - El Makefile tiene targets estándar (all/install/clean) que el builder
#     invoca automáticamente
#   - DESTDIR se pasa automáticamente como $TERMUX_PKG_MASSEDIR
#
# Si el proyecto requiriera pasos personalizados, se pueden overr Idea
# los hooks correspondientes (ver ejemplos comentados abajo).
# -----------------------------------------------------------------------------

# --- Hooks adicionales (comentados como referencia) --------------------------
#
# termux_step_post_get_source() {
#     echo "=> Aplicando parches adicionales..."
#     # Por ejemplo, aplicar parches desde $TERMUX_PKG_BUILDER_DIR/patches/
# }
#
# termux_step_make() {
#     make $TERMUX_PKG_EXTRA_MAKE_ARGS
# }
#
# termux_step_make_install() {
#     make install DESTDIR=$TERMUX_PKG_MASSEDIR
# }
#
# termux_step_post_make_install() {
#     echo "=> Post-install: verificando binario..."
#     file "$TERMUX_PKG_MASSEDIR/$TERMUX_PREFIX_BIN/termux-sysinfo"
# }
