-------------------------------------------------------------------------------
-- Title      : Clock Divider
-- Project    : ELE113 Lab 1
-------------------------------------------------------------------------------
-- File             : $RCSfile: ELE113_lab1.vhd,v $
-- Last edited by   : $Author: alme $
-- Last update      : $Date: 2008/02/05 11:42:01 $
-- Current Revision : $Revision: 1.9 $
-------------------------------------------------------------------------------
-- Description: 
-- Input: 50 MHz/250Mhz
-- Output: 1kHz, 100 Hz, 1 Hz
-- Duty Cycle: High = 20 ns, the rest is low (following 50 MHz clock)
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

entity clock_divider is
  generic (
    g_frequency    : integer := 50;
    g_is_testbench : boolean := false);
  port(
    clk              : in  std_logic;
    pulse_1Hz        : out std_logic;
    pulse_100Hz      : out std_logic;
    pulse_1kHz       : out std_logic
  );
end clock_divider;

architecture behave of clock_divider is
  signal counter_1kHz    : std_logic_vector(19 downto 0):= (others => '0');
  signal counter_100Hz   : std_logic_vector(3 downto 0):= (others => '0');
  signal counter_1Hz     : std_logic_vector(7 downto 0):= (others => '0');
  signal pulse_1kHz_i      : std_logic;
  signal pulse_100Hz_i     : std_logic;
  signal pulse_1Hz_i       : std_logic;
  
  signal dividing_factor_testbench  : std_logic_vector(19 downto 0);  
  signal dividing_factor_production : std_logic_vector(19 downto 0);  
  signal dividing_factor            : std_logic_vector(19 downto 0);  
begin

  dividing_factor_production <= X"0C34F" when (g_frequency = 50) else 
                                X"3D08F"; --250
  -- pulse_1kHz == 100kHz for testbench. Otherwise we have to wait too long.
  dividing_factor_testbench  <= X"001F3" when (g_frequency = 50) else 
                                X"009C3";
  
  dividing_factor <= dividing_factor_production when g_is_testbench = false else 
                     dividing_factor_testbench;
  
  -- process p_debouncer
  -- Sequential process that debounces the input
  p_1kHz: process (clk) is
  begin
    if rising_edge(clk) then
      -- default
      pulse_1kHz_i <= '0';
      
      if (counter_1kHz = dividing_factor) then 
        counter_1kHz   <= (others => '0');
        pulse_1kHz_i   <= '1';
      else 
        counter_1kHz   <= counter_1kHz + 1;
      end if;
    end if;
  end process p_1kHz;
  
  p_100Hz: process(clk) 
  begin
    if rising_edge(clk) then
      -- default
      pulse_100Hz_i <= '0';
      
      if (pulse_1kHz_i = '1') then -- base on the 1 kHz
        if (counter_100Hz = 9) then 
          counter_100Hz   <= (others => '0');
          pulse_100Hz_i   <= '1';
        else 
          counter_100Hz   <= counter_100Hz + 1;
        end if;
      end if;
    end if;
  end process p_100Hz;
  
  p_1Hz: process(clk) 
  begin
    if rising_edge(clk) then
      -- default
      pulse_1Hz_i <= '0';
      
      if (pulse_100Hz_i = '1') then -- base on the 100 Hz
        if (counter_1Hz = 99) then 
          counter_1Hz   <= (others => '0');
          pulse_1Hz_i   <= '1';
        else 
          counter_1Hz   <= counter_1Hz + 1;
        end if;
      end if;
    end if;
  end process p_1Hz;
  
  --output 
  pulse_1kHz  <= pulse_1kHz_i;
  pulse_100Hz <= pulse_100Hz_i;
  pulse_1Hz   <= pulse_1Hz_i;
end architecture behave;

