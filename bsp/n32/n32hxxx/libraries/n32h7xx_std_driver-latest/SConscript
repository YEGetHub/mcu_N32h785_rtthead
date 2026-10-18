from building import *
import os

cwd = GetCurrentDir()
path = [os.path.join(cwd, 'n32h7xx_std_periph_driver/inc')]

src_path = os.path.join(cwd, 'n32h7xx_std_periph_driver/src')

# Select library file
src = [
os.path.join(src_path, 'misc.c'),
os.path.join(src_path, 'n32h7xx_gpio.c'),
os.path.join(src_path, 'n32h7xx_mmu.c'),
os.path.join(src_path, 'n32h7xx_dma.c'),
os.path.join(src_path, 'n32h7xx_dmamux.c'),
os.path.join(src_path, 'n32h7xx_pwr.c'),
os.path.join(src_path, 'n32h7xx_rcc.c'),
os.path.join(src_path, 'n32h7xx_dbg.c'),
os.path.join(src_path, 'n32h7xx_exti.c'),
]

if GetDepend(['RT_USING_SERIAL']) or GetDepend(['RT_USING_NANO', 'RT_USING_CONSOLE']):
    src += [os.path.join(src_path, 'n32h7xx_usart.c')]

if GetDepend(['RT_USING_SPI']):
    src += [os.path.join(src_path, 'n32h7xx_spi.c')]
    
if GetDepend(['RT_USING_QSPI']):
    src += [os.path.join(src_path, 'n32h7xx_xspi_v2.c')]
    
if GetDepend(['RT_USING_I2C']):
    src += [os.path.join(src_path, 'n32h7xx_i2c.c')]
    
if GetDepend(['BSP_USING_ETH']):
    src += [os.path.join(src_path, 'n32h7xx_eth.c')]

if GetDepend(['RT_USING_ADC']):
    src += [os.path.join(src_path, 'n32h7xx_adc.c')]
    
if GetDepend(['RT_USING_DAC']):
    src += [os.path.join(src_path, 'n32h7xx_dac.c')]
    
if GetDepend(['RT_USING_CAN']):
    src += [os.path.join(src_path, 'n32h7xx_fdcan.c')]
    
if GetDepend(['BSP_USING_LPTIM']):
    src += [os.path.join(src_path, 'n32h7xx_lptim.c')]
    
if GetDepend(['BSP_USING_SDRAM']):
    src += [os.path.join(src_path, 'n32h7xx_sdram.c')]
    
if GetDepend(['BSP_USING_LCD']):
    src += [os.path.join(src_path, 'n32h7xx_lcdc.c')]

if GetDepend(['RT_USING_RTC']):
    src += [os.path.join(src_path, 'n32h7xx_rtc.c')]
    
if GetDepend(['BSP_USING_QSPI_FLASH']) or GetDepend(['BSP_USING_ON_CHIP_FLASH']):
    src += [os.path.join(src_path, 'n32h7xx_smu.c')]
    
if GetDepend(['RT_USING_WDT']):
    src += [os.path.join(src_path, 'n32h7xx_iwdg.c')]
    src += [os.path.join(src_path, 'n32h7xx_wwdg.c')]

if GetDepend(['RT_USING_SDIO']):
    src += [os.path.join(src_path, 'n32h7xx_sdmmc.c')]

if GetDepend(['RT_USING_MTD_NAND']) or GetDepend(['RT_USING_MTD_NOR']) or GetDepend(['BSP_USING_NAND']):
    src += [os.path.join(src_path, 'n32h7xx_femc.c')]
    
if GetDepend(['RT_USING_AUDIO']):
    src += [os.path.join(src_path, 'n32h7xx_i2s.c')]

if GetDepend(['BSP_USING_CLOCK_TIMER']) or GetDepend(['RT_USING_PWM']) or GetDepend(['RT_USING_PULSE_ENCODER']):
    src += [os.path.join(src_path, 'n32h7xx_tim.c')]

CPPDEFINES = ['USE_STDPERIPH_DRIVER']

group = DefineGroup('Libraries', src, depend = ['PKG_USING_N32H7XX_STD_DRIVER'], CPPPATH = path, CPPDEFINES = CPPDEFINES)

Return('group')
