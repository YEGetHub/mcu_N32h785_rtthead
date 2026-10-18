/*
 * N32H7xx XIP-to-TCM SoC startup support
 *
 * This file contains the boot-stage code that still runs from FLASH:
 *   - early cache/system initialization
 *   - runtime image relocation to ITCM/DTCM/AHB_SRAM
 *   - VTOR/MSP switch before entering main()
 */

#include <stdint.h>

#include "n32h7xx.h"

/* ---- Section attributes ---- */
#define BOOT_CODE   __attribute__((used, section(".boot_text")))

/* ---- Linker-script symbols ---- */
extern uint32_t __image_copy_load_start__;
extern uint32_t __image_copy_start__;
extern uint32_t __image_copy_end__;

extern uint32_t __tcm_vector_start__;
extern uint32_t __tcm_vector_end__;

extern uint32_t __itcm_text_load_start__;
extern uint32_t __itcm_text_start__;
extern uint32_t __itcm_text_end__;

extern uint32_t _sidata;
extern uint32_t _sdata;
extern uint32_t _edata;

extern uint32_t _sbss;
extern uint32_t _ebss;

extern uint32_t _app_estack;

/* SystemInit() is declared by the device headers. */
extern int entry(void);

/* ======================================================================
 * Boot-stage helpers -- copied nowhere, run directly from FLASH
 * ====================================================================== */

BOOT_CODE static void boot_copy_words(volatile uint32_t *dst, volatile const uint32_t *src, volatile uint32_t *end)
{
    while (dst < end)
    {
        *dst++ = *src++;
    }
}

BOOT_CODE static void boot_zero_words(volatile uint32_t *start, volatile uint32_t *end)
{
    while (start < end)
    {
        *start++ = 0U;
    }
}

BOOT_CODE static void relocate_runtime_image(void)
{
    volatile uint32_t *src = &__image_copy_load_start__;
    volatile uint32_t *dst = &__image_copy_start__;
    uint32_t *end = &__image_copy_end__;

    if (dst != src)
    {
        boot_copy_words(dst, src, end);
    }
    dst[15] = src[250];
}

/* ======================================================================
 * lowlevel_init -- called from reset (startup.S)
 * ====================================================================== */

BOOT_CODE static void cache_init(void)
{
    /* Invalidate before enabling to avoid stale cache state. */
    // SCB_InvalidateICache();
    // SCB_InvalidateDCache();
    // SCB_EnableICache();
    // SCB_EnableDCache();
}

BOOT_CODE void lowlevel_init(void)
{
    /* Interrupts are already disabled by reset in startup.S. */
    SystemInit();

    /* Keep boot running on default clock. */
    cache_init();
}

/* ======================================================================
 * _main -- relocate runtime image, switch execution context, jump to app
 *
 *   - copy one contiguous runtime image into its execution address
 *   - initialize runtime data sections that live outside the image
 *   - switch VTOR/MSP and branch into the relocated program
 * ====================================================================== */

BOOT_CODE void _main(void)
{
    /* Relocate one contiguous ITCM runtime image. */
    relocate_runtime_image();

    /* Copy data from the .data section of XIP NOR Flash to RAM. */
    boot_copy_words(&_sdata, &_sidata, &_edata);

    /* Set the .bss section to zero. */
    boot_zero_words(&_sbss, &_ebss);

    /* Switch exception entry to the relocated runtime vector table. */
    SCB->VTOR = (uint32_t)(uintptr_t)&__tcm_vector_start__;
    __DSB();
    __ISB();

    /* Switch to the application runtime stack from the startup vector table. */
    __set_MSP((uint32_t)(uintptr_t)&_app_estack);
    __DSB();
    __ISB();

    /* Runtime image now lives in ITCM/DTCM, so VTOR/MSP switch only needs
     * DSB/ISB ordering here; no extra D-cache clean is required. */
    __enable_fault_irq();   /* cpsie f -- clear FAULTMASK (defensive) */
    __enable_irq();         /* cpsie i -- clear PRIMASK               */
    __asm volatile("bx %0" :: "r"(entry));

    while (1) {}
}
