/*
 * Copyright (c) 2006-2025, RT-Thread Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author           Notes
 * 2026-01-24     ox-horse         first version
 */

#include <board.h>
#include <rtthread.h>
#include <drv_gpio.h>
#include "SEGGER_RTT.h"
#ifndef RT_USING_NANO
#include <rtdevice.h>
#endif /* RT_USING_NANO */


#define ADC_DEV_NAME        "adc1"  /* ADC 设备名称 */
#define ADC_DEV_CHANNEL     5       /* ADC 通道 */
#define REFER_VOLTAGE       10
#define CONVERT_BITS        1
rt_adc_device_t adc_dev;            /* ADC 设备句柄 */


void adc_init(void)
{
    rt_uint32_t value;
    /* 查找设备 */
    adc_dev = (rt_adc_device_t)rt_device_find(ADC_DEV_NAME);
    if (adc_dev == RT_NULL) {
        SEGGER_RTT_printf(0, "ADC device not found!\r\n");
        return; // 必须返回，绝不能往下执行
    }
    /* 使能设备 */
    rt_adc_enable(adc_dev, ADC_DEV_CHANNEL);
    /* 读取采样值 */
    value = rt_adc_read(adc_dev, ADC_DEV_CHANNEL);
    /* 转换为对应电压值 */
    rt_uint32_t vol = value * REFER_VOLTAGE / CONVERT_BITS;
    SEGGER_RTT_printf(0,"the voltage is :%d.%02d \n", vol / 100, vol % 100);
    /* 关闭通道 */
    rt_adc_disable(adc_dev, ADC_DEV_CHANNEL);
}



/* defined the LED0 pin: PA4 */
#define LED0_PIN GET_PIN(D, 13)

int main(void)
{
    SEGGER_RTT_Init();

    /* set LED0 pin mode to output */
    rt_pin_mode(LED0_PIN, PIN_MODE_OUTPUT);

    while (1)
    {   
        SEGGER_RTT_printf(0, "yzz_debug\r\n");
        adc_init();
        rt_pin_write(LED0_PIN, PIN_HIGH);
        rt_thread_mdelay(200);
        rt_pin_write(LED0_PIN, PIN_LOW);
        rt_thread_mdelay(200);
    }
}

