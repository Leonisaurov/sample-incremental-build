# Termux Sample Project

![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=terminal)
![MIT](https://img.shields.io/badge/license-MIT-blue)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF)

## Descripción

Template completo para compilar programas para Termux usando el build system
oficial `termux-packages`. Este repositorio integra el pipeline completo de
empaquetado — `build-package.sh`, `scripts/`, `ndk-patches/` — junto con el
código fuente trackeado en `project/` y CI en GitHub Actions con caché
incremental.

A diferencia de un scaffold genérico, aquí el código fuente y la configuración
de empaquetado conviven en un mismo repositorio. El desarrollador edita en
`project/`, hace commit y push, y GitHub Actions compila automáticamente un
paquete `.deb` publicable.

## Flujo de trabajo

```
Tú editas → ./project/src/main.c
       │
       ▼
  git add project/ + git commit + git push
       │
       ▼
  GitHub Actions
       │
       ├── 1. actions/checkout@v4
       ├── 2. Restaura caché (~/.termux-build/)  ← Incremental ♻️
       ├── 3. ./build-package.sh -I -a aarch64 termux-sample
       │       └── Lee packages/termux-sample/build.sh
       │       └── termux_step_get_source() → rsync desde project/
       │       └── Compila termux-sysinfo con Makefile
       ├── 4. Sube .deb como artifact
       └── 5. Actualiza caché para próxima vez
```

## Requisitos

| Recurso                  | Propósito                                      |
|--------------------------|------------------------------------------------|
| **GitHub repo**          | Alojar el código y ejecutar GitHub Actions     |
| **GitHub Actions**       | Compilación automática en cada push            |
| **Container Docker**     | Imagen `ghcr.io/termux/termux-packages:latest` (usada en CI) |

## Cómo usar

### Editar código

Todo el código fuente vive en `project/`. Edita los archivos directamente:

```bash
vim project/src/main.c
vim project/Makefile
```

El archivo `project/src/main.c` es el programa de ejemplo `termux-sysinfo`.
Puedes modificarlo o reemplazarlo por completo.

### Compilar localmente (prueba rápida)

Para validar que el código compila antes de hacer commit, usa el Makefile
local dentro de `project/`:

```bash
cd project && make && ./termux-sysinfo
```

> **Nota**: Esta compilación es nativa y no produce un paquete `.deb`. Sirve
> únicamente para validación rápida en Termux o Linux. La compilación cruzada
> para el target Termux ocurre en CI.

### Commit + Push (dispara CI)

La forma recomendada de subir cambios y activar el build automático:

```bash
# Opción manual
git add project/
git commit -m "update(project): mi cambio"
git push
```

El CI se activa automáticamente porque el workflow `build.yml` escucha cambios
en `project/**`, `packages/termux-sample/build.sh` y
`.github/workflows/build.yml`.

Para un flujo más ágil, puedes crear un alias o script local que ejecute estos
tres comandos secuencialmente.

## Caché incremental

El workflow de GitHub Actions utiliza `actions/cache@v4` para acelerar builds
consecutivos reutilizando el estado de compilación anterior.

| Concepto          | Detalle                                                       |
|-------------------|---------------------------------------------------------------|
| **Cache key**     | `termux-build-${{ hashFiles('project/**', 'packages/termux-sample/build.sh') }}` |
| **Restore keys**  | `termux-build-` (busca cualquier caché previa)                |
| **Ruta cacheadas** | `/home/builder/.termux-build`                                |
| **Cuándo se guarda** | Al finalizar el job, si la key no existía previamente        |

**Efecto práctico**: si cambias un solo archivo fuente en `project/`, el cache
restore encuentra la caché anterior y `make` solo recompila lo necesario. El
directorio `~/.termux-build` contiene objetos compilados, dependencias
descargadas y el estado completo del builder de termux-packages. Los builds
subsecuentes (incluso en ramas diferentes) suelen completarse en una fracción
del tiempo del primero.

## Estructura del proyecto

```
Sample/
├── build-package.sh              ← Orquestador principal de build (839 líneas)
├── build-all.sh                  ← Build de todos los paquetes del repo
├── clean.sh                      ← Limpieza de artefactos de build
├── repo.json                     ← Configuración del repositorio APT
│
├── scripts/                      ← Pipeline completo de termux-packages
│   ├── build/                    ←   Pasos del pipeline
│   │   ├── configure/            ←     termux_step_configure (autotools, cmake, meson, cabal)
│   │   ├── get_source/           ←     termux_step_get_source (tarball, git, local)
│   │   ├── setup/                ←     termux_setup_* (toolchains, cmake, rust, go, ninja…)
│   │   ├── toolchain/            ←     Toolchains para NDK (23c, 29, GNU)
│   │   ├── termux_step_*.sh      ←     39 hooks del pipeline de build
│   │   └── ...                   ←     termux_download_*, termux_error_exit, etc.
│   ├── bin/                      ←   Utilidades auxiliares
│   │   ├── build-package-dry-run-simulation.sh
│   │   └── revbump
│   ├── utils/                    ←   Utilidades de entorno
│   │   ├── docker/
│   │   │   └── docker.sh         ←     Helpers para Docker
│   │   └── termux/
│   │       └── package/
│   ├── properties.sh             ←   Metadatos de paquetes (2566 líneas)
│   ├── buildorder.py             ←   Orden de compilación topológico
│   ├── Dockerfile                ←   Imagen Docker para build
│   ├── run-docker.sh             ←   Ejecuta build dentro de Docker
│   ├── setup-android-sdk.sh      ←   Configura Android SDK
│   ├── setup-termux.sh           ←   Configura entorno Termux
│   ├── setup-ubuntu.sh           ←   Configura Ubuntu host
│   ├── lint-packages.sh          ←   Linter de packages/
│   ├── config.guess / config.sub ←   Scripts de autoconf
│   └── ...                       ←   mapas .map.txt, claves GPG, perfiles AppArmor
│
├── ndk-patches/                  ← Parches para Android NDK
│   ├── 29/                       ←   Parches específicos para API 29
│   ├── langinfo.h                ←   Header langinfo.h compatible con NDK
│   └── libintl.h                 ←   Header libintl.h compatible con NDK
│
├── packages/
│   └── termux-sample/
│       └── build.sh              ← Receta del paquete (rsync desde project/)
│
├── project/                      ← ⭐ TU CÓDIGO FUENTE
│   ├── src/
│   │   └── main.c                ← termux-sysinfo (programa de ejemplo en C)
│   ├── Makefile                  ← Build system local (all/install/clean)
│   └── README.md                 ← Documentación del proyecto
│
├── .github/
│   └── workflows/
│       └── build.yml             ← CI con caché incremental
│
├── patches/
│   └── example.patch             ← Parches opcionales (orden alfabético)
│
├── .gitignore
├── CHANGELOG.md
├── LICENSE                       ← MIT
├── VERSION                       ← 1.0.0
└── README.md                     ← Este archivo
```

## Archivo `packages/termux-sample/build.sh`

El script de build sigue el formato de `termux-packages` con una diferencia
clave: en lugar de descargar un tarball desde `TERMUX_PKG_SRCURL`, la función
`termux_step_get_source()` está **overrideada** para copiar la fuente local
desde `./project/` usando `rsync`.

### Variables definidas

| Variable                      | Valor                                            | Descripción                            |
|-------------------------------|--------------------------------------------------|----------------------------------------|
| `TERMUX_PKG_HOMEPAGE`         | `https://github.com/user/termux-sample`          | URL del proyecto                       |
| `TERMUX_PKG_DESCRIPTION`      | `"System info utility for Termux (tracked source)"` | Descripción del paquete             |
| `TERMUX_PKG_LICENSE`          | `MIT`                                            | Identificador SPDX de licencia         |
| `TERMUX_PKG_MAINTAINER`       | `@termux-user`                                   | Mantenedor del paquete                 |
| `TERMUX_PKG_VERSION`          | `1.0.0`                                          | Versión semver                         |
| `TERMUX_PKG_SRCURL`           | *(vacío)*                                        | Sin tarball externo                    |
| `TERMUX_PKG_SHA256`           | *(vacío)*                                        | Sin checksum                           |
| `TERMUX_PKG_DEPENDS`          | `libandroid-support`                             | Dependencias en tiempo de ejecución    |
| `TERMUX_PKG_BUILD_IN_SRC`     | `true`                                           | Compila dentro del source dir          |
| `TERMUX_PKG_SKIP_SRC_EXTRACT` | `true`                                           | No extraer tarball                      |

### Hook override: `termux_step_get_source()`

```bash
termux_step_get_source() {
    mkdir -p "$TERMUX_PKG_SRCDIR"
    rsync -a --delete "$TERMUX_PKG_BUILDER_DIR/project/" "$TERMUX_PKG_SRCDIR/"
    echo "=> Fuente local copiada: $(find "$TERMUX_PKG_SRCDIR" -type f | wc -l) archivos"
}
```

- `-a`: modo archivo (preserva permisos, timestamps, symlinks).
- `--delete`: elimina archivos en destino que ya no existen en origen (útil al
  renombrar o eliminar fuentes).
- `$TERMUX_PKG_BUILDER_DIR` apunta al directorio donde reside `build.sh`
  (dentro del árbol de termux-packages).
- `$TERMUX_PKG_SRCDIR` es el directorio donde espera la fuente el builder.

### Hooks no overrideados

Gracias a `TERMUX_PKG_BUILD_IN_SRC=true`, los hooks estándar de
termux-packages (`termux_step_configure()`, `termux_step_make()`,
`termux_step_make_install()`) funcionan automáticamente. El Makefile en
`project/` provee los targets `all`, `install` y `clean`, y el builder pasa
`DESTDIR` automáticamente vía `$TERMUX_PKG_MASSEDIR`.

## Variables del workflow CI

El archivo `.github/workflows/build.yml` define el pipeline de CI:

| Variable / Config               | Valor                                                   |
|---------------------------------|---------------------------------------------------------|
| **Trigger**                     | Push a `project/**`, `packages/termux-sample/build.sh`, `.github/workflows/build.yml` |
| **Container**                   | `ghcr.io/termux/termux-packages:latest`                 |
| **Comando de build**            | `./build-package.sh -I -a aarch64 termux-sample`        |
| **Arquitectura**                | `aarch64` (configurable)                                |
| **Artefacto**                   | `.deb` subido como artifact (retención: 7 días)         |
| **Concurrencia**                | Grupo por workflow + ref; cancela builds en progreso    |
| **Permisos**                    | `contents: read`                                        |

El flag `-I` en `build-package.sh` indica "instalar dependencias" y `-a aarch64`
define la arquitectura destino.

## Limitaciones de Termux

Al trabajar con este proyecto ten en cuenta las siguientes particularidades del
entorno Termux:

- **No compiles directamente en Termux.** El entorno de Termux no está diseñado
  para compilaciones pesadas. Usa GitHub Actions (CI) o Docker para compilar.
  Compilar en el dispositivo puede agotar la batería, sobrecalentar el equipo
  o llenar el almacenamiento interno.
- **Usa `$TMPDIR`, no `/tmp`.** En Termux el directorio temporal estándar es
  `$TMPDIR` (generalmente `/data/data/com.termux/files/usr/tmp`). No asumas la
  existencia de `/tmp`. El propio `build-package.sh` respeta esta convención.
- **Las rutas no siguen FHS.** Todo el sistema de archivos de Termux reside bajo
  `/data/data/com.termux/files/`. El prefijo del sistema es `$PREFIX`
  (usualmente `/data/data/com.termux/files/usr`). No esperes encontrar
  directorios como `/usr`, `/bin` o `/etc` en ubicaciones estándar.
- **Arquitecturas soportadas.** Termux se ejecuta sobre `aarch64`, `arm`,
  `i686` y `x86_64`. El workflow actual compila para `aarch64`, pero puedes
  ajustar el flag `-a` en `build.yml` para otras arquitecturas.
- **Build con Docker local.** Si necesitas compilar localmente (sin CI), usa
  el contenedor `ghcr.io/termux/termux-packages:latest` con el script
  `scripts/run-docker.sh`.

## Licencia

Distribuido bajo la licencia **MIT**. Consulta el archivo [`LICENSE`](./LICENSE)
para más detalles.
