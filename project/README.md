# termux-sysinfo

Programa de ejemplo para Termux que muestra información del sistema:
kernel, hardware, variables de entorno de Termux y plataforma.

## Compilación local

```bash
make
make install PREFIX=$PREFIX
termux-sysinfo
```

## Uso en CI (GitHub Actions)

El directorio `project/` contiene la fuente trackeada.
El `build.sh` en la raíz copia este directorio al entorno de
compilación de `termux-pkg-builder` usando `rsync`, sin descargar
ningún tarball externo. Esto permite compilar con caché incremental.

## Limpiar

```bash
make clean
```
