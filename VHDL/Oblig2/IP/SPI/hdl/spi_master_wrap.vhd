library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity spi_master_wrap is
	port(
		clk : 	IN std_logic;
		reset_n   : in  std_logic;
		cs_n : 		IN std_logic;
		addr : 		IN std_logic_vector(3 downto 0);
		write_n : 	IN std_logic;
		read_n : 	IN std_logic;
		din : 		IN std_logic_vector(31 DOWNTO 0);
		dout : 		OUT std_logic_vector(31 DOWNTO 0);
		
			--external interface
		
		AD7817_MISO         : in  std_logic; --GPIO1
		AD7817_MOSI         : out std_logic; --GPIO3
		AD7817_SCLK         : out std_logic; --GPIO5
		AD7817_WR_N         : out std_logic; --GPIO7
		AD7817_CONVST_N     : out std_logic; --GPIO9
		AD7817_BUSY         : in  std_logic; --GPIO11
		AD7817_OTI_N        : in  std_logic; --GPIO13
		AD7817_CS_N         : out std_logic);--GPIO15
	end entity spi_master_wrap;
		
Architecture wrap_rtl of spi_master_wrap is


	-- Registers
	signal reset_reg			: std_logic_vector(31 downto 0);	-- WR*
	signal oneshot_reg			: std_logic_vector(31 downto 0);	-- WR*
	signal control_status_reg	: std_logic_vector(31 downto 0);	-- RD/WR
	signal temperature_reg		: std_logic_vector(31 downto 0);	-- RD
	signal channel1_reg			: std_logic_vector(31 downto 0);	-- RD
	signal channel2_reg			: std_logic_vector(31 downto 0);	-- RD
	signal channel3_reg			: std_logic_vector(31 downto 0);	-- RD
	signal channel4_reg			: std_logic_vector(31 downto 0);	-- RD
	signal reference_reg		: std_logic_vector(31 downto 0);	-- RD
	signal version_reg			: std_logic_vector(31 downto 0);	-- RD
	
	signal TEMP					: std_logic_vector(9 downto 0);
	signal AI1					: std_logic_vector(9 downto 0);
	signal AI2					: std_logic_vector(9 downto 0);
	signal AI3					: std_logic_vector(9 downto 0);
	signal AI4					: std_logic_vector(9 downto 0);
	signal REFERENCE			: std_logic_vector(9 downto 0);
	signal SPI_BUSY				: std_logic;
		
	-- Hardware Component
	component spi_master
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
	end component spi_master;
	
	begin
	-- Define Write Decode and registers
	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET_N = '0' then
				reset_reg    		<= (others => '0');
				oneshot_reg  		<= (others => '0');
				control_status_reg	<= (others => '0');
				temperature_reg 	<= (others => '0');
				channel1_reg 		<= (others => '0');
				channel2_reg 		<= (others => '0');
				channel3_reg 		<= (others => '0');
				channel4_reg 		<= (others => '0');
				reference_reg 		<= (others => '0');
				version_reg			<= X"00000001";
				
			elsif WRITE_N = '0' and CS_N = '0' then
				case ADDR is
					when X"0" => reset_reg <= DIN;
					when X"1" => oneshot_reg <= DIN;
					when X"2" => control_status_reg <= DIN;
					when others => null;	
				end case;   
			else
			   reset_reg <= (others => '0'); -- No storage, only pulse
			   oneshot_reg <= (others => '0'); -- No storage, only pulse
			   temperature_reg(9 downto 0) <= TEMP;
			   channel1_reg(9 downto 0) <= AI1;
			   channel2_reg(9 downto 0) <= AI2;
			   channel3_reg(9 downto 0) <= AI3;
			   channel4_reg(9 downto 0) <= AI4;
			   reference_reg(9 downto 0) <= REFERENCE;
			   control_status_reg(1) <= SPI_BUSY;
			end if;
		end if;	
	end process; 

		

	-- Define Read Mux 
	process(ADDR, CS_N, read_n)
	begin
	   if READ_N = '0' and CS_N = '0' then
			case ADDR is
				when X"2" => DOUT <= Control_status_reg;
				when X"3" => DOUT <= temperature_reg;
				when X"4" => DOUT <= channel1_reg;
				when X"5" => DOUT <= channel2_reg; 
				when X"6" => DOUT <= channel3_reg; 
				when X"7" => DOUT <= channel4_reg; 
				when X"8" => DOUT <= reference_reg; 
				when X"9" => DOUT <= version_reg; 
				
				when others => DOUT <= (others => '0');
			end case;
		end if;
	end process;
	

	
		
	spi_master_component : spi_master
		port map(
			CLK => clk,
			RESET => reset_reg(0),
			ONESHOT => oneshot_reg(0),
			CONTINOUS => control_status_reg(0),
			TEMP => TEMP,
			AI1 => AI1,
			AI2 => AI2,
			AI3 => AI3,
			AI4 => AI4,
			REFERENCE => REFERENCE,
			SPI_BUSY => SPI_BUSY,
		  --	for SPI bus interface, from ELE113_Mandatory1:
			sclk		=> AD7817_SCLK,    
			mosi		=> AD7817_MOSI,
			miso		=> AD7817_MISO,   
			cs_n		=> AD7817_CS_N,
			wr_n		=> AD7817_WR_N, 
			convst_n	=> AD7817_CONVST_N,
			busy		=> AD7817_BUSY,
			oti_n		=> AD7817_OTI_N);
	
	
end wrap_rtl;
	