# =============================================================================
# project/Makefile — Build system for termux-sysinfo
# =============================================================================
# Este Makefile compila el programa termux-sysinfo para Termux.
#
# Targets:
#   all     — Compila el programa (por defecto)
#   install — Copia el binario a $(DESTDIR)$(PREFIX)/bin/termux-sysinfo
#   clean   — Elimina binarios y archivos objeto
#
# Uso local en Termux:
#   make
#   make install PREFIX=$PREFIX
#
# Uso en termux-pkg-builder (CI):
#   make
#   make install DESTDIR=$TERMUX_PKG_MASSEDIR PREFIX=$TERMUX_PREFIX
# =============================================================================

# --- Variables de compilación ------------------------------------------------

# Compilador C. Se puede sobrescribir desde la línea de comandos:
#   make CC=clang
CC ?= gcc

# Banderas del compilador.
# -Wall -Wextra:   muestra todas las advertencias
# -O2:             optimización estándar
# -DVERSION=...:   inyecta la versión en el código (constante VERSION)
CFLAGS ?= -Wall -Wextra -O2 -DVERSION=\"1.0.0\"

# Banderas del enlazador (vacío por defecto).
LDFLAGS ?=

# --- Archivos del proyecto ---------------------------------------------------

# Nombre del binario final
BINARY := termux-sysinfo

# Directorio donde están los fuentes
SRC_DIR := src

# Archivo fuente principal
SRC := $(SRC_DIR)/main.c

# Archivo objeto derivado
OBJ := $(SRC_DIR)/main.o

# --- Destino de instalación --------------------------------------------------

# Prefijo de instalación.
# En Termux es normalmente /data/data/com.termux/files/usr.
# Se puede sobrescribir desde la línea de comandos:
#   make install PREFIX=$PREFIX
PREFIX ?= /data/data/com.termux/files/usr

# DESTDIR se usa para instalaciones empaquetadas (staged installs).
# En termux-pkg-builder se establece automáticamente como
# $TERMUX_PKG_MASSEDIR.
DESTDIR ?=

# Ruta completa donde se instalará el binario
INSTALL_DIR  := $(DESTDIR)$(PREFIX)/bin
INSTALL_PATH := $(INSTALL_DIR)/$(BINARY)

# --- Targets -----------------------------------------------------------------

# Target por defecto: compilar el programa
.PHONY: all
all: $(BINARY)

# Regla de enlace: combina el objeto en el binario final
$(BINARY): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^
	@echo "==> Compilado: $(BINARY) v$(VERSION)"

# Regla de compilación: genera el objeto a partir del fuente
$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c -o $@ $<

# Instalación: copia el binario al directorio de destino
.PHONY: install
install: $(BINARY)
	@mkdir -p $(INSTALL_DIR)
	cp $(BINARY) $(INSTALL_PATH)
	@echo "==> Instalado: $(INSTALL_PATH)"

# Limpieza: elimina binarios y objetos
.PHONY: clean
clean:
	rm -f $(OBJ) $(BINARY)
	@echo "==> Limpieza completa"
