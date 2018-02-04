----------------- COPYRIGHT NERA ASA 2000---------------------------------
--
-- File:          tb_spi_master.vhd
-- Init Author:   
-- Init Date:     15 sep 2016
-- Project:
-- Description:
--
--------------------------------------------------------------------------
-- RCS Last Revision Information
-- 
-- $Revision$
-- $Author$
-- $Date$ 
--
--------------------------------------------------------------------------
-- RCS Revision History
--
-- $Log$
--
--------------------------------------------------------------------------
-- library declarations

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library common_work;
--ibrary _work;

-- entity declaration of testbench

entity TB_SPI_MASTER is
end TB_SPI_MASTER;

-- behavoiural decription of testbench

architecture BEHAV of TB_SPI_MASTER is

-- SPI_MASTER Component Declaration

component SPI_MASTER is
   port
   (
   CLK               :  in     std_logic;
   RESET             :  in     std_logic;
   ONESHOT           :  in     std_logic;
   CONTINOUS         :  in     std_logic;
   TEMP              :  out    std_logic_vector(9 downto 0);
   AI1               :  out    std_logic_vector(9 downto 0);
   AI2               :  out    std_logic_vector(9 downto 0);
   AI3               :  out    std_logic_vector(9 downto 0);
   AI4               :  out    std_logic_vector(9 downto 0);
   REFERENCE         :  out    std_logic_vector(9 downto 0);
   SPI_BUSY          :  out    std_logic;
   SCLK              :  out    std_logic;
   MOSI              :  out    std_logic;
   MISO              :  in     std_logic;
   CS_N              :  out    std_logic;
   WR_N              :  out    std_logic;
   CONVST_N          :  out    std_logic;
   BUSY              :  in     std_logic;
   OTI_N             :  in     std_logic
   );
end component;

-- AD7817 Component Declaration

component AD7817 is
   port
   (
   SCLK              :  IN     std_logic;
   MOSI              :  IN     std_logic;
   MISO              :  OUT    std_logic;
   CS_N              :  IN     std_logic;
   WR_N              :  IN     std_logic;
   CONVST_N          :  IN     std_logic;
   BUSY              :  OUT    std_logic;
   OTI_N             :  OUT    std_logic
   );
end component;

-- Signal Declarations

shared variable T   : time := 50 ns;
shared variable TSU : time := 10 ns;
shared variable Vector : integer := 0;
signal VectorClk    : std_logic := '0';
signal StrobeClk    : std_logic := '0';

-- SPI_MASTER Input Signals

signal CLK               : std_logic := '0';
signal RESET             : std_logic := '0';
signal ONESHOT           : std_logic := '0';
signal CONTINOUS         : std_logic := '0';
signal MISO              : std_logic := '0';
signal BUSY              : std_logic := '0';
signal OTI_N             : std_logic := '0';

-- SPI_MASTER InOut Signals


-- SPI_MASTER Output Signals

signal TEMP              : std_logic_vector(9 downto 0);
signal AI1               : std_logic_vector(9 downto 0);
signal AI2               : std_logic_vector(9 downto 0);
signal AI3               : std_logic_vector(9 downto 0);
signal AI4               : std_logic_vector(9 downto 0);
signal REFERENCE         : std_logic_vector(9 downto 0);
signal SPI_BUSY          : std_logic;
signal SCLK              : std_logic;
signal MOSI              : std_logic;
signal CS_N              : std_logic;
signal WR_N              : std_logic;
signal CONVST_N          : std_logic;

begin

-- SPI_MASTER Port Map

SPI_MASTER0 : SPI_MASTER
   port map
   (
   CLK               => CLK,
   RESET             => RESET,
   ONESHOT           => ONESHOT,
   CONTINOUS         => CONTINOUS,
   TEMP              => TEMP,
   AI1               => AI1,
   AI2               => AI2,
   AI3               => AI3,
   AI4               => AI4,
   REFERENCE         => REFERENCE,
   SPI_BUSY          => SPI_BUSY,
   SCLK              => SCLK,
   MOSI              => MOSI,
   MISO              => MISO,
   CS_N              => CS_N,
   WR_N              => WR_N,
   CONVST_N          => CONVST_N,
   BUSY              => BUSY,
   OTI_N             => OTI_N
   );

	
	-- AD7817 Port Map

AD78170 : AD7817
   port map
   (
   SCLK              => SCLK,
   MOSI              => MOSI,
   MISO              => MISO,
   CS_N              => CS_N,
   WR_N              => WR_N,
   CONVST_N          => CONVST_N,
   BUSY              => BUSY,
   OTI_N             => OTI_N
   );
-- infinite clock generator

VectorClk <= not VectorClk after T/2;
StrobeClk <= VectorClk after (T/2)- 1 ns;
CLK <= not VectorClk after TSU;

pVector: process(VectorClk)
begin
   if (VectorClk'event and VectorClk='0') then
      Vector := Vector + 1;
   end if;
end process pVector;

-- init process

INIT : process
   begin
-- insert your stimuli here !
   wait for T;
   RESET <= '1';
   wait for T;
   RESET <= '0';
	
	wait for T;
	CONTINOUS <= '1';
   wait for 50 ms;
	
	end process;
	
	

end BEHAV;
