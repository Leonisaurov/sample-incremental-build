#!/bin/bash
# =============================================================================
# scripts/setup-env.sh — Environment setup helper for termux-sample
# =============================================================================
#
# This script verifies that the required Termux environment variables are set,
# displays environment information, and creates necessary directories.
#
# Usage:
#   source scripts/setup-env.sh    # Source it to keep env changes
#   bash scripts/setup-env.sh      # Run it (env changes are lost)
#
# It is safe to run multiple times.
# =============================================================================

set -e  # Exit on first error

# --- Color output helpers ----------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Banner ------------------------------------------------------------------
echo ""
echo "========================================"
echo "  termux-sample — Environment Setup"
echo "========================================"
echo ""

# --- Step 1: Check TERMUX_PREFIX --------------------------------------------
info "Checking TERMUX_PREFIX..."

if [ -z "${TERMUX_PREFIX:-}" ]; then
    warn "TERMUX_PREFIX is NOT set."
    warn "Falling back to PREFIX from environment..."

    if [ -z "${PREFIX:-}" ]; then
        error "PREFIX is also not set. Are you running inside Termux?"
        error "Please run this script within a Termux session."
        export TERMUX_PREFIX="/data/data/com.termux/files/usr"
        warn "Using default: TERMUX_PREFIX=$TERMUX_PREFIX"
    else
        export TERMUX_PREFIX="$PREFIX"
        success "TERMUX_PREFIX set to: $TERMUX_PREFIX"
    fi
else
    success "TERMUX_PREFIX = $TERMUX_PREFIX"
fi

# --- Step 2: Check TMPDIR ----------------------------------------------------
info "Checking TMPDIR..."

if [ -z "${TMPDIR:-}" ]; then
    warn "TMPDIR is NOT set."
    export TMPDIR="/data/data/com.termux/files/usr/tmp"
    warn "Using default: TMPDIR=$TMPDIR"
else
    success "TMPDIR = $TMPDIR"
fi

# Verify TMPDIR exists
if [ ! -d "$TMPDIR" ]; then
    warn "TMPDIR ($TMPDIR) does not exist. Creating it..."
    mkdir -p "$TMPDIR"
fi

# --- Step 3: Check HOME ------------------------------------------------------
info "Checking HOME..."

if [ -z "${HOME:-}" ]; then
    error "HOME is not set! This is unusual."
    export HOME="/data/data/com.termux/files/home"
    warn "Using default: HOME=$HOME"
else
    success "HOME = $HOME"
fi

# --- Step 4: Display system information --------------------------------------
echo ""
info "--- System Information ---"
echo "  Architecture  : $(uname -m)"
echo "  Kernel        : $(uname -s)"
echo "  Hostname      : $(uname -n)"
echo "  User          : $(whoami 2>/dev/null || echo 'unknown')"
echo "  Shell         : $SHELL"
echo "  PREFIX        : ${PREFIX:-"(not set)"}"
echo "  TERMUX_PREFIX : $TERMUX_PREFIX"
echo "  TMPDIR        : $TMPDIR"
echo "  HOME          : $HOME"

# --- Step 5: Create necessary directories ------------------------------------
echo ""
info "Creating project directories (if they don't exist)..."

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIRS=(
    "$PROJECT_DIR/src"
    "$PROJECT_DIR/patches"
    "$PROJECT_DIR/.github/workflows"
    "$PROJECT_DIR/scripts"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        info "  Created: $dir"
    else
        success "  Exists:  $dir"
    fi
done

# --- Summary -----------------------------------------------------------------
echo ""
echo "========================================"
echo "  Environment is ready!"
echo "========================================"
echo ""
info "Project directory: $PROJECT_DIR"
info "To build:          cd $PROJECT_DIR && make -C src"
info "To install:        make -C src install PREFIX=\$TERMUX_PREFIX"
echo ""

# If sourced, keep the exported variables in the calling shell
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    success "Environment variables exported to current shell."
fi
