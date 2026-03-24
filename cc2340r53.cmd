/* symbols provided by /ti/devices/CCFG */
ti_utils_build_GenMap_sym_CRC_CCFG_BOOT_CFG_begin = 0x4e020000;
ti_utils_build_GenMap_sym_CRC_CCFG_BOOT_CFG_end = 0x4e02000b;
ti_utils_build_GenMap_sym_CRC_CCFG_begin = 0x4e020010;
ti_utils_build_GenMap_sym_CRC_CCFG_end = 0x4e02074b;
ti_utils_build_GenMap_sym_CRC_CCFG_DEBUG_begin = 0x4e0207d0;
ti_utils_build_GenMap_sym_CRC_CCFG_DEBUG_end = 0x4e0207fb;

/* definitions provided by /ti/devices/DriverLib */
#define ti_utils_build_GenMap_FLASH0_BASE (0x0)
#define ti_utils_build_GenMap_FLASH0_SIZE (0x80000)

#define ti_utils_build_GenMap_BOOTLOADER_BASE (ti_utils_build_GenMap_FLASH0_BASE)
#define ti_utils_build_GenMap_BOOTLOADER_SIZE (0x08000)

#define ti_utils_build_GenMap_APPLICATION_BASE (ti_utils_build_GenMap_BOOTLOADER_SIZE)
#define ti_utils_build_GenMap_APPLICATION_SIZE (ti_utils_build_GenMap_FLASH0_SIZE - ti_utils_build_GenMap_BOOTLOADER_SIZE)

#define ti_utils_build_GenMap_RAM0_BASE 0x20000000
#define ti_utils_build_GenMap_RAM0_SIZE 0x10000

#define ti_utils_build_GenMap_S2RRAM_BASE 0x40098000
#define ti_utils_build_GenMap_S2RRAM_SIZE 0x1000

#define ti_utils_build_GenMap_CCFG_BASE 0x4e020000
#define ti_utils_build_GenMap_CCFG_SIZE 0x800


--stack_size=2560
--heap_size=0
--entry_point resetISR

/* Retain interrupt vector table variable                                    */
--retain "*(.resetVecs)"

/* Suppress warnings and errors:                                             */
/* - 10063: Warning about entry point not being _c_int00                     */
/* - 16011, 16012: 8-byte alignment errors. Observed when linking in object  */
/*   files compiled using Keil (ARM compiler)                                */
--diag_suppress=10063,16011,16012

/* Set severity of diagnostics to Remark instead of Warning                  */
/* - 10068: Warning about no matching log_ptr* sections                      */
--diag_remark=10068

/* The starting address of the application.  Normally the interrupt vectors  */
/* must be located at the beginning of the application.                      */

#if defined(BOOTLOADER)
#define FLASH_BASE              ti_utils_build_GenMap_BOOTLOADER_BASE
#else
#define FLASH_BASE              ti_utils_build_GenMap_APPLICATION_BASE
#endif

#define BOOTLOADER_BASE         ti_utils_build_GenMap_BOOTLOADER_BASE
#define BOOTLOADER_SIZE         ti_utils_build_GenMap_BOOTLOADER_SIZE

#define APPLICATION_BASE        ti_utils_build_GenMap_APPLICATION_BASE
#define APPLICATION_SIZE        ti_utils_build_GenMap_APPLICATION_SIZE

#define RAM_BASE                ti_utils_build_GenMap_RAM0_BASE
#define RAM_SIZE                ti_utils_build_GenMap_RAM0_SIZE

#define S2RRAM_BASE             ti_utils_build_GenMap_S2RRAM_BASE
#define S2RRAM_SIZE             ti_utils_build_GenMap_S2RRAM_SIZE

#if defined(BOOTLOADER)
#define CCFG_BASE               ti_utils_build_GenMap_CCFG_BASE
#define CCFG_SIZE               ti_utils_build_GenMap_CCFG_SIZE
#else
/* the application should not have a CCFG configured */
#define CCFG_BASE               0
#define CCFG_SIZE               0
#endif

/* System memory map */
MEMORY
{
    BOOTLOADER_FLASH (RWX) : origin = BOOTLOADER_BASE, length = BOOTLOADER_SIZE
    APPLICATION_FLASH (RWX) : origin = APPLICATION_BASE, length = APPLICATION_SIZE

    SRAM (RWX) : origin = RAM_BASE, length = RAM_SIZE

    /* S2RRAM is intended for the S2R radio module, but it can also be used by
     * the application with some limitations. Please refer to the s2rram example. */
    S2RRAM (RW) : origin = S2RRAM_BASE, length = S2RRAM_SIZE

    /* Configuration region */
    CCFG (R) : origin = CCFG_BASE, length = CCFG_SIZE

    /* Explicitly placed off target for the storage of logging data.
     * The ARM memory map allocates 1 GB of external memory from 0x60000000 - 0x9FFFFFFF.
     * Unlikely that all of this will be used, so we are using the upper parts of the region.
     * ARM memory map: https://developer.arm.com/documentation/ddi0337/e/memory-map/about-the-memory-map */
    LOG_DATA (R) : origin = 0x90000000, length = 0x40000        /* 256 KB */
    LOG_PTR  (R) : origin = 0x94000008, length = 0x40000        /* 256 KB */
}

#if defined(BOOTLOADER)
#define FLASH_TEXT BOOTLOADER_FLASH
#else
#define FLASH_TEXT APPLICATION_FLASH
#endif

_second_stage_bootloader_start = BOOTLOADER_BASE;
_second_stage_bootloader_end = BOOTLOADER_BASE + BOOTLOADER_SIZE;

_application_start = APPLICATION_BASE;
_application_end = APPLICATION_BASE + APPLICATION_SIZE;

/* Section allocation in memory */
SECTIONS
{
    .resetVecs      :   > FLASH_BASE
    .text           :   > FLASH_TEXT
    .TI.ramfunc     : {} load=FLASH_TEXT, run=SRAM, table(BINIT)
    .const          :   > FLASH_TEXT
    .constdata      :   > FLASH_TEXT
    .rodata         :   > FLASH_TEXT
    .binit          :   > FLASH_TEXT
    .cinit          :   > FLASH_TEXT
    .pinit          :   > FLASH_TEXT
    .init_array     :   > FLASH_TEXT
    .emb_text       :   > FLASH_TEXT
    .ccfg           :   > CCFG

    .ramVecs        :   > SRAM, type = NOLOAD, ALIGN(256)
    .data           :   > SRAM
    .bss            :   > SRAM
    .sysmem         :   > SRAM
    .stack          :   > SRAM (HIGH)
    .nonretenvar    :   > SRAM

    /* Placing the section .s2rram in S2RRAM region. Only uninitialized
     * objects may be placed in this section. */
    .s2rram         :   > S2RRAM, type = NOINIT

    .log_data       :   > LOG_DATA, type = COPY
    .log_ptr        : { *(.log_ptr*) } > LOG_PTR align 4, type = COPY
}
