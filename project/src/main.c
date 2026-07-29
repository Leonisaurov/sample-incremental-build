/*
 * project/src/main.c — termux-sysinfo: Información del sistema para Termux
 *
 * Muestra detalles del kernel, hardware, y entorno Termux.
 * Compila con:  make
 * Instala con:  make install
 *
 * La versión se define en tiempo de compilación mediante la macro VERSION.
 *
 * Uso:
 *   termux-sysinfo           — Muestra información completa del sistema
 *   termux-sysinfo --help    — Muestra la ayuda
 *   termux-sysinfo --version — Muestra solo la versión
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <unistd.h>

/* ---------------------------------------------------------------------------
 * Constantes del programa
 * --------------------------------------------------------------------------- */
#define PROGRAM_NAME "termux-sysinfo"

/*
 * VERSION debe definirse en tiempo de compilación:
 *   CFLAGS += -DVERSION=\"1.0.0\"
 * Si no está definida, se usa un valor por defecto.
 */
#ifndef VERSION
#define VERSION "0.0.0"
#endif

/* ---------------------------------------------------------------------------
 * Prototipos de funciones internas
 * --------------------------------------------------------------------------- */
static void print_banner(void);
static void print_kernel_info(void);
static void print_hardware_info(void);
static void print_termux_info(void);
static void print_platform_info(void);
static void print_usage(const char *progname);
static long parse_meminfo_value(const char *label);

/* ---------------------------------------------------------------------------
 * main: Punto de entrada
 *
 * Acepta un argumento opcional:
 *   --version  : Muestra solo la versión y sale
 *   --help     : Muestra la ayuda y sale
 *   (sin args) : Muestra la información completa
 *
 * Devuelve 0 en éxito, 1 en error.
 * --------------------------------------------------------------------------- */
int main(int argc, char *argv[])
{
    /* Procesar argumentos de línea de comandos */
    if (argc > 1) {
        if (strcmp(argv[1], "--version") == 0) {
            printf("%s v%s\n", PROGRAM_NAME, VERSION);
            return 0;
        }
        if (strcmp(argv[1], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        }
        /* Argumento desconocido */
        fprintf(stderr, "Error: argumento desconocido '%s'\n", argv[1]);
        print_usage(argv[0]);
        return 1;
    }

    /* Mostrar banner principal */
    print_banner();

    /* Mostrar cada sección de información */
    print_kernel_info();
    print_hardware_info();
    print_termux_info();
    print_platform_info();

    /* Línea final decorativa */
    printf("\n");

    return 0;
}

/* ---------------------------------------------------------------------------
 * print_banner: Muestra el encabezado del programa
 *
 * Incluye el nombre del programa, la versión y una línea decorativa.
 * --------------------------------------------------------------------------- */
static void print_banner(void)
{
    printf("\n");
    printf("  %s v%s\n", PROGRAM_NAME, VERSION);
    printf("  \u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550"
           "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550"
           "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550"
           "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550"
           "\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\n");
    printf("\n");
}

/* ---------------------------------------------------------------------------
 * print_kernel_info: Información del kernel y sistema operativo
 *
 * Usa la llamada al sistema uname(2) para obtener:
 *   - Nombre del SO (sysname)
 *   - Nombre del host (nodename)
 *   - Versión del kernel (release)
 *   - Arquitectura del kernel (machine)
 * --------------------------------------------------------------------------- */
static void print_kernel_info(void)
{
    struct utsname buf;

    if (uname(&buf) != 0) {
        perror("uname");
        return;
    }

    printf("  System:   %s %s %s (%s)\n",
           buf.sysname, buf.nodename, buf.release, buf.machine);
    printf("  Hostname: %s\n", buf.nodename);
}

/* ---------------------------------------------------------------------------
 * print_hardware_info: Información del hardware
 *
 * Usa sysconf(3) para obtener:
 *   - Número de núcleos de CPU (SC_NPROCESSORS_CONF)
 *   - Memoria total del sistema (lectura de /proc/meminfo)
 *
 * En sistemas sin /proc/meminfo, muestra un mensaje de advertencia.
 * --------------------------------------------------------------------------- */
static void print_hardware_info(void)
{
    long nprocs;
    long mem_kb;

    /* Número de CPUs configuradas */
    nprocs = sysconf(_SC_NPROCESSORS_CONF);
    if (nprocs > 0) {
        printf("  CPU Cores: %ld\n", nprocs);
    } else {
        printf("  CPU Cores: desconocido\n");
    }

    /*
     * Memoria total: leemos /proc/meminfo.
     * En Termux esto está disponible gracias a /proc.
     * La línea "MemTotal:" está en kB.
     */
    mem_kb = parse_meminfo_value("MemTotal");
    if (mem_kb > 0) {
        printf("  Total RAM: %ld kB (%.1f MB)\n",
               mem_kb, mem_kb / 1024.0);
    } else {
        printf("  Total RAM: no disponible\n");
    }
}

/* ---------------------------------------------------------------------------
 * parse_meminfo_value: Lee un valor numérico de /proc/meminfo
 *
 * Busca una línea que comience con `label` seguido de ':' y extrae
 * el primer número entero. Por ejemplo, "MemTotal: 6141632 kB" → 6141632.
 *
 * Parámetros:
 *   label — Nombre del campo a buscar (ej. "MemTotal")
 *
 * Devuelve:
 *   El valor numérico, o -1 si no se encuentra o hay error.
 * --------------------------------------------------------------------------- */
static long parse_meminfo_value(const char *label)
{
    FILE *fp;
    char line[256];
    long value = -1;
    size_t label_len;

    fp = fopen("/proc/meminfo", "r");
    if (fp == NULL) {
        return -1;
    }

    label_len = strlen(label);

    while (fgets(line, sizeof(line), fp) != NULL) {
        /* Buscar línea que comience con el label */
        if (strncmp(line, label, label_len) == 0 && line[label_len] == ':') {
            /* Extraer el primer número entero después de ':' */
            const char *p = line + label_len + 1;
            while (*p != '\0' && (*p == ' ' || *p == '\t')) {
                p++;
            }
            if (*p >= '0' && *p <= '9') {
                value = atol(p);
            }
            break;
        }
    }

    fclose(fp);
    return value;
}

/* ---------------------------------------------------------------------------
 * print_termux_info: Información del entorno Termux
 *
 * Usa variables de entorno específicas de Termux:
 *   - PREFIX:         Ruta base de Termux (/data/data/com.termux/files/usr)
 *   - TERMUX_VERSION: Versión de la app Termux (opcional)
 *   - HOME:           Directorio home del usuario
 *
 * La variable TERMUX_VERSION solo está disponible en la app Termux,
 * no en sesiones ADB o emuladores de terminal estándar.
 * --------------------------------------------------------------------------- */
static void print_termux_info(void)
{
    const char *prefix = getenv("PREFIX");
    const char *termux_ver = getenv("TERMUX_VERSION");
    const char *home = getenv("HOME");

    printf("  Termux PREFIX: %s\n",
           prefix ? prefix : "(no disponible — ¿estás en Termux?)");

    /*
     * TERMUX_VERSION solo se define dentro de la app Termux.
     * Si no está, puede que estemos en un entorno alternativo
     * (ADB shell, proot, etc.).
     */
    if (termux_ver) {
        printf("  Termux Version: %s\n", termux_ver);
    }

    if (home) {
        printf("  Home: %s\n", home);
    }
}

/* ---------------------------------------------------------------------------
 * print_platform_info: Información de la plataforma de compilación
 *
 * Usa macros de preprocesador para determinar:
 *   - Si se compiló para Android (__ANDROID__)
 *   - La arquitectura de compilación (__aarch64__, __arm__, etc.)
 * --------------------------------------------------------------------------- */
static void print_platform_info(void)
{
    printf("  Platform: ");

#ifdef __ANDROID__
    printf("Android");
#elif defined(__linux__)
    printf("Linux");
#else
    printf("desconocido");
#endif

    /*
     * Mostrar la arquitectura para la que se compiló el binario.
     * Esto es útil para depurar binarios compilados para arquitectura
     * incorrecta.
     */
    printf(" (");

#if defined(__aarch64__)
    printf("aarch64");
#elif defined(__arm__)
    printf("arm");
#elif defined(__i386__)
    printf("i386");
#elif defined(__x86_64__)
    printf("x86_64");
#else
    printf("unknown");
#endif

    printf(")\n");

    /*
     * Detectar si es un binario compilado para Termux o para el host.
     * En termux-pkg-builder, TERMUX_PREFIX se define durante la compilación.
     */
#ifdef TERMUX_PREFIX
    printf("  Build PREFIX: %s\n", TERMUX_PREFIX);
#endif
}

/* ---------------------------------------------------------------------------
 * print_usage: Muestra el mensaje de uso del programa
 *
 * Parámetros:
 *   progname — Nombre del ejecutable (argv[0])
 * --------------------------------------------------------------------------- */
static void print_usage(const char *progname)
{
    printf("Uso: %s [OPCIÓN]\n", progname);
    printf("\n");
    printf("Muestra información del sistema para Termux.\n");
    printf("\n");
    printf("Opciones:\n");
    printf("  --version  Muestra la versión y sale\n");
    printf("  --help     Muestra esta ayuda y sale\n");
    printf("\n");
    printf("Sin argumentos, muestra la información completa del sistema.\n");
}
