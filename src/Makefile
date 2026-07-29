# =============================================================================
# src/Makefile — Build system for termux-sample
# =============================================================================
# This Makefile compiles main.c and installs the binary into
#   $(DESTDIR)$(PREFIX)/bin/termux-sample
#
# Targets:
#   all     — Compile the program
#   install — Copy the binary to the installation prefix
#   clean   — Remove build artifacts
# =============================================================================

# --- Configuration -----------------------------------------------------------

# Compiler and flags
CC       ?= gcc
CFLAGS   ?= -O2 -Wall -Wextra -pedantic
LDFLAGS  ?=

# The name of the final binary
BINARY   := termux-sample

# Source files
SRC      := main.c

# Object files (derived from source)
OBJ      := $(SRC:.c=.o)

# Installation prefix.
# When building inside termux-pkg-builder, PREFIX is set automatically
# to /data/data/com.termux/files/usr (or $TERMUX_PREFIX).
# For local builds, default to the Termux system prefix.
PREFIX   ?= /data/data/com.termux/files/usr

# DESTDIR is used by termux-pkg-builder for staged installs.
# When set, files are installed to $(DESTDIR)$(PREFIX)/bin/.
DESTDIR  ?=

# Full install path for the binary
INSTALL_DIR  := $(DESTDIR)$(PREFIX)/bin
INSTALL_PATH := $(INSTALL_DIR)/$(BINARY)

# --- Targets -----------------------------------------------------------------

# Default target: compile the program
all: $(BINARY)

# Link the object file(s) into the final binary
$(BINARY): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^
	@echo "==> Built: $(BINARY)"

# Compile each .c file into a .o file
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Install the binary into the prefix
install: $(BINARY)
	@mkdir -p $(INSTALL_DIR)
	cp $(BINARY) $(INSTALL_PATH)
	@echo "==> Installed: $(INSTALL_PATH)"

# Remove build artifacts
clean:
	rm -f $(OBJ) $(BINARY)
	@echo "==> Cleaned build artifacts"

# Declare phony targets (not actual files)
.PHONY: all install clean
