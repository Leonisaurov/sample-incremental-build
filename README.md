# Termux Sample Project

![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=terminal)
![MIT](https://img.shields.io/badge/license-MIT-blue)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF)

## Descripción

Template para compilar programas para Termux con build incremental y CI
automático. El código fuente se edita en el directorio `project/` y al hacer
commit se dispara el build en GitHub Actions. La caché incremental acelera
builds subsecuentes al reutilizar el estado de compilación anterior.

Este repositorio no es un scaffold genérico — es un flujo de trabajo real
donde el código trackeado vive junto con la configuración de empaquetado.

## Flujo de trabajo

```
Tú editas → ./project/src/main.c
       │
       ▼
  git add project/ + git commit + git push
       │
       ▼
  GitHub Actions (workflow/build.yml)
       │
       ├── 1. Restaura caché (~/.termux-build/)  ← Incremental!
       ├── 2. Ejecuta build-package.sh -a aarch64
       ├── 3. Guarda .deb como artifact
       └── 4. Actualiza caché para próxima vez  ♻️
```

## Requisitos

| Recurso | Propósito |
|---------|-----------|
| **GitHub repo** | Alojar el código y ejecutar GitHub Actions |
| **GitHub Actions habilitado** | Compilación automática en cada push |
| **Docker** (opcional) | Build local con termux-packages |

## Cómo usar

### 1. Editar código

Realiza los cambios en los archivos dentro de `project/`. Todo el código
fuente, el Makefile y los recursos del programa residen ahí.

```bash
# Edita los archivos en project/
vim project/src/main.c
```

El archivo `project/src/main.c` es un programa de ejemplo (`termux-sysinfo`).
Puedes modificarlo o reemplazarlo por completo.

### 2. Compilar localmente (prueba rápida)

Para probar que el código compila sin errores antes de hacer commit, usa el
Makefile local dentro de `project/`:

```bash
cd project && make && ./termux-sysinfo
```

> **Nota**: Esta compilación es nativa y no produce un paquete `.deb`. Sirve
> únicamente para validación rápida en Termux o Linux.

### 3. Commit y push (dispara CI automático)

Hay dos formas de subir cambios:

#### Opción A: Helper script (recomendada)

```bash
bash scripts/push-and-build.sh "mi mensaje de commit"
```

El script:
- Agrega `project/` al stage de git.
- Crea un commit con el mensaje dado (prefijado con `update(project):`).
- Hace push al remote `origin`.
- Muestra la URL del workflow en GitHub Actions.

Si no hay cambios en `project/`, el script lo notifica y no hace commit.

#### Opción B: Manual

```bash
git add project/
git commit -m "update(project): mi cambio"
git push
```

El CI se activa automáticamente porque el workflow `build.yml` escucha cambios
en `project/**`, `build.sh` y `.github/workflows/build.yml`.

## Caché incremental

El workflow de GitHub Actions utiliza `actions/cache@v4` para acelerar builds
consecutivos. Así funciona:

| Concepto | Detalle |
|----------|---------|
| **Cache key** | `termux-build-${{ hashFiles('project/**', 'build.sh') }}` |
| **Restore keys** | `termux-build-` (busca cualquier caché previa) |
| **Ruta cacheadas** | `/home/builder/.termux-build` |
| **Cuándo se guarda** | Al finalizar el job, si la key no existía |

**Efecto práctico**: si cambias un solo archivo fuente, solo se recompila lo
necesario. El directorio `~/.termux-build` contiene los objetos compilados,
dependencias descargadas y el estado del builder de termux-packages. Los
builds siguientes (incluso en ramas diferentes) suelen completarse en una
fracción del tiempo del primero.

## Estructura de directorios

```
Sample/
├── project/                         ← TU CÓDIGO FUENTE (editas aquí)
│   ├── src/
│   │   └── main.c                   ← Programa termux-sysinfo en C
│   ├── Makefile                     ← Build system local
│   └── README.md                    ← Docs del proyecto
├── build.sh                         ← Build script termux-packages (override)
├── .github/
│   └── workflows/
│       └── build.yml                ← CI con caché incremental
├── scripts/
│   ├── setup-env.sh                 ← Helper de configuración de entorno
│   └── push-and-build.sh            ← Helper commit+push (ejecutable)
├── patches/                         ← Parches opcionales (orden alfabético)
├── .gitignore
├── .git/
├── CHANGELOG.md
├── LICENSE (MIT)
├── README.md                        ← Este archivo
└── VERSION
```

## Archivo `build.sh`

El script `build.sh` sigue el formato de `termux-packages` con una diferencia
clave: en lugar de descargar un tarball desde `TERMUX_PKG_SRCURL`, la función
`termux_step_get_source()` está **overrideada** para copiar la fuente local
desde `./project/` usando `rsync`.

### Variables definidas

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `TERMUX_PKG_HOMEPAGE` | `https://github.com/user/termux-sample` | URL del proyecto |
| `TERMUX_PKG_DESCRIPTION` | `"System info utility for Termux (tracked source)"` | Descripción del paquete |
| `TERMUX_PKG_LICENSE` | `MIT` | Licencia SPDX |
| `TERMUX_PKG_MAINTAINER` | `@termux-user` | Mantenedor |
| `TERMUX_PKG_VERSION` | `1.0.0` | Versión semver |
| `TERMUX_PKG_SRCURL` | *(vacío)* | Sin tarball externo |
| `TERMUX_PKG_SHA256` | *(vacío)* | Sin checksum |
| `TERMUX_PKG_DEPENDS` | `libandroid-support` | Dependencias runtime |
| `TERMUX_PKG_BUILD_IN_SRC` | `true` | Compila dentro del source dir |
| `TERMUX_PKG_SKIP_SRC_EXTRACT` | `true` | No extraer tarball |

### Hook override: `termux_step_get_source()`

```
rsync -a --delete "$TERMUX_PKG_BUILDER_DIR/project/" "$TERMUX_PKG_SRCDIR/"
```

- `-a`: modo archivo (preserva permisos, timestamps, symlinks).
- `--delete`: elimina archivos en destino que ya no existen en origen (útil al
  renombrar o eliminar fuentes).
- El contenido de `project/` se copia al directorio de compilación cada vez
  que se ejecuta el build.

## Limitaciones de Termux

Al trabajar con este proyecto ten en cuenta las siguientes particularidades del
entorno Termux:

- **No compiles directamente en Termux.** El entorno de Termux no está diseñado
  para compilaciones pesadas. Usa GitHub Actions (CI) o Docker para compilar.
  Compilar en el dispositivo puede agotar la batería, sobrecalentar el equipo
  o llenar el almacenamiento interno.
- **Usa `$TMPDIR`, no `/tmp`.** En Termux el directorio temporal estándar es
  `$TMPDIR` (generalmente `/data/data/com.termux/files/usr/tmp`). No asumas la
  existencia de `/tmp`.
- **Las rutas no siguen FHS.** Todo el sistema de archivos de Termux reside bajo
  `/data/data/com.termux/files/`. El prefijo del sistema es `$PREFIX`
  (usualmente `/data/data/com.termux/files/usr`). No esperes encontrar
  directorios como `/usr`, `/bin` o `/etc` en ubicaciones estándar.
- **Arquitecturas soportadas.** Termux se ejecuta sobre `aarch64`, `arm`,
  `i686` y `x86_64`. Asegúrate de compilar para la arquitectura correcta según
  el dispositivo destino.

## Licencia

Distribuido bajo la licencia **MIT**. Consulta el archivo [`LICENSE`](./LICENSE)
para más detalles.
