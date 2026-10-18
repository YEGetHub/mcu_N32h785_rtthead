; *********************************************************************************************************
;     N32H7xx Startup for GCC-style boot flow (Keil/ARMCC)
;
;     Modified from Nations' original startup to use our own __main instead of
;     Keil's library __main.
;
;     Boot flow:
;       Reset_Handler -> lowlevel_init -> __main -> main()
;
;     lowlevel_init: calls SystemInit(), cache init          (C, in soc.c)
;     __main:        ITCM copy, .data init, .bss zero,       (C, in soc.c)
;                    VTOR/MSP switch, jump to main()
; ************************************************************************************************************

; Amount of memory (in bytes) allocated for Stack
; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00002000

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp

; Heap is managed by the scatter file (RW_AXI_SRAM), not here
Heap_Size       EQU     0

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit

                PRESERVE8
                THUMB

; Minimal reset vector table placed at FLASH base by scatter file.
; The full runtime vector table is in tcm_vector and is selected by VTOR.
; after soc.c relocates RW_ITCM.
                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

__Vectors       DCD     __initial_sp                      ; Top of Stack
                DCD     Reset_Handler                     ; Reset Handler
                DCD     NMI_Handler                       ; NMI Handler
__Vectors_End
__Vectors_Size  EQU  __Vectors_End - __Vectors

; ====================================================================
; Reset handler — calls our own lowlevel_init and __main (in soc.c)
; instead of Keil's library __main
; ====================================================================
                AREA    |.text|, CODE, READONLY

Reset_Handler   PROC
                EXPORT  Reset_Handler                   [WEAK]
                IMPORT  lowlevel_init
                IMPORT  __main
                CPSID   I       ; Disable maskable IRQs during early boot
                CPSID   F       ; Disable fault exceptions until VTOR is switched
                LDR     R0, =lowlevel_init
                BLX     R0
                LDR     R0, =__main
                BX      R0
                ENDP

;*******************************************************************************
; Stack and Heap initialization
;*******************************************************************************
                 IF      :DEF:__MICROLIB

                 EXPORT  __initial_sp
                 EXPORT  __heap_base
                 EXPORT  __heap_limit

                 ELSE

                 IMPORT  __use_two_region_memory
                 EXPORT  __user_initial_stackheap

__user_initial_stackheap

                 LDR     R0, =  Heap_Mem
                 LDR     R1, =(Stack_Mem + Stack_Size)
                 LDR     R2, = (Heap_Mem +  Heap_Size)
                 LDR     R3, = Stack_Mem
                 BX      LR

                 ALIGN

                 ENDIF

;*******************************************************************************
; Runtime Vector Table — placed in ITCM at 0x00000000 by scatter file
; Used after __main switches VTOR. Copied from FLASH to ITCM by __main.
;*******************************************************************************
                PRESERVE8
                AREA    tcm_vector, DATA, READONLY
                IMPORT  main
                ALIGN   2
                GLOBAL  g_pfnVectors_runtime

g_pfnVectors_runtime
                DCD     __initial_sp                     ; Top of Stack (from Stack_Size)
                DCD     main                             ; Reset Handler
                DCD     NMI_Handler
                DCD     HardFault_Handler
                DCD     MemManage_Handler
                DCD     BusFault_Handler
                DCD     UsageFault_Handler
                DCD     0                                ; Reserved
                DCD     0                                ; Reserved
                DCD     0                                ; Reserved
                DCD     0                                ; Reserved
                DCD     SVC_Handler
                DCD     DebugMon_Handler
                DCD     0                                ; Reserved
                DCD     PendSV_Handler
                DCD     N32SysTick_Handler

                ; External Interrupts
                DCD     WWDG1_IRQHandler
                DCD     PVD_IRQHandler
                DCD     RTC_TAMPER_IRQHandler
                DCD     RTC_WKUP_IRQHandler
                DCD     RCC_IRQHandler
                DCD     EXTI0_IRQHandler
                DCD     EXTI1_IRQHandler
                DCD     EXTI2_IRQHandler
                DCD     EXTI3_IRQHandler
                DCD     EXTI4_IRQHandler
                DCD     EXTI9_5_IRQHandler
                DCD     EXTI15_10_IRQHandler
                DCD     DMA1_Channel0_IRQHandler
                DCD     DMA1_Channel1_IRQHandler
                DCD     DMA1_Channel2_IRQHandler
                DCD     DMA1_Channel3_IRQHandler
                DCD     DMA1_Channel4_IRQHandler
                DCD     DMA1_Channel5_IRQHandler
                DCD     DMA1_Channel6_IRQHandler
                DCD     DMA1_Channel7_IRQHandler
                DCD     DMA2_Channel0_IRQHandler
                DCD     DMA2_Channel1_IRQHandler
                DCD     DMA2_Channel2_IRQHandler
                DCD     DMA2_Channel3_IRQHandler
                DCD     DMA2_Channel4_IRQHandler
                DCD     DMA2_Channel5_IRQHandler
                DCD     DMA2_Channel6_IRQHandler
                DCD     DMA2_Channel7_IRQHandler
                DCD     DMA3_Channel0_IRQHandler
                DCD     DMA3_Channel1_IRQHandler
                DCD     DMA3_Channel2_IRQHandler
                DCD     DMA3_Channel3_IRQHandler
                DCD     DMA3_Channel4_IRQHandler
                DCD     DMA3_Channel5_IRQHandler
                DCD     DMA3_Channel6_IRQHandler
                DCD     DMA3_Channel7_IRQHandler
                DCD     MDMA_Channel0_IRQHandler
                DCD     MDMA_Channel1_IRQHandler
                DCD     MDMA_Channel2_IRQHandler
                DCD     MDMA_Channel3_IRQHandler
                DCD     MDMA_Channel4_IRQHandler
                DCD     MDMA_Channel5_IRQHandler
                DCD     MDMA_Channel6_IRQHandler
                DCD     MDMA_Channel7_IRQHandler
                DCD     MDMA_Channel8_IRQHandler
                DCD     MDMA_Channel9_IRQHandler
                DCD     MDMA_Channel10_IRQHandler
                DCD     MDMA_Channel11_IRQHandler
                DCD     MDMA_Channel12_IRQHandler
                DCD     MDMA_Channel13_IRQHandler
                DCD     MDMA_Channel14_IRQHandler
                DCD     MDMA_Channel15_IRQHandler
                DCD     SDPU_IRQHandler
                DCD     0                                ; Reserved
                DCD     0                                ; Reserved
                DCD     FPU_CPU1_IRQHandler
                DCD     ECCMON_IRQHandler
                DCD     RTC_ALARM_IRQHandler
                DCD     I2C1_EV_IRQHandler
                DCD     I2C1_ER_IRQHandler
                DCD     I2C2_EV_IRQHandler
                DCD     I2C2_ER_IRQHandler
                DCD     I2C3_EV_IRQHandler
                DCD     I2C3_ER_IRQHandler
                DCD     I2C4_EV_IRQHandler
                DCD     I2C4_ER_IRQHandler
                DCD     I2C5_EV_IRQHandler
                DCD     I2C5_ER_IRQHandler
                DCD     I2C6_EV_IRQHandler
                DCD     I2C6_ER_IRQHandler
                DCD     I2C7_EV_IRQHandler
                DCD     I2C7_ER_IRQHandler
                DCD     I2C8_EV_IRQHandler
                DCD     I2C8_ER_IRQHandler
                DCD     I2C9_EV_IRQHandler
                DCD     I2C9_ER_IRQHandler
                DCD     I2C10_EV_IRQHandler
                DCD     I2C10_ER_IRQHandler
                DCD     I2S1_IRQHandler
                DCD     I2S2_IRQHandler
                DCD     I2S3_IRQHandler
                DCD     I2S4_IRQHandler
                DCD     0                                ; Reserved
                DCD     xSPI2_IRQHandler
                DCD     SPI1_IRQHandler
                DCD     SPI2_IRQHandler
                DCD     SPI3_IRQHandler
                DCD     SPI4_IRQHandler
                DCD     SPI5_IRQHandler
                DCD     SPI6_IRQHandler
                DCD     SPI7_IRQHandler
                DCD     LCD_EV_IRQHandler
                DCD     LCD_ER_IRQHandler
                DCD     DVP1_IRQHandler
                DCD     DVP2_IRQHandler
                DCD     DMAMUX2_IRQHandler
                DCD     USB1_HS_EPx_OUT_IRQHandler
                DCD     USB1_HS_EPx_IN_IRQHandler
                DCD     USB1_HS_WKUP_IRQHandler
                DCD     USB1_HS_IRQHandler
                DCD     USB2_HS_EPx_OUT_IRQHandler
                DCD     USB2_HS_EPx_IN_IRQHandler
                DCD     USB2_HS_WKUP_IRQHandler
                DCD     USB2_HS_IRQHandler
                DCD     ETH1_IRQHandler
                DCD     ETH1_PMT_LPI_IRQHandler
                DCD     ETH2_IRQHandler
                DCD     ETH2_PMT_LPI_IRQHandler
                DCD     FDCAN1_INT0_IRQHandler
                DCD     FDCAN2_INT0_IRQHandler
                DCD     FDCAN3_INT0_IRQHandler
                DCD     FDCAN4_INT0_IRQHandler
                DCD     FDCAN1_INT1_IRQHandler
                DCD     FDCAN2_INT1_IRQHandler
                DCD     FDCAN3_INT1_IRQHandler
                DCD     FDCAN4_INT1_IRQHandler
                DCD     USART1_IRQHandler
                DCD     USART2_IRQHandler
                DCD     USART3_IRQHandler
                DCD     USART4_IRQHandler
                DCD     USART5_IRQHandler
                DCD     USART6_IRQHandler
                DCD     USART7_IRQHandler
                DCD     USART8_IRQHandler
                DCD     UART9_IRQHandler
                DCD     UART10_IRQHandler
                DCD     UART11_IRQHandler
                DCD     UART12_IRQHandler
                DCD     UART13_IRQHandler
                DCD     UART14_IRQHandler
                DCD     UART15_IRQHandler
                DCD     LPUART1_IRQHandler
                DCD     LPUART2_IRQHandler
                DCD     GPU_IRQHandler
                DCD     0                                ; Reserved
                DCD     SDMMC1_IRQHandler
                DCD     SDMMC2_IRQHandler
                DCD     ADC1_IRQHandler
                DCD     ADC2_IRQHandler
                DCD     ADC3_IRQHandler
                DCD     COMP1_2_IRQHandler
                DCD     COMP3_4_IRQHandler
                DCD     SHRTIM1_INT1_IRQHandler
                DCD     SHRTIM1_INT2_IRQHandler
                DCD     SHRTIM1_INT3_IRQHandler
                DCD     SHRTIM1_INT4_IRQHandler
                DCD     SHRTIM1_INT5_IRQHandler
                DCD     SHRTIM1_INT6_IRQHandler
                DCD     SHRTIM1_INT7_IRQHandler
                DCD     SHRTIM1_INT8_IRQHandler
                DCD     SHRTIM2_INT1_IRQHandler
                DCD     SHRTIM2_INT2_IRQHandler
                DCD     SHRTIM2_INT3_IRQHandler
                DCD     SHRTIM2_INT4_IRQHandler
                DCD     SHRTIM2_INT5_IRQHandler
                DCD     SHRTIM2_INT6_IRQHandler
                DCD     SHRTIM2_INT7_IRQHandler
                DCD     SHRTIM2_INT8_IRQHandler
                DCD     FDCAN5_INT0_IRQHandler
                DCD     FDCAN6_INT0_IRQHandler
                DCD     FDCAN7_INT0_IRQHandler
                DCD     FDCAN8_INT0_IRQHandler
                DCD     FDCAN5_INT1_IRQHandler
                DCD     FDCAN6_INT1_IRQHandler
                DCD     FDCAN7_INT1_IRQHandler
                DCD     FDCAN8_INT1_IRQHandler
                DCD     0                                ; Reserved
                DCD     0                                ; Reserved
                DCD     LPTIM5_WKUP_IRQHandler
                DCD     JPEG_SGDMA_H2P_IRQHandler
                DCD     JPEG_SGDMA_P2H_IRQHandler
                DCD     WAKEUP_IO_IRQHandler
                DCD     SEMA4_INT1_IRQHandler
                DCD     0                                ; Reserved
                DCD     WWDG2_RST_IRQHandler
                DCD     OTPC_IRQHandler
                DCD     FEMC_IRQHandler
                DCD     DCMUB_IRQHandler
                DCD     DAC1_IRQHandler
                DCD     DAC2_IRQHandler
                DCD     MDMA_AHBS_ER_IRQHandler
                DCD     CM7_CATCH_READ_ER_IRQHandler
                DCD     DAC3_IRQHandler
                DCD     DAC4_IRQHandler
                DCD     EMC_IRQHandler
                DCD     DAC5_IRQHandler
                DCD     DAC6_IRQHandler
                DCD     ESC_OPB_IRQHandler
                DCD     ESC_SYNC0_IRQHandler
                DCD     ESC_SYNC1_IRQHandler
                DCD     ESC_WRP_IRQHandler
                DCD     0                                ; Reserved
                DCD     ATIM1_BRK_IRQHandler
                DCD     ATIM1_TRG_COM_IRQHandler
                DCD     ATIM1_CC_IRQHandler
                DCD     ATIM1_UP_IRQHandler
                DCD     ATIM2_BRK_IRQHandler
                DCD     ATIM2_TRG_COM_IRQHandler
                DCD     ATIM2_CC_IRQHandler
                DCD     ATIM2_UP_IRQHandler
                DCD     ATIM3_BRK_IRQHandler
                DCD     ATIM3_TRG_COM_IRQHandler
                DCD     ATIM3_CC_IRQHandler
                DCD     ATIM3_UP_IRQHandler
                DCD     ATIM4_BRK_IRQHandler
                DCD     ATIM4_TRG_COM_IRQHandler
                DCD     ATIM4_CC_IRQHandler
                DCD     ATIM4_UP_IRQHandler
                DCD     GTIMA1_IRQHandler
                DCD     GTIMA2_IRQHandler
                DCD     GTIMA3_IRQHandler
                DCD     GTIMA4_IRQHandler
                DCD     GTIMA5_IRQHandler
                DCD     GTIMA6_IRQHandler
                DCD     GTIMA7_IRQHandler
                DCD     GTIMB1_IRQHandler
                DCD     GTIMB2_IRQHandler
                DCD     GTIMB3_IRQHandler
                DCD     BTIM1_IRQHandler
                DCD     BTIM2_IRQHandler
                DCD     BTIM3_IRQHandler
                DCD     BTIM4_IRQHandler
                DCD     LPTIM1_WKUP_IRQHandler
                DCD     LPTIM2_WKUP_IRQHandler
                DCD     LPTIM3_WKUP_IRQHandler
                DCD     LPTIM4_WKUP_IRQHandler
                DCD     DSMU_FLT0_IRQHandler
                DCD     DSMU_FLT1_IRQHandler
                DCD     DSMU_FLT2_IRQHandler
                DCD     DSMU_FLT3_IRQHandler
                DCD     FMAC_IRQHandler
                DCD     CORDIC_IRQHandler
                DCD     DMAMUX1_IRQHandler
                DCD     MMU_IRQHandler
                DCD     SysTick_Handler

;*******************************************************************************
; Default core exception handlers referenced by RESET and tcm_vector
;*******************************************************************************
                AREA    |.text|, CODE, READONLY

NMI_Handler     PROC
                EXPORT  NMI_Handler                     [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler               [WEAK]
                B       .
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler               [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler                [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler              [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler                     [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler                [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler                  [WEAK]
                B       .
                ENDP
N32SysTick_Handler PROC
                EXPORT  N32SysTick_Handler              [WEAK]
                B       .
                ENDP

;*******************************************************************************
; Default external interrupt handlers referenced by tcm_vector
;*******************************************************************************
                AREA    |.text|, CODE, READONLY

Default_Handler PROC

                EXPORT  WWDG1_IRQHandler                [WEAK]
                EXPORT  PVD_IRQHandler                  [WEAK]
                EXPORT  RTC_TAMPER_IRQHandler           [WEAK]
                EXPORT  RTC_WKUP_IRQHandler             [WEAK]
                EXPORT  RCC_IRQHandler                  [WEAK]
                EXPORT  EXTI0_IRQHandler                [WEAK]
                EXPORT  EXTI1_IRQHandler                [WEAK]
                EXPORT  EXTI2_IRQHandler                [WEAK]
                EXPORT  EXTI3_IRQHandler                [WEAK]
                EXPORT  EXTI4_IRQHandler                [WEAK]
                EXPORT  EXTI9_5_IRQHandler              [WEAK]
                EXPORT  EXTI15_10_IRQHandler            [WEAK]
                EXPORT  DMA1_Channel0_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel1_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel2_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel3_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel4_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel5_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel6_IRQHandler        [WEAK]
                EXPORT  DMA1_Channel7_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel0_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel1_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel2_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel3_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel4_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel5_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel6_IRQHandler        [WEAK]
                EXPORT  DMA2_Channel7_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel0_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel1_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel2_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel3_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel4_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel5_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel6_IRQHandler        [WEAK]
                EXPORT  DMA3_Channel7_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel0_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel1_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel2_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel3_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel4_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel5_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel6_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel7_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel8_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel9_IRQHandler        [WEAK]
                EXPORT  MDMA_Channel10_IRQHandler       [WEAK]
                EXPORT  MDMA_Channel11_IRQHandler       [WEAK]
                EXPORT  MDMA_Channel12_IRQHandler       [WEAK]
                EXPORT  MDMA_Channel13_IRQHandler       [WEAK]
                EXPORT  MDMA_Channel14_IRQHandler       [WEAK]
                EXPORT  MDMA_Channel15_IRQHandler       [WEAK]
                EXPORT  SDPU_IRQHandler                 [WEAK]
                EXPORT  FPU_CPU1_IRQHandler             [WEAK]
                EXPORT  ECCMON_IRQHandler               [WEAK]
                EXPORT  RTC_ALARM_IRQHandler            [WEAK]
                EXPORT  I2C1_EV_IRQHandler              [WEAK]
                EXPORT  I2C1_ER_IRQHandler              [WEAK]
                EXPORT  I2C2_EV_IRQHandler              [WEAK]
                EXPORT  I2C2_ER_IRQHandler              [WEAK]
                EXPORT  I2C3_EV_IRQHandler              [WEAK]
                EXPORT  I2C3_ER_IRQHandler              [WEAK]
                EXPORT  I2C4_EV_IRQHandler              [WEAK]
                EXPORT  I2C4_ER_IRQHandler              [WEAK]
                EXPORT  I2C5_EV_IRQHandler              [WEAK]
                EXPORT  I2C5_ER_IRQHandler              [WEAK]
                EXPORT  I2C6_EV_IRQHandler              [WEAK]
                EXPORT  I2C6_ER_IRQHandler              [WEAK]
                EXPORT  I2C7_EV_IRQHandler              [WEAK]
                EXPORT  I2C7_ER_IRQHandler              [WEAK]
                EXPORT  I2C8_EV_IRQHandler              [WEAK]
                EXPORT  I2C8_ER_IRQHandler              [WEAK]
                EXPORT  I2C9_EV_IRQHandler              [WEAK]
                EXPORT  I2C9_ER_IRQHandler              [WEAK]
                EXPORT  I2C10_EV_IRQHandler             [WEAK]
                EXPORT  I2C10_ER_IRQHandler             [WEAK]
                EXPORT  I2S1_IRQHandler                 [WEAK]
                EXPORT  I2S2_IRQHandler                 [WEAK]
                EXPORT  I2S3_IRQHandler                 [WEAK]
                EXPORT  I2S4_IRQHandler                 [WEAK]
                EXPORT  xSPI2_IRQHandler                [WEAK]
                EXPORT  SPI1_IRQHandler                 [WEAK]
                EXPORT  SPI2_IRQHandler                 [WEAK]
                EXPORT  SPI3_IRQHandler                 [WEAK]
                EXPORT  SPI4_IRQHandler                 [WEAK]
                EXPORT  SPI5_IRQHandler                 [WEAK]
                EXPORT  SPI6_IRQHandler                 [WEAK]
                EXPORT  SPI7_IRQHandler                 [WEAK]
                EXPORT  LCD_EV_IRQHandler               [WEAK]
                EXPORT  LCD_ER_IRQHandler               [WEAK]
                EXPORT  DVP1_IRQHandler                 [WEAK]
                EXPORT  DVP2_IRQHandler                 [WEAK]
                EXPORT  DMAMUX2_IRQHandler              [WEAK]
                EXPORT  USB1_HS_EPx_OUT_IRQHandler      [WEAK]
                EXPORT  USB1_HS_EPx_IN_IRQHandler       [WEAK]
                EXPORT  USB1_HS_WKUP_IRQHandler         [WEAK]
                EXPORT  USB1_HS_IRQHandler              [WEAK]
                EXPORT  USB2_HS_EPx_OUT_IRQHandler      [WEAK]
                EXPORT  USB2_HS_EPx_IN_IRQHandler       [WEAK]
                EXPORT  USB2_HS_WKUP_IRQHandler         [WEAK]
                EXPORT  USB2_HS_IRQHandler              [WEAK]
                EXPORT  ETH1_IRQHandler                 [WEAK]
                EXPORT  ETH1_PMT_LPI_IRQHandler         [WEAK]
                EXPORT  ETH2_IRQHandler                 [WEAK]
                EXPORT  ETH2_PMT_LPI_IRQHandler         [WEAK]
                EXPORT  FDCAN1_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN2_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN3_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN4_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN1_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN2_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN3_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN4_INT1_IRQHandler          [WEAK]
                EXPORT  USART1_IRQHandler               [WEAK]
                EXPORT  USART2_IRQHandler               [WEAK]
                EXPORT  USART3_IRQHandler               [WEAK]
                EXPORT  USART4_IRQHandler               [WEAK]
                EXPORT  USART5_IRQHandler               [WEAK]
                EXPORT  USART6_IRQHandler               [WEAK]
                EXPORT  USART7_IRQHandler               [WEAK]
                EXPORT  USART8_IRQHandler               [WEAK]
                EXPORT  UART9_IRQHandler                [WEAK]
                EXPORT  UART10_IRQHandler               [WEAK]
                EXPORT  UART11_IRQHandler               [WEAK]
                EXPORT  UART12_IRQHandler               [WEAK]
                EXPORT  UART13_IRQHandler               [WEAK]
                EXPORT  UART14_IRQHandler               [WEAK]
                EXPORT  UART15_IRQHandler               [WEAK]
                EXPORT  LPUART1_IRQHandler              [WEAK]
                EXPORT  LPUART2_IRQHandler              [WEAK]
                EXPORT  GPU_IRQHandler                  [WEAK]
                EXPORT  SDMMC1_IRQHandler               [WEAK]
                EXPORT  SDMMC2_IRQHandler               [WEAK]
                EXPORT  ADC1_IRQHandler                 [WEAK]
                EXPORT  ADC2_IRQHandler                 [WEAK]
                EXPORT  ADC3_IRQHandler                 [WEAK]
                EXPORT  COMP1_2_IRQHandler              [WEAK]
                EXPORT  COMP3_4_IRQHandler              [WEAK]
                EXPORT  SHRTIM1_INT1_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT2_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT3_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT4_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT5_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT6_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT7_IRQHandler         [WEAK]
                EXPORT  SHRTIM1_INT8_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT1_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT2_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT3_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT4_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT5_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT6_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT7_IRQHandler         [WEAK]
                EXPORT  SHRTIM2_INT8_IRQHandler         [WEAK]
                EXPORT  FDCAN5_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN6_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN7_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN8_INT0_IRQHandler          [WEAK]
                EXPORT  FDCAN5_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN6_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN7_INT1_IRQHandler          [WEAK]
                EXPORT  FDCAN8_INT1_IRQHandler          [WEAK]
                EXPORT  LPTIM5_WKUP_IRQHandler          [WEAK]
                EXPORT  JPEG_SGDMA_H2P_IRQHandler       [WEAK]
                EXPORT  JPEG_SGDMA_P2H_IRQHandler       [WEAK]
                EXPORT  WAKEUP_IO_IRQHandler            [WEAK]
                EXPORT  SEMA4_INT1_IRQHandler           [WEAK]
                EXPORT  WWDG2_RST_IRQHandler            [WEAK]
                EXPORT  OTPC_IRQHandler                 [WEAK]
                EXPORT  FEMC_IRQHandler                 [WEAK]
                EXPORT  DCMUB_IRQHandler                [WEAK]
                EXPORT  DAC1_IRQHandler                 [WEAK]
                EXPORT  DAC2_IRQHandler                 [WEAK]
                EXPORT  MDMA_AHBS_ER_IRQHandler         [WEAK]
                EXPORT  CM7_CATCH_READ_ER_IRQHandler    [WEAK]
                EXPORT  DAC3_IRQHandler                 [WEAK]
                EXPORT  DAC4_IRQHandler                 [WEAK]
                EXPORT  EMC_IRQHandler                  [WEAK]
                EXPORT  DAC5_IRQHandler                 [WEAK]
                EXPORT  DAC6_IRQHandler                 [WEAK]
                EXPORT  ESC_OPB_IRQHandler              [WEAK]
                EXPORT  ESC_SYNC0_IRQHandler            [WEAK]
                EXPORT  ESC_SYNC1_IRQHandler            [WEAK]
                EXPORT  ESC_WRP_IRQHandler              [WEAK]
                EXPORT  ATIM1_BRK_IRQHandler            [WEAK]
                EXPORT  ATIM1_TRG_COM_IRQHandler        [WEAK]
                EXPORT  ATIM1_CC_IRQHandler             [WEAK]
                EXPORT  ATIM1_UP_IRQHandler             [WEAK]
                EXPORT  ATIM2_BRK_IRQHandler            [WEAK]
                EXPORT  ATIM2_TRG_COM_IRQHandler        [WEAK]
                EXPORT  ATIM2_CC_IRQHandler             [WEAK]
                EXPORT  ATIM2_UP_IRQHandler             [WEAK]
                EXPORT  ATIM3_BRK_IRQHandler            [WEAK]
                EXPORT  ATIM3_TRG_COM_IRQHandler        [WEAK]
                EXPORT  ATIM3_CC_IRQHandler             [WEAK]
                EXPORT  ATIM3_UP_IRQHandler             [WEAK]
                EXPORT  ATIM4_BRK_IRQHandler            [WEAK]
                EXPORT  ATIM4_TRG_COM_IRQHandler        [WEAK]
                EXPORT  ATIM4_CC_IRQHandler             [WEAK]
                EXPORT  ATIM4_UP_IRQHandler             [WEAK]
                EXPORT  GTIMA1_IRQHandler               [WEAK]
                EXPORT  GTIMA2_IRQHandler               [WEAK]
                EXPORT  GTIMA3_IRQHandler               [WEAK]
                EXPORT  GTIMA4_IRQHandler               [WEAK]
                EXPORT  GTIMA5_IRQHandler               [WEAK]
                EXPORT  GTIMA6_IRQHandler               [WEAK]
                EXPORT  GTIMA7_IRQHandler               [WEAK]
                EXPORT  GTIMB1_IRQHandler               [WEAK]
                EXPORT  GTIMB2_IRQHandler               [WEAK]
                EXPORT  GTIMB3_IRQHandler               [WEAK]
                EXPORT  BTIM1_IRQHandler                [WEAK]
                EXPORT  BTIM2_IRQHandler                [WEAK]
                EXPORT  BTIM3_IRQHandler                [WEAK]
                EXPORT  BTIM4_IRQHandler                [WEAK]
                EXPORT  LPTIM1_WKUP_IRQHandler          [WEAK]
                EXPORT  LPTIM2_WKUP_IRQHandler          [WEAK]
                EXPORT  LPTIM3_WKUP_IRQHandler          [WEAK]
                EXPORT  LPTIM4_WKUP_IRQHandler          [WEAK]
                EXPORT  DSMU_FLT0_IRQHandler            [WEAK]
                EXPORT  DSMU_FLT1_IRQHandler            [WEAK]
                EXPORT  DSMU_FLT2_IRQHandler            [WEAK]
                EXPORT  DSMU_FLT3_IRQHandler            [WEAK]
                EXPORT  FMAC_IRQHandler                 [WEAK]
                EXPORT  CORDIC_IRQHandler               [WEAK]
                EXPORT  DMAMUX1_IRQHandler              [WEAK]
                EXPORT  MMU_IRQHandler                  [WEAK]
                EXPORT  SysTick_Handler                 [WEAK]

; All weak handlers fall through to Default_Handler infinite loop
WWDG1_IRQHandler
PVD_IRQHandler
RTC_TAMPER_IRQHandler
RTC_WKUP_IRQHandler
RCC_IRQHandler
EXTI0_IRQHandler
EXTI1_IRQHandler
EXTI2_IRQHandler
EXTI3_IRQHandler
EXTI4_IRQHandler
EXTI9_5_IRQHandler
EXTI15_10_IRQHandler
DMA1_Channel0_IRQHandler
DMA1_Channel1_IRQHandler
DMA1_Channel2_IRQHandler
DMA1_Channel3_IRQHandler
DMA1_Channel4_IRQHandler
DMA1_Channel5_IRQHandler
DMA1_Channel6_IRQHandler
DMA1_Channel7_IRQHandler
DMA2_Channel0_IRQHandler
DMA2_Channel1_IRQHandler
DMA2_Channel2_IRQHandler
DMA2_Channel3_IRQHandler
DMA2_Channel4_IRQHandler
DMA2_Channel5_IRQHandler
DMA2_Channel6_IRQHandler
DMA2_Channel7_IRQHandler
DMA3_Channel0_IRQHandler
DMA3_Channel1_IRQHandler
DMA3_Channel2_IRQHandler
DMA3_Channel3_IRQHandler
DMA3_Channel4_IRQHandler
DMA3_Channel5_IRQHandler
DMA3_Channel6_IRQHandler
DMA3_Channel7_IRQHandler
MDMA_Channel0_IRQHandler
MDMA_Channel1_IRQHandler
MDMA_Channel2_IRQHandler
MDMA_Channel3_IRQHandler
MDMA_Channel4_IRQHandler
MDMA_Channel5_IRQHandler
MDMA_Channel6_IRQHandler
MDMA_Channel7_IRQHandler
MDMA_Channel8_IRQHandler
MDMA_Channel9_IRQHandler
MDMA_Channel10_IRQHandler
MDMA_Channel11_IRQHandler
MDMA_Channel12_IRQHandler
MDMA_Channel13_IRQHandler
MDMA_Channel14_IRQHandler
MDMA_Channel15_IRQHandler
SDPU_IRQHandler
FPU_CPU1_IRQHandler
ECCMON_IRQHandler
RTC_ALARM_IRQHandler
I2C1_EV_IRQHandler
I2C1_ER_IRQHandler
I2C2_EV_IRQHandler
I2C2_ER_IRQHandler
I2C3_EV_IRQHandler
I2C3_ER_IRQHandler
I2C4_EV_IRQHandler
I2C4_ER_IRQHandler
I2C5_EV_IRQHandler
I2C5_ER_IRQHandler
I2C6_EV_IRQHandler
I2C6_ER_IRQHandler
I2C7_EV_IRQHandler
I2C7_ER_IRQHandler
I2C8_EV_IRQHandler
I2C8_ER_IRQHandler
I2C9_EV_IRQHandler
I2C9_ER_IRQHandler
I2C10_EV_IRQHandler
I2C10_ER_IRQHandler
I2S1_IRQHandler
I2S2_IRQHandler
I2S3_IRQHandler
I2S4_IRQHandler
xSPI2_IRQHandler
SPI1_IRQHandler
SPI2_IRQHandler
SPI3_IRQHandler
SPI4_IRQHandler
SPI5_IRQHandler
SPI6_IRQHandler
SPI7_IRQHandler
LCD_EV_IRQHandler
LCD_ER_IRQHandler
DVP1_IRQHandler
DVP2_IRQHandler
DMAMUX2_IRQHandler
USB1_HS_EPx_OUT_IRQHandler
USB1_HS_EPx_IN_IRQHandler
USB1_HS_WKUP_IRQHandler
USB1_HS_IRQHandler
USB2_HS_EPx_OUT_IRQHandler
USB2_HS_EPx_IN_IRQHandler
USB2_HS_WKUP_IRQHandler
USB2_HS_IRQHandler
ETH1_IRQHandler
ETH1_PMT_LPI_IRQHandler
ETH2_IRQHandler
ETH2_PMT_LPI_IRQHandler
FDCAN1_INT0_IRQHandler
FDCAN2_INT0_IRQHandler
FDCAN3_INT0_IRQHandler
FDCAN4_INT0_IRQHandler
FDCAN1_INT1_IRQHandler
FDCAN2_INT1_IRQHandler
FDCAN3_INT1_IRQHandler
FDCAN4_INT1_IRQHandler
USART1_IRQHandler
USART2_IRQHandler
USART3_IRQHandler
USART4_IRQHandler
USART5_IRQHandler
USART6_IRQHandler
USART7_IRQHandler
USART8_IRQHandler
UART9_IRQHandler
UART10_IRQHandler
UART11_IRQHandler
UART12_IRQHandler
UART13_IRQHandler
UART14_IRQHandler
UART15_IRQHandler
LPUART1_IRQHandler
LPUART2_IRQHandler
GPU_IRQHandler
SDMMC1_IRQHandler
SDMMC2_IRQHandler
ADC1_IRQHandler
ADC2_IRQHandler
ADC3_IRQHandler
COMP1_2_IRQHandler
COMP3_4_IRQHandler
SHRTIM1_INT1_IRQHandler
SHRTIM1_INT2_IRQHandler
SHRTIM1_INT3_IRQHandler
SHRTIM1_INT4_IRQHandler
SHRTIM1_INT5_IRQHandler
SHRTIM1_INT6_IRQHandler
SHRTIM1_INT7_IRQHandler
SHRTIM1_INT8_IRQHandler
SHRTIM2_INT1_IRQHandler
SHRTIM2_INT2_IRQHandler
SHRTIM2_INT3_IRQHandler
SHRTIM2_INT4_IRQHandler
SHRTIM2_INT5_IRQHandler
SHRTIM2_INT6_IRQHandler
SHRTIM2_INT7_IRQHandler
SHRTIM2_INT8_IRQHandler
FDCAN5_INT0_IRQHandler
FDCAN6_INT0_IRQHandler
FDCAN7_INT0_IRQHandler
FDCAN8_INT0_IRQHandler
FDCAN5_INT1_IRQHandler
FDCAN6_INT1_IRQHandler
FDCAN7_INT1_IRQHandler
FDCAN8_INT1_IRQHandler
LPTIM5_WKUP_IRQHandler
JPEG_SGDMA_H2P_IRQHandler
JPEG_SGDMA_P2H_IRQHandler
WAKEUP_IO_IRQHandler
SEMA4_INT1_IRQHandler
WWDG2_RST_IRQHandler
OTPC_IRQHandler
FEMC_IRQHandler
DCMUB_IRQHandler
DAC1_IRQHandler
DAC2_IRQHandler
MDMA_AHBS_ER_IRQHandler
CM7_CATCH_READ_ER_IRQHandler
DAC3_IRQHandler
DAC4_IRQHandler
EMC_IRQHandler
DAC5_IRQHandler
DAC6_IRQHandler
ESC_OPB_IRQHandler
ESC_SYNC0_IRQHandler
ESC_SYNC1_IRQHandler
ESC_WRP_IRQHandler
ATIM1_BRK_IRQHandler
ATIM1_TRG_COM_IRQHandler
ATIM1_CC_IRQHandler
ATIM1_UP_IRQHandler
ATIM2_BRK_IRQHandler
ATIM2_TRG_COM_IRQHandler
ATIM2_CC_IRQHandler
ATIM2_UP_IRQHandler
ATIM3_BRK_IRQHandler
ATIM3_TRG_COM_IRQHandler
ATIM3_CC_IRQHandler
ATIM3_UP_IRQHandler
ATIM4_BRK_IRQHandler
ATIM4_TRG_COM_IRQHandler
ATIM4_CC_IRQHandler
ATIM4_UP_IRQHandler
GTIMA1_IRQHandler
GTIMA2_IRQHandler
GTIMA3_IRQHandler
GTIMA4_IRQHandler
GTIMA5_IRQHandler
GTIMA6_IRQHandler
GTIMA7_IRQHandler
GTIMB1_IRQHandler
GTIMB2_IRQHandler
GTIMB3_IRQHandler
BTIM1_IRQHandler
BTIM2_IRQHandler
BTIM3_IRQHandler
BTIM4_IRQHandler
LPTIM1_WKUP_IRQHandler
LPTIM2_WKUP_IRQHandler
LPTIM3_WKUP_IRQHandler
LPTIM4_WKUP_IRQHandler
DSMU_FLT0_IRQHandler
DSMU_FLT1_IRQHandler
DSMU_FLT2_IRQHandler
DSMU_FLT3_IRQHandler
FMAC_IRQHandler
CORDIC_IRQHandler
DMAMUX1_IRQHandler
MMU_IRQHandler
SysTick_Handler
                B       .

                ENDP
                ALIGN

                END
