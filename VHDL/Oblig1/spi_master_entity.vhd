library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- SPI_master ENTITY:
entity SPI_MASTER is
port(
-- higher level connection:
   CLK         :in     std_logic;      -- System Clock
   RESET       :in     std_logic;      -- Sync reset active high
   ONESHOT     :in     std_logic;      -- Read all inputs one time
   CONTINOUS   :in     std_logic;      -- Read all inputs in loop
   TEMP        :out    std_logic_vector(9 downto 0);  -- Temperatur sensor
   AI1         :out    std_logic_vector(9 downto 0);  -- Analog Input 1
   AI2         :out    std_logic_vector(9 downto 0);  -- Analog Input 2
   AI3         :out    std_logic_vector(9 downto 0);  -- Analog Input 3
   AI4         :out    std_logic_vector(9 downto 0);  -- Analog Input 4
   REFERENCE   :out    std_logic_vector(9 downto 0);  -- Reference Voltage
   SPI_BUSY    :out    std_logic;      -- SPI Busy
-- SPI bus interface:
   SCLK        :out    std_logic;      -- SPI Clock
   MOSI        :out    std_logic;      -- Master Out Slave In
   MISO        :in     std_logic;      -- Master In Slave Out
   CS_N        :out    std_logic;      -- Chip Select active low
   WR_N        :out    std_logic;      -- Write Enable active low
   CONVST_N    :out    std_logic;      -- Conversion Start active low
   BUSY        :in     std_logic;      -- Busy signal from ADC
   OTI_N       :in     std_logic       -- Over Temp Indicator from ADC not used.
);
end SPI_MASTER;

