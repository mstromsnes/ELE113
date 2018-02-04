-------------------------------------------------------------------------------
-- Title      : Debouncer
-- Project    : ELE113 Lab 1
-------------------------------------------------------------------------------
-- File             : $RCSfile: ELE113_lab1.vhd,v $
-- Last edited by   : $Author: alme $
-- Last update      : $Date: 2008/02/05 11:42:01 $
-- Current Revision : $Revision: 1.9 $
-------------------------------------------------------------------------------
-- Description: 
-- Detects a falling or rising edge on an input signal and gives a 
-- 1 clk cycle pulse out
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

entity debouncer is
  generic (
    level          : bit := '0'; -- '1' level is output (no pulse), '0' edge is detected (pulse)
    polarity       : bit := '1');-- '0' negative edge, '1' positive edge
  port(
    clk            : in  std_logic;
    clk_100Hz      : in  std_logic;
    input          : in  std_logic;
    output         : out std_logic
  );
end debouncer;

architecture behave of debouncer is
   signal srl_100Hz  : std_logic_vector(3 downto 0);
   signal srl_sysclk : std_logic_vector(2 downto 0);
   
   
begin
  
  -- process p_debouncer
  -- Sequential process that debounces the input
  p_debouncer: process (clk) is
  begin
    if rising_edge(clk) then
      if (clk_100Hz = '1') then 
        srl_100Hz <= srl_100Hz(2 downto 0) & input;
      end if;
    end if;
  end process p_debouncer;
  
  -- process p_pulse_gen
  -- Sequential process synchronizes the signal to the system clock to make a single pulse
  p_pulse_gen: process (clk) is
  begin
    if rising_edge(clk) then
      srl_sysclk <= srl_sysclk(1 downto 0) & srl_100Hz(3);
    end if;
  end process p_pulse_gen;
  
  g_edge : if (level = '0') generate
  begin 
    g_falling_edge : if (polarity = '0') generate
      output <= srl_sysclk(2) and (not srl_sysclk(1));
    end generate g_falling_edge;
  
    g_rising_edge : if (polarity = '1') generate
      output <= (not srl_sysclk(2)) and srl_sysclk(1);
    end generate g_rising_edge;
  end generate g_edge;
  
  g_level : if (level = '1') generate
  begin 
    output <= srl_sysclk(2);
  end generate g_level;
  
  
end architecture behave;

