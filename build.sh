#!/bin/bash

# =============================================================================
# build.sh — Termux package build script (template)
# =============================================================================
# This script is used by termux-pkg-builder to compile and package programs
# for Termux on Android. Each TERMUX_PKG_* variable configures the build.
#
# Reference: https://github.com/termux/termux-packages
# =============================================================================

# --- Package metadata --------------------------------------------------------

# URL of the project homepage
TERMUX_PKG_HOMEPAGE=https://github.com/user/termux-sample

# Short description shown in `pkg show`
TERMUX_PKG_DESCRIPTION="Sample Termux project template"

# SPDX license identifier (see https://spdx.org/licenses/)
TERMUX_PKG_LICENSE="MIT"

# Package maintainer (use your GitHub username prefixed with @)
TERMUX_PKG_MAINTAINER="@termux-user"

# Version string — follows semver. Bump this for each release.
TERMUX_PKG_VERSION=1.0.0

# URL to the source tarball.
# The variable TERMUX_PKG_VERSION can be used in the URL.
TERMUX_PKG_SRCURL=https://github.com/user/termux-sample/archive/v${TERMUX_PKG_VERSION}.tar.gz

# SHA-256 checksum of the source tarball.
# Generate with: sha256sum <file>  or  curl -L <url> | sha256sum
# Set to 64 zeroes as placeholder — replace with real hash before building.
TERMUX_PKG_SHA256=0000000000000000000000000000000000000000000000000000000000000000

# Runtime dependencies (installed automatically when the package is installed).
TERMUX_PKG_DEPENDS="libandroid-support"

# Build-time dependencies (only needed during compilation, not at runtime).
# Uncomment if needed:
# TERMUX_PKG_BUILD_DEPENDS=""

# Recommended packages (optional, suggested to install alongside).
# Uncomment if needed:
# TERMUX_PKG_RECOMMENDS=""

# --- Build configuration -----------------------------------------------------

# If true, the build happens inside the source directory rather than a
# separate build directory. Set to true for simple Makefile-based projects.
TERMUX_PKG_BUILD_IN_SRC=true

# Host architecture to build for (aarch64, arm, i686, x86_64).
# Leave unset for default (autodetected). Uncomment to force:
# TERMUX_PKG_HOSTARCH=aarch64

# Additional configure flags (for autotools projects).
# Uncomment if needed:
# TERMUX_PKG_EXTRA_CONFIGURE_ARGS=""

# Additional make flags.
# Uncomment if needed:
# TERMUX_PKG_EXTRA_MAKE_ARGS=""

# --- Hooks (commented examples) ----------------------------------------------
#
# These functions override the default build steps. Uncomment and customize
# as needed for your project.
#
# NOTE: You do NOT need to define any of these for a simple Makefile project.
# The defaults handle common cases automatically.
#
# -----------------------------------------------------------------------------
# Patch source code after extraction
# termux_step_post_get_source() {
#     echo "=> Applying additional patches..."
#     # Custom patching logic here
# }
#
# -----------------------------------------------------------------------------
# Configure the package (before make)
# termux_step_configure() {
#     if [ -f ./configure ]; then
#         ./configure --prefix=$TERMUX_PREFIX \
#                     --host=$TERMUX_HOST_PLATFORM \
#                     $TERMUX_PKG_EXTRA_CONFIGURE_ARGS
#     fi
# }
#
# -----------------------------------------------------------------------------
# Build the package (make / compile)
# termux_step_make() {
#     make $TERMUX_PKG_EXTRA_MAKE_ARGS
# }
#
# -----------------------------------------------------------------------------
# Install the package (after make)
# termux_step_make_install() {
#     make install DESTDIR=$TERMUX_PKG_MASSEDIR
# }
#
# -----------------------------------------------------------------------------
# Run after installation (e.g., for post-install scripts)
# termux_step_post_make_install() {
#     echo "=> Post-install steps..."
# }
#
# -----------------------------------------------------------------------------
# Run tests (if applicable)
# termux_step_make_test() {
#     make test
# }
