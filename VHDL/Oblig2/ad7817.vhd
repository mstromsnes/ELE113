-- AD7917 simple model
-- Fixed datapatterns
-- Fixed timing parameters for delivered timing
-- No setup/hold checks for input signals

-- Rev1 19sep2016 SvHa
--

library ieee  ; 
use ieee.std_logic_1164.all  ; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity AD7817 is 
port(
   SCLK           :IN   std_logic;
   MOSI           :IN   std_logic;
   MISO           :OUT  std_logic;
   CS_N           :IN   std_logic;
   WR_N           :IN   std_logic;
   CONVST_N       :IN   std_logic;  
   BUSY           :OUT  std_logic;
   OTI_N          :OUT  std_logic   --not used.
);
end entity AD7817;

architecture BEHAV of AD7817 is
    
   -- internal signals
   
   signal SHIFT_DATA_OUT   : std_logic_vector(9 downto 0) := (others => '0');
   signal SHIFT_DATA_IN    : std_logic_vector(7 downto 0) := (others => '0');
   signal BIT_CNT          : integer range 0 to 9 := 9;
   signal MISO_INT         : std_logic;

   begin 
      
   -- input shift register, receive address
   pSHIFT_DATA_IN: process(SCLK)
   begin
      if(rising_edge(SCLK)) then
         if(CS_N = '0' and WR_N = '0') then
            SHIFT_DATA_IN <= SHIFT_DATA_IN(6 downto 0) & MOSI;
         end if;
      end if;
   end process pSHIFT_DATA_IN;
   
   -- select ADC output according to received address
   -- will deliver fixed values according to written byte
   -- if value is different from 6 valid only zeroes will be shifted out
   
   pDATA_OUT: process(SHIFT_DATA_IN)
	begin
   case SHIFT_DATA_IN is
      when x"00"  => SHIFT_DATA_OUT <= "0000010000"; -- 16
      when x"01"  => SHIFT_DATA_OUT <= "0000100001"; -- 33
      when x"02"  => SHIFT_DATA_OUT <= "0000110010"; -- 50
      when x"03"  => SHIFT_DATA_OUT <= "0001000011"; -- 67
      when x"04"  => SHIFT_DATA_OUT <= "0001010100"; -- 84
      when x"07"  => SHIFT_DATA_OUT <= "0010000111"; -- 135
      when others => SHIFT_DATA_OUT <= "0000000000";
   end case;
   end process pDATA_OUT;
   
     
   -- output shift register
   pSHIFT_DATA_OUT: process(SCLK)
   begin
      if(falling_edge(SCLK)) then
         if(CS_N = '0' and WR_N = '1') then
            MISO_INT <= SHIFT_DATA_OUT(BIT_CNT);
				if BIT_CNT = 0 then
				   BIT_CNT <= 9;
				else
					BIT_CNT <= BIT_CNT - 1; 
				end if;	
         end if;
						
      end if;  
   end process pSHIFT_DATA_OUT;
   
   MISO <= MISO_INT when (CS_N = '0') and (WR_N = '1') else 'Z';
   
   pBUSY: process
   begin
		BUSY <= '0';
      wait until falling_edge(CONVST_N);
      wait for 50 ns;
      BUSY <= '1';
      wait for 1000 ns; --in real it's 27us to complete one conversion.
      BUSY <= '0';
   end process pBUSY;
   
end architecture BEHAV;