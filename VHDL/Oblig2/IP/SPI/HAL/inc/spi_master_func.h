// spi_master_func.h

#ifndef __SPI_MASTER_FUNC_H__
#define __SPI_MASTER_FUNC_H__

#include <stdio.h>
#include <spi_master_regs.h>

// reset the spi_master -module
void spi_master_reset();

// activate oneshot mode
void spi_master_oneshot();

// turn continuous mode on
void spi_master_continuous_on();

// turn continuous mode off
void spi_master_continuous_off();

// check if the spi-module is active - returns '1' if so
int spi_master_busy();

// get the value of the control and status register
int spi_master_get_status();

// get the value of temperature register
double spi_master_read_temp();

// get the value of channel 1 register(Ai1_reg)
double spi_master_read_channel1();

// get the value of channel 2 register(Ai2_reg)
double spi_master_read_channel2();

// get the value of channel 3 register(Ai3_reg)
double spi_master_read_channel3();

// get the value of channel 4 register(Ai4_reg)
double spi_master_read_channel4();

// get the value of reference register
double spi_master_read_ref();

#endif /* __SPI_MASTER_FUNC_H__ */
