-------------------------------------------------------------------------------
-- Title      : HEX to 7-seg encoder
-- Project    : ELE113 Lab 1
-------------------------------------------------------------------------------
-- File             : $RCSfile: ELE113_lab1.vhd,v $
-- Last edited by   : $Author: alme $
-- Last update      : $Date: 2008/02/05 11:42:01 $
-- Current Revision : $Revision: 1.9 $
-------------------------------------------------------------------------------
-- Description: 
-- Encodes HEX number on the 7-seg displays. 100% combinatorial
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

entity seven_seg_encoder is
  port(
    hex_number     : in  std_logic_vector(3 downto 0);     
    seven_seg_code : out std_logic_vector(6 downto 0)
  );
end seven_seg_encoder;

architecture behave of seven_seg_encoder is
   
begin
  
  -- process p_encoder:
  -- Combinatorial process that encodes HEX numbers onto the 7 segment displays
  p_encoder: process (hex_number) is
  begin
    case (hex_number) is
      when X"0"   => seven_seg_code <= "1000000";
      when X"1"   => seven_seg_code <= "1111001";
      when X"2"   => seven_seg_code <= "0100100";
      when X"3"   => seven_seg_code <= "0110000";
      when X"4"   => seven_seg_code <= "0011001";
      when X"5"   => seven_seg_code <= "0010010";
      when X"6"   => seven_seg_code <= "0000010";
      when X"7"   => seven_seg_code <= "1111000";
      when X"8"   => seven_seg_code <= "0000000";
      when X"9"   => seven_seg_code <= "0011000";
      when X"A"   => seven_seg_code <= "0001000";
      when X"B"   => seven_seg_code <= "0000011";
      when X"C"   => seven_seg_code <= "1000110";
      when X"D"   => seven_seg_code <= "0100001";
      when X"E"   => seven_seg_code <= "0000110";
      when X"F"   => seven_seg_code <= "0001110";
      when others => seven_seg_code <= "1111111"; --no lights on
    end case;    
  end process p_encoder;
end architecture behave;

