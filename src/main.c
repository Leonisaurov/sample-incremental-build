/*
 * src/main.c — Hello World example for Termux
 *
 * This is a minimal C program that demonstrates:
 *   - Printing the program version (from TERMUX_PKG_VERSION)
 *   - Greeting the user
 *   - Displaying the Termux prefix ($PREFIX)
 *
 * Compile with:  make
 * Install with:  make install
 *
 * The binary is installed as 'termux-sample' in $PREFIX/bin/.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---------------------------------------------------------------------------
 * Version string — should match TERMUX_PKG_VERSION in build.sh
 * --------------------------------------------------------------------------- */
#define PROGRAM_NAME    "termux-sample"
#define PROGRAM_VERSION "1.0.0"

/* ---------------------------------------------------------------------------
 * Main entry point
 *
 * Returns 0 on success, 1 on error.
 * --------------------------------------------------------------------------- */
int main(void)
{
    /* Retrieve the Termux prefix from the environment.
     * In Termux this is typically /data/data/com.termux/files/usr.
     * The PREFIX environment variable is always set in Termux sessions. */
    const char *prefix = getenv("PREFIX");
    if (prefix == NULL) {
        /* Fallback if PREFIX is not set (e.g., running outside Termux) */
        prefix = "/data/data/com.termux/files/usr";
    }

    /* Print a greeting with program name and version */
    printf("========================================\n");
    printf("  %s v%s\n", PROGRAM_NAME, PROGRAM_VERSION);
    printf("  Hello from Termux!\n");
    printf("========================================\n");
    printf("\n");

    /* Show the Termux prefix path */
    printf("  Termux PREFIX : %s\n", prefix);
    printf("  Architecture  : ");

    /* Detect and display the build architecture at runtime */
#if defined(__aarch64__)
    printf("aarch64 (64-bit ARM)\n");
#elif defined(__ARM_ARCH_ISA_A32)
    printf("arm (32-bit ARM)\n");
#elif defined(__i386__)
    printf("i686 (x86)\n");
#elif defined(__x86_64__)
    printf("x86_64 (64-bit x86)\n");
#else
    printf("unknown\n");
#endif

    printf("\n");
    printf("  Your Termux environment is ready!\n");
    printf("========================================\n");

    return 0;
}
