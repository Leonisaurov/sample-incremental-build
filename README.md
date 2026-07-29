# Termux Sample Project

![Termux](https://img.shields.io/badge/Termux-000000?style=flat-square&logo=terminal&label=platform)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=github-actions)

Plantilla base para compilar programas para **Termux** usando el build system oficial [`termux-packages`](https://github.com/termux/termux-packages). Este repositorio proporciona la estructura de directorios, scripts y configuración de CI necesarios para empezar a empaquetar software para Termux de forma rápida y estandarizada.

No compila nada por sí mismo — es únicamente un **scaffold** o **template** que puedes copiar y adaptar para tu propio proyecto.

---

## Estructura del proyecto

```
termux-sample-project/
├── build.sh                          # Script de build (estilo termux-packages)
├── CHANGELOG.md                      # Registro de cambios
├── LICENSE                           # Licencia MIT
├── VERSION                           # Versión actual del paquete
├── .gitignore                        # Exclusiones Git
├── .github/
│   └── workflows/
│       └── build.yml                 # CI con GitHub Actions
├── patches/
│   └── 01-fix-example.patch          # Parche de ejemplo
├── scripts/
│   └── setup-env.sh                  # Helper de configuración de entorno
└── src/
    ├── hello.c                       # Código fuente de ejemplo (hello world)
    └── Makefile                      # Makefile de ejemplo
```

---

## Requisitos previos

| Recurso | Propósito |
|---|---|
| **Docker** | Ejecutar builds locales dentro del entorno controlado de `termux-packages` |
| **GitHub Actions** | Compilación automática en la nube al hacer push al repositorio |
| **Fork de `termux/termux-packages`** (opcional) | Necesario solo si deseas contribuir parches o paquetes oficiales upstream |

---

## Cómo usar este template

### 1. Clonar o copiar como base

```bash
git clone https://github.com/tu-usuario/termux-sample-project.git mi-paquete
cd mi-paquete
```

### 2. Editar `build.sh`

Completa los metadatos del paquete: `TERMUX_PKG_HOMEPAGE`, `TERMUX_PKG_DESCRIPTION`, `TERMUX_PKG_VERSION`, `TERMUX_PKG_SRCURL`, entre otros. Consulta la [sección de variables](#estructura-de-buildsh) más abajo.

### 3. Poner el código fuente en `src/`

Reemplaza los archivos de ejemplo (`hello.c`, `Makefile`) con el código real de tu programa. Ajusta el `Makefile` para que compile correctamente dentro del entorno Termux.

### 4. Configurar el CI

Revisa `.github/workflows/build.yml` y ajusta las arquitecturas objetivo o los triggers si es necesario. Por defecto compila para `aarch64` en cada push a `main`.

### 5. (Opcional) Agregar parches

Si necesitas modificar el código fuente original antes de compilar, coloca los archivos `.patch` en `patches/`. Se aplicarán automáticamente durante el build en orden alfabético.

---

## Build local (con Docker)

El método recomendado para compilar localmente es usar la imagen Docker oficial de `termux-packages`:

```bash
docker run --rm -it \
  -v $PWD:/workspace \
  ghcr.io/termux/termux-packages \
  bash -c "cd /workspace && ./build-package.sh -a aarch64 termux-sample"
```

Explicación de los flags:

| Flag | Significado |
|---|---|
| `--rm` | Elimina el contenedor tras finalizar |
| `-it` | Modo interactivo para ver la salida en terminal |
| `-v $PWD:/workspace` | Monta el directorio actual dentro del contenedor |
| `-a aarch64` | Arquitectura destino (`aarch64`, `arm`, `i686`, `x86_64`) |
| `termux-sample` | Nombre del paquete (debe coincidir con `TERMUX_PKG_NAME` en `build.sh`) |

El binario compilado se generará dentro del contenedor en `/workspace/debs/` con extensión `.deb`.

---

## Build con GitHub Actions

El flujo de trabajo incluido en `.github/workflows/build.yml` se activa automáticamente en cada push a la rama `main` (o `master`). También puedes ejecutarlo manualmente desde la pestaña **Actions** de tu repositorio en GitHub.

**¿Qué hace?**

1. Clona el repositorio y el branch `packages` de `termux/termux-packages`.
2. Copia los archivos del paquete al árbol de `termux-packages`.
3. Ejecuta `build-package.sh` para las arquitecturas configuradas.
4. Sube los paquetes `.deb` generados como artefactos descargables.

Para activarlo, solo haz push al repositorio:

```bash
git add .
git commit -m "feat: inicializar paquete"
git push origin main
```

El resultado de la compilación estará disponible en **Actions > workflow > Summary > Artifacts**.

---

## Estructura de `build.sh`

Las variables siguientes son las más importantes y deben definirse en el script `build.sh`:

| Variable | Obligatoria | Descripción |
|---|---|---|
| `TERMUX_PKG_HOMEPAGE` | Sí | URL del sitio web del proyecto |
| `TERMUX_PKG_DESCRIPTION` | Sí | Descripción breve del paquete |
| `TERMUX_PKG_LICENSE` | Sí | Licencia del software (ej. `MIT`, `GPL-2.0`) |
| `TERMUX_PKG_VERSION` | Sí | Versión del paquete |
| `TERMUX_PKG_SRCURL` | Sí | URL de descarga del código fuente (tarball, git, etc.) |
| `TERMUX_PKG_SHA256` | Sí | Checksum SHA-256 del tarball de origen |
| `TERMUX_PKG_MAINTAINER` | No | Nombre y correo del mantenedor |
| `TERMUX_PKG_DEPENDS` | No | Dependencias de tiempo de ejecución |
| `TERMUX_PKG_BUILD_DEPENDS` | No | Dependencias solo de compilación |
| `TERMUX_PKG_AUTO_UPDATE` | No | Si se debe actualizar automáticamente (`true`/`false`) |

Ejemplo mínimo de `build.sh`:

```bash
TERMUX_PKG_HOMEPAGE=https://example.com
TERMUX_PKG_DESCRIPTION="A sample Termux package"
TERMUX_PKG_LICENSE=MIT
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_SRCURL=https://example.com/source-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=abc123...
TERMUX_PKG_MAINTAINER="Your Name <your@email.com>"
TERMUX_PKG_DEPENDS="glibc"
```

---

## Limitaciones de Termux

Al trabajar con Termux ten en cuenta lo siguiente:

- **No compiles directamente en Termux.** El entorno de Termux no está diseñado para compilaciones pesadas. Usa siempre Docker (build local) o GitHub Actions (CI) para compilar. Compilar en el dispositivo puede agotar la batería, sobrecalentar el equipo o llenar el almacenamiento interno.
- **Usa `$TMPDIR`, no `/tmp`.** En Termux el directorio temporal estándar es `$TMPDIR` (generalmente `/data/data/com.termux/files/usr/tmp`). No asumas la existencia de `/tmp`.
- **Las rutas no siguen FHS.** Todo el sistema de archivos de Termux reside bajo `/data/data/com.termux/files/`. El prefijo del sistema es `$PREFIX` (usualmente `/data/data/com.termux/files/usr`). No esperes encontrar directorios como `/usr`, `/bin` o `/etc` en ubicaciones estándar.
- **Arquitecturas soportadas.** Termux se ejecuta sobre `aarch64`, `arm`, `i686` y `x86_64`. Asegúrate de compilar para la arquitectura correcta según el dispositivo destino.

---

## Licencia

Distribuido bajo la licencia **MIT**. Consulta el archivo [`LICENSE`](./LICENSE) para más detalles.
