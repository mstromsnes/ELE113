/*
 * spi_master_func.c
 *
 *  Created on: 23. nov. 2016
 *      Author: Alaka
 */


#include <spi_master_func.h>

// reset the spi_master -module
void spi_master_reset(){
	SET_SPI_RESET;
}

// activate oneshot mode
void spi_master_oneshot(){
	SET_SPI_ONESHOT;
}

// turn continuous mode on
void spi_master_continuous_on(){
	SET_SPI_CONTINOUS_ON;
}

// turn continuous mode off
void spi_master_continuous_off(){
	SET_SPI_CONTIONOUS_OFF;
}

// check if the spi-module is active - returns '1' if so
int spi_master_busy(){
	if (GET_SPI_CONTROL & 0x00000002) return 1;
	if (GET_SPI_CONTROL & 0x00000003) return 1;
	return 0;
}

// get the value of the control and status register
int spi_master_get_status(){
	return GET_SPI_CONTROL;
}

// get the value of temperature register
double spi_master_read_temp(){
	alt_u32 temp = GET_SPI_TEMP;
	double temperature = temp/4.0 - 103;
	return temperature;
}

// get the value of channel 1 register(Ai1_reg)
double spi_master_read_channel1(){
	alt_u32 AI1 = GET_SPI_CHAN1;
	double channel1 = 2.5*AI1/1024.0;
	return channel1;
}

// get the value of channel 2 register(Ai2_reg)
double spi_master_read_channel2(){
	alt_u32 AI2 = GET_SPI_CHAN2;
	double channel2 = 2.5*AI2/1024.0;
	return channel2;
}

// get the value of channel 3 register(Ai3_reg)
double spi_master_read_channel3(){
	alt_u32 AI3 = GET_SPI_CHAN1;
	double channel3 = 2.5*AI3/1024.0;
	return channel3;
}

// get the value of channel 4 register(Ai4_reg)
double spi_master_read_channel4(){
	alt_u32 AI4 = GET_SPI_CHAN4;
	double channel4 = 2.5*AI4/1024.0;
	return channel4;
}

// get the value of reference register
double spi_master_read_ref(){
	alt_u32 ref = GET_SPI_REFERENCE;
	double reference = 2.5*ref/1024.0;
	return reference;
}
