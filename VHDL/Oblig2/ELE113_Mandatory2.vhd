-------------------------------------------------------------------------------
-- Title      : ELE113 Mandatory Assignment 1 - SPI interface
-- Project    : ELE113
-------------------------------------------------------------------------------
-- File             : $RCSfile: ELE113_lab1.vhd,v $
-- Last edited by   : $Author: alme $
-- Last update      : $Date: 2008/02/05 11:42:01 $
-- Current Revision : $Revision: 1.9 $
-------------------------------------------------------------------------------
-- Description: 
-- This module implements the SPI interface to the sensor board ADC 
-- The 10 bit value is displayed on the seven segment dispays. 
-- 
-- Specification: 
-- * Clock frequency = 50 MHz
-- * Key[3]   = reset
-- * Key[0]   = one shot conversion
-- * Key[1]   = Continous conversion - i.e. conversion are going on all the time
--              Press one time - light LEDG[1] - shows continous mode is ongoing
--              Press one more time - unlight LEDG[1]. Continous mode stops.
-- * SW[2..0] = selects which value to show on HEX display
--              "000" - Temperature
--              "001" - Ain1
--              "010" - Ain2
--              "011" - Ain3
--              "100" - Ain4
--              others - Internal refernce - 1.23V
-- * LEDG0 = Lights up when conversion is done - unlit when conversion ongoing 
-- * LEDR[3..0] = lights up according to pattern on SW[3..0]
-- * The other leds can be used for debugging. Put signals out which you can measure with 
--   the oscilloscope
-------------------------------------------------------------------------------
-- Revision History : 
-------------------------------------------------------------------------------
--
-- This file is property of and copyright by the Bergen University College,
-- Department of Electrical Engineering 
-- This file has been written by Johan Alme (Johan.Alme@hib.no)
--
-- Permission to use, copy, modify and distribute this design and its
-- documentation strictly for non-commercial purposes is hereby granted
-- without fee, provided that the above copyright notice appears in all
-- copies and that both the copyright notice and this permission notice
-- appear in the supporting documentation. The authors make no claims
-- about the suitability of this design for any purpose. It is
-- provided "as is" without express or implied warranty.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ELE113_Mandatory1 is
  generic (
    g_frequency         : integer := 50;
    g_is_testbench      : boolean := false);
  port(
    CLOCK_50            : in  std_logic;
    --external interface
    SW                  : in  std_logic_vector(17 downto 0);
    KEY                 : in  std_logic_vector(3 downto 0);
    LEDR                : out std_logic_vector(17 downto 0);
    LEDG                : out std_logic_vector(8 downto 0);
    HEX0                : out std_logic_vector(6 downto 0);
    HEX1                : out std_logic_vector(6 downto 0);
    HEX2                : out std_logic_vector(6 downto 0);
    HEX3                : out std_logic_vector(6 downto 0);
    HEX4                : out std_logic_vector(6 downto 0);
    HEX5                : out std_logic_vector(6 downto 0);
    HEX6                : out std_logic_vector(6 downto 0);
    HEX7                : out std_logic_vector(6 downto 0);
    AD7817_MISO         : in  std_logic; --GPIO1
    AD7817_MOSI         : out std_logic; --GPIO3
    AD7817_SCLK         : out std_logic; --GPIO5
    AD7817_WR_N         : out std_logic; --GPIO7
    AD7817_CONVST_N     : out std_logic; --GPIO9
    AD7817_BUSY         : in  std_logic; --GPIO11
    AD7817_OTI_N        : in  std_logic; --GPIO13
    AD7817_CS_N         : out std_logic);--GPIO15
    
end ELE113_Mandatory1;

architecture behave of ELE113_Mandatory1 is
  signal sysclk       : std_logic:= '0';
  signal sw_synch     : std_logic_vector(2 downto 0):= (others => '0');
  signal key_synch    : std_logic_vector(3 downto 0):= (others => '0');
  alias one_shot_conv : std_logic is key_synch(0);
  alias continous_conv: std_logic is key_synch(1);
  alias reset         : std_logic is key_synch(3);
  signal enable_100Hz : std_logic;
    
  signal continous_convR : std_logic;
  signal conv_active     : std_logic;
  signal display_value   : std_logic_vector(11 downto 0);--use two more bits to make conversion easier.
  
  type adc_array is array (0 to 5) of std_logic_vector(9 downto 0);
  signal ad7817_output: adc_array;
  
  type seven_seg_array is array (0 to 7) of std_logic_vector(6 downto 0);
  signal seven_segment : seven_seg_array;
  signal decimal       : std_logic_vector(7 downto 0);
    
begin
  sysclk <= CLOCK_50;
  --g_sysclk50 : if (g_frequency = 50) generate 
  --begin 
  --  -- PLL
  --  m_pll : entity work.pll
  --  port map (
	--   inclk0 => CLOCK_50,
	--	c0		 => sysclk,--50 MHz
	--	c1		 => open,  --250MHz
	--	locked => open);
  --end generate g_sysclk50;

  --g_sysclk250 : if (g_frequency = 250) generate 
  --begin 
  --  -- PLL
  --  m_pll : entity work.pll
  --  port map (
	--   inclk0 => CLOCK_50,
	--	 c0		  => open,
	--	 c1		  => sysclk,
	--	 locked => open);
  --end generate g_sysclk250;
  
  --used for synching inputs
  m_clock_divider: entity work.clock_divider
  generic map (
    g_frequency    => g_frequency,
    g_is_testbench => g_is_testbench)-- makes the outputs 100x faster than stated by their names - to make simulation easier
  port map (
    clk            => sysclk,
    pulse_1Hz      => open,
    pulse_100Hz    => enable_100Hz,
    pulse_1kHz     => open);
     
  -- debounce and synch buttons (We don't use KEY[2])
  g_button_synch: for i in 0 to 3 generate
  begin 
    m_button_synch: entity work.debouncer
    generic map (
      level          => '0',
      polarity       => '1')-- '0' negative edge, '1' positive edge
    port map(
      clk            => sysclk,
      clk_100Hz      => enable_100Hz,
      input          => KEY(i),
      output         => key_synch(i));
  end generate g_button_synch;
  
  -- debounce and synch switches
  g_switch_synch: for i in 0 to 2 generate
  begin 
    m_switch_synch: entity work.debouncer
    generic map (
      level          => '1',
      polarity       => '1')-- '0' negative edge, '1' positive edge
    port map(
      clk            => sysclk,
      clk_100Hz      => enable_100Hz,
      input          => SW(i),
      output         => sw_synch(i));
  end generate g_switch_synch;
  
  
  --register continous_conv
  --this is just a pulse and needs to be set to a register so that it is high (or low) after a push of the button
  p_continous_mode : process(sysclk)
  begin
    if rising_edge(sysclk) then
      if (reset = '1') then
        continous_convR <= '0';
      elsif (continous_conv = '1') then
        continous_convR <= not continous_convR;
      end if;
    end if;
  end process p_continous_mode;
  
  m_spi_master: entity work.SPI_master
  port map(
    --	for higher level connection:
	  clk					=> sysclk,
	  reset				=> reset,
	  oneshot			=> one_shot_conv,
	  continous		=> continous_convR,
	  temp				=> ad7817_output(0),
	  Ai1					=> ad7817_output(1),
	  Ai2					=> ad7817_output(2),
	  Ai3					=> ad7817_output(3),
	  Ai4					=> ad7817_output(4),
	  reference		=> ad7817_output(5),
	  SPI_BUSY => conv_active,
    --	for SPI bus interface:
	  sclk				=> AD7817_SCLK,    
	  mosi				=> AD7817_MOSI,
	  miso				=> AD7817_MISO,   
	  cs_n				=> AD7817_CS_N,
	  wr_n				=> AD7817_WR_N, 
	  convst_n		=> AD7817_CONVST_N,
	  busy				=> AD7817_BUSY,
	  oti_n				=> AD7817_OTI_N);

   
  display_value <= "00" & ad7817_output(to_integer(unsigned(sw_synch))) when (sw_synch <= "101") else
                   "00" & ad7817_output(5);
  
  -- generates the seven seg code from the hex number
  g_seven_segment_vectors : for i in 0 to 2 generate
  begin
  	m_seven_segment_vectors : entity work.seven_seg_encoder
    port map (
      hex_number     => display_value(4*(i+1)-1 downto 4*i),
      seven_seg_code => seven_segment(i));
  end generate g_seven_segment_vectors;
  
  g_seven_segment_vectors2 : for i in 3 to 7 generate
  begin
    seven_segment(i) <= "1111111";
  end generate g_seven_segment_vectors2;
  
  -- set outputs
  HEX0 <= seven_segment(0);
  HEX1 <= seven_segment(1);
  HEX2 <= seven_segment(2);
  HEX3 <= seven_segment(3);
  HEX4 <= seven_segment(4);
  HEX5 <= seven_segment(5);
  HEX6 <= seven_segment(6);
  HEX7 <= seven_segment(7);
  -- combinatorial set outputs - we can measure time delay on this
  LEDR <= SW;
  LEDG(8 downto 2) <= "1001001";
  LEDG(1) <= continous_convR; -- '1' means this on
  LEDG(0) <= conv_active;
 
  
end architecture behave;

