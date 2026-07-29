# Termux Incremental Build Template

![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=terminal)
![Rust](https://img.shields.io/badge/Rust-✓-DEA584?logo=rust)
![C](https://img.shields.io/badge/C-✓-A8B9CC?logo=c)
![Zig](https://img.shields.io/badge/Zig-✓-F7A41D?logo=zig)
![MIT](https://img.shields.io/badge/license-MIT-blue)

---

## Descripción

Template inteligente para compilar programas para **Termux** usando el build system oficial `termux-packages`. A diferencia de un scaffold tradicional, este template **auto-detecta** el lenguaje de programación del proyecto (Rust, C o Zig) y aplica automáticamente la estrategia de **compilación incremental óptima** para cada uno, maximizando la velocidad de rebuild en CI.

El código fuente se edita en `project/`, se configura opcionalmente con `project/.termux-build-config`, y con un solo `git push` se dispara un pipeline completo en GitHub Actions que produce un paquete `.deb` listo para instalar en Termux. Las cachés de toolchain y objetos compilados se preservan entre ejecuciones, haciendo que los builds subsecuentes sean drásticamente más rápidos.

Diseñado para desarrolladores que necesitan un flujo CI/CD robusto, predecible y rápido para empaquetar software en ecosistema Termux, soportando los tres lenguajes más utilizados en el mundo del scripting de sistemas y herramientas de línea de comandos.

---

## Lenguajes soportados

| Lenguaje | Detección             | Estrategia incremental                                                            | Rendimiento                       |
|----------|-----------------------|-----------------------------------------------------------------------------------|-----------------------------------|
| Rust     | `project/Cargo.toml`  | `CARGO_INCREMENTAL=1` + `CARGO_TARGET_DIR` cacheado por hash de `Cargo.lock`      | **13× más rápido** (25s → 1.8s)   |
| Zig      | `project/build.zig`   | `ZIG_GLOBAL_CACHE_DIR` + `ZIG_LOCAL_CACHE_DIR` persistentes entre builds          | **26% más rápido** (24s → 17.7s)  |
| C        | `project/*.c` / `Makefile` | `ccache` + `rsync --checksum` preserva `.o` para que `make` sea incremental | Build ya es instantáneo (~1.5s)   |

---

## Quick Start

```bash
# 1. Clonar el repositorio
git clone <repo-url> && cd Sample

# 2. Poner tu código en project/
#    Dependiendo del lenguaje, alguno de estos archivos:
#    - Rust:   project/Cargo.toml
#    - Zig:    project/build.zig
#    - C:      project/Makefile + project/*.c

# 3. Configurar opcionalmente (ver sección de configuración)
#    echo 'PKG_DEPENDS="libtalloc"' > project/.termux-build-config

# 4. Commit + Push → CI automático
bash helpers/push-and-build.sh "mi primer cambio"
```

---

## Estructura del directorio

```
Sample/
│
├── project/                      ← ⭐ TU CÓDIGO (se auto-detecta el lenguaje)
│   ├── Cargo.toml                →   Rust (auto-detectado)
│   ├── build.zig                 →   Zig (auto-detectado)
│   ├── build.zig.zon             →   Zig (alternativo)
│   ├── src/main.zig              →   Código fuente de ejemplo (Zig)
│   ├── Makefile / *.c            →   C (auto-detectado si no hay Cargo.toml ni build.zig)
│   ├── LICENSE                   →   Licencia del proyecto
│   └── .termux-build-config      →   (Opcional) Configuración extra del paquete
│
├── build-package.sh              ← Orquestador principal de build (termux-packages)
├── build-all.sh                  ← Build de todos los paquetes del repositorio
├── clean.sh                      ← Limpieza de artefactos de build
├── repo.json                     ← Configuración del repositorio APT/Pacman
├── VERSION                       ← Versión del template (1.0.0)
│
├── scripts/ (94 files)           ← Pipeline completo de build de termux-packages
│   ├── build/                    ←   Steps del pipeline (configuración, compilación, empaquetado)
│   │   ├── configure/            ←     termux_step_configure_autotools, _cmake, _meson, _cabal
│   │   ├── get_source/           ←     termux_step_get_source (tarball, git, rsync local)
│   │   ├── setup/                ←     termux_setup_* (toolchains: rust, zig, go, cmake, ninja…)
│   │   ├── toolchain/            ←     Toolchains para NDK (23c, 29, GNU)
│   │   ├── termux_step_*.sh      ←     39 hooks del pipeline de build
│   │   └── ...                   ←     termux_download_*, termux_error_exit, etc.
│   ├── bin/                      ←   Utilidades (dry-run, revbump)
│   ├── utils/                    ←   Helpers de Docker y Termux
│   ├── properties.sh             ←   Metadatos de paquetes
│   ├── buildorder.py             ←   Orden topológico de compilación
│   ├── Dockerfile                ←   Imagen Docker para build
│   ├── run-docker.sh             ←   Ejecuta build dentro de Docker
│   └── ...                       ←   setup-*.sh, lint-packages.sh, config.guess, etc.
│
├── packages/
│   └── termux-sample/
│       └── build.sh              ← Receta del paquete (auto-detecta lenguaje y carga helper)
│
├── helpers/
│   ├── build-rust.sh             →   Rust: CARGO_INCREMENTAL + cargo target cache
│   ├── build-c.sh                →   C: ccache + rsync checksum
│   ├── build-zig.sh              →   Zig: zig global + local cache
│   ├── termux-build-config.sh    →   Cargador de project/.termux-build-config
│   ├── push-and-build.sh         →   Script helper para commit + push rápido
│   └── setup-env.sh              →   Verificador de entorno Termux local
│
├── ndk-patches/                  ← Parches para Android NDK
│   ├── 29/                       ←   Parches específicos para API 29
│   ├── langinfo.h                ←   Header langinfo.h compatible con NDK
│   └── libintl.h                 ←   Header libintl.h compatible con NDK
│
├── patches/                      ← Parches opcionales del paquete (orden alfabético)
│
├── .github/
│   └── workflows/
│       └── build.yml             ← CI con 3 estrategias de caché según lenguaje
│
├── .gitignore
├── CHANGELOG.md
├── LICENSE                       ← MIT
└── README.md                     ← Este archivo
```

---

## Configuración del proyecto (`project/.termux-build-config`)

El archivo opcional `project/.termux-build-config` permite personalizar la receta de empaquetado sin tocar `packages/termux-sample/build.sh`. Es cargado automáticamente por `helpers/termux-build-config.sh`.

### Opciones disponibles

| Variable             | Descripción                                                              | Ejemplo                                         |
|----------------------|--------------------------------------------------------------------------|-------------------------------------------------|
| `PKG_DEPENDS`        | Dependencias en tiempo de ejecución del paquete                          | `PKG_DEPENDS="libtalloc libandroid-shmem"`      |
| `BUILD_SYSTEM`       | Sistema de build (make, autotools, cmake, meson)                         | `BUILD_SYSTEM="make"`                            |
| `EXTRA_MAKE_ARGS`    | Argumentos extra para `make` (ej: `-C src` para build en subdirectorio)  | `EXTRA_MAKE_ARGS="-C src"`                       |
| `CPPFLAGS_EXTRA`     | Flags extra del preprocesador de C                                       | `CPPFLAGS_EXTRA="-DARG_MAX=131072"`              |
| `EXTRA_ENV`          | Variables de entorno extra (una por línea)                               | `EXTRA_ENV="PROOT_UNBUNDLE_LOADER=\$PREFIX/libexec/proot"` |

### Ejemplo completo

```bash
# project/.termux-build-config
PKG_DEPENDS="libtalloc libandroid-shmem"
BUILD_SYSTEM="make"
EXTRA_MAKE_ARGS="-C src"
CPPFLAGS_EXTRA="-DARG_MAX=131072"
EXTRA_ENV="MY_CUSTOM_VAR=hello"
```

---

## Flujo de CI/CD

```
git push → GitHub Actions
  │
  ├── 1. Pull container (ghcr.io/termux/package-builder)
  │
  ├── 2. Auto-detect: ¿Rust, C o Zig?
  │      ├── project/build.zig?       → Zig
  │      ├── project/Cargo.toml?       → Rust
  │      └── default                   → C
  │
  ├── 3. Restore cache según lenguaje
  │      ├── Rust: toolchain + cargo target (key = hash de Cargo.lock)
  │      ├── C:    toolchain + ccache (key = hash de headers/Makefile)
  │      └── Zig:  toolchain + zig-cache (key = hash de build.zig + *.zig)
  │
  ├── 4. Fix NDK path (symlink para container HOME)
  │
  ├── 5. build-package.sh -I -a aarch64 termux-sample
  │      ├── Rsync project/ → build dir (excluye caches según lenguaje)
  │      └── Compilación incremental ⚡
  │
  ├── 6. Collect .deb artifact
  │
  ├── 7. Upload .deb (retención: 7 días)
  │
  └── 8. Save cache → próximo build ♻️
```

### Triggers del workflow

El CI se activa automáticamente con push a:

- `project/**` — cambios en el código fuente
- `packages/termux-sample/build.sh` — cambios en la receta
- `.github/workflows/build.yml` — cambios en el pipeline
- `helpers/**` — cambios en los scripts de build

---

## Estrategias de caché

Cada lenguaje tiene una estrategia de caché específica para maximizar la reutilización de objetos compilados entre builds.

| Cache       | Path en container                                        | Key (hash)                                       | ¿Para qué sirve?                                  |
|-------------|----------------------------------------------------------|--------------------------------------------------|---------------------------------------------------|
| Toolchain   | `~/.termux-build/`                                       | `build.sh` + `packages/rust/build.sh`            | NDK, toolchain, zig binario descargado            |
| Cargo target| `~/.termux-build/termux-sample/cargo-target/`            | `project/Cargo.lock`                             | Objetos compilados de Rust (evita recompilar crates) |
| ccache      | `~/.termux-build/termux-sample/ccache/`                  | `Makefile` + `*.h` + `.termux-build-config`      | Objetos compilados de C (hash por contenido)      |
| Zig cache   | `~/.termux-build/termux-sample/zig-cache/`               | `build.zig` + `build.zig.zon` + `src/**/*.zig`   | Objetos compilados de Zig                         |

**Clave del diseño**: las keys de caché se basan en archivos de **configuración** (Cargo.lock, Makefile, build.zig), no en el código fuente. Esto permite que `make`, `cargo` y `zig build` detecten naturalmente qué archivos cambiaron y recompilen solo lo necesario.

---

## Ejemplos por lenguaje

### Rust (ej: content-7z)

```bash
# project/ contiene:
#   Cargo.toml  (con dependencias)
#   src/main.rs

# El auto-detect encuentra Cargo.toml → usa helpers/build-rust.sh
# Configura:
#   CARGO_INCREMENTAL=1
#   CARGO_TARGET_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/cargo-target"

# rsync excluye target/ para preservar el cache de cargo
# Efecto: 73 crates → solo recompila el crate modificado
# Tiempo: ~1.8s (vs ~25s sin caché)
```

### C (ej: proot)

```bash
# project/ contiene:
#   src/GNUmakefile
#   src/*.c

# project/.termux-build-config:
#   PKG_DEPENDS="libtalloc"
#   EXTRA_MAKE_ARGS="-C src"
#   CPPFLAGS_EXTRA="-DARG_MAX=131072"

# El auto-detect (fallback) → usa helpers/build-c.sh
# rsync --checksum --exclude='*.o' preserva objetos compilados
# ccache cachea por contenido, no por timestamp
# Efecto: 75 archivos .c → build ~1.5s
```

### Zig

```bash
# project/ contiene:
#   build.zig
#   src/main.zig

# El auto-detect encuentra build.zig → usa helpers/build-zig.sh
# Configura:
#   ZIG_GLOBAL_CACHE_DIR="${TERMUX_COMMON_CACHEDIR}/zig-global-cache"
#   ZIG_LOCAL_CACHE_DIR="${TERMUX_TOPDIR}/${TERMUX_PKG_NAME}/zig-cache"

# rsync excluye zig-cache/ y zig-out/ para preservar caches
# zig build recibe --cache-dir y --global-cache-dir explícitos
# Efecto: ~26% más rápido (24s → 17.7s)
```

---

## Scripts auxiliares

| Script                        | Propósito                                                                    |
|-------------------------------|------------------------------------------------------------------------------|
| `helpers/push-and-build.sh`   | Commit + push rápido de `project/` que dispara el CI automático              |
| `helpers/build-rust.sh`       | Template de build para proyectos Rust (incremental con cargo)                |
| `helpers/build-c.sh`          | Template de build para proyectos C (incremental con ccache + make)           |
| `helpers/build-zig.sh`        | Template de build para proyectos Zig (incremental con zig cache)             |
| `helpers/termux-build-config.sh` | Cargador de configuración desde `project/.termux-build-config`             |
| `helpers/setup-env.sh`        | Verificador de entorno Termux para desarrollo local                          |

### push-and-build.sh

```bash
# Uso: bash helpers/push-and-build.sh "mensaje del commit"
#
# 1. Verifica que hay cambios en project/
# 2. Muestra git diff --stat
# 3. Ejecuta: git add project/ && git commit -m "mensaje" && git push
# 4. Imprime URL de seguimiento en GitHub Actions
```

---

## packages/termux-sample/build.sh — La receta

El script `packages/termux-sample/build.sh` es el corazón del template. Define los metadatos del paquete Termux y **auto-detecta** el lenguaje del proyecto:

```bash
# Detección en orden:
# 1. ¿Existe project/build.zig?           → Zig   → source helpers/build-zig.sh
# 2. ¿Existe project/Cargo.toml?          → Rust  → source helpers/build-rust.sh
# 3. Caso contrario                       → C     → source helpers/build-c.sh
```

### Variables del paquete

| Variable                      | Valor                                            | Descripción                            |
|-------------------------------|--------------------------------------------------|----------------------------------------|
| `TERMUX_PKG_HOMEPAGE`         | `https://github.com/Leonisaurov/sample-incremental-build` | URL del proyecto           |
| `TERMUX_PKG_DESCRIPTION`      | `"Universal template (auto-detect Rust/C/Zig)"`  | Descripción del paquete                |
| `TERMUX_PKG_LICENSE`          | `MIT`                                            | Identificador SPDX de licencia         |
| `TERMUX_PKG_VERSION`          | `1.0.0`                                          | Versión semver                         |
| `TERMUX_PKG_SKIP_SRC_EXTRACT` | `true`                                           | No extraer tarball (usamos rsync local)|
| `TERMUX_PKG_BUILD_IN_SRC`     | `true`                                           | Compila dentro del source dir          |

---

## Limitaciones

- **Pull de imagen Docker (~2 min):** El tiempo de descarga de `ghcr.io/termux/package-builder` domina el tiempo total del pipeline. Las cachés mitigan el tiempo de build, pero el pull inicial es inevitable.
- **ccache no pre-instalado:** El contenedor no incluye `ccache` por defecto. El helper `build-c.sh` intenta instalarlo vía `apt-get`, pero esto puede fallar si el mirror de paquetes no está disponible.
- **Target Zig `linux-musl`:** El target de Zig usa `linux-musl` en lugar de `android` por una limitación del upstream de Zig. Esto puede afectar la compatibilidad con algunas APIs de Android.
- **Compilación solo para `aarch64`:** El workflow actual compila únicamente para arquitectura `aarch64`. Para otras arquitecturas (arm, i686, x86_64), modifica el flag `-a` en `.github/workflows/build.yml`.
- **No compilar directamente en Termux:** El dispositivo Termux no está diseñado para compilaciones pesadas. Usa GitHub Actions (CI) o Docker local para compilar.

---

## Licencia

Distribuido bajo la licencia **MIT**. Consulta el archivo [`LICENSE`](./LICENSE) para más detalles.
