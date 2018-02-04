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

use ieee.numeric_std.all;

--library common_work;
--ibrary _work;

-- entity declaration of testbench

entity TB_SPI_MASTER_WRAP is
end TB_SPI_MASTER_WRAP;

-- behavoiural decription of testbench

architecture BEHAV of TB_SPI_MASTER_WRAP is

-- SPI_MASTER Component Declaration

component SPI_MASTER_WRAP is
   port
   (
		clk		: IN std_logic;
		reset_n	: IN  std_logic;
		cs_n 	: IN std_logic;
		addr 	: IN std_logic_vector(3 downto 0);
		write_n : IN std_logic;
		read_n 	: IN std_logic;
		din 	: IN std_logic_vector(31 DOWNTO 0);
		dout 	: OUT std_logic_vector(31 DOWNTO 0);
		
			--external interface
		
		AD7817_MISO         : in  std_logic; --GPIO1
		AD7817_MOSI         : out std_logic; --GPIO3
		AD7817_SCLK         : out std_logic; --GPIO5
		AD7817_WR_N         : out std_logic; --GPIO7
		AD7817_CONVST_N     : out std_logic; --GPIO9
		AD7817_BUSY         : in  std_logic; --GPIO11
		AD7817_OTI_N        : in  std_logic; --GPIO13
		AD7817_CS_N         : out std_logic --GPIO15
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

-- Register Addresses

constant RESET		: integer := 0;
constant ONESHOT	: integer := 1;
constant CONTROL	: integer := 2;
constant TEMP		: integer := 3;
constant CHAN1		: integer := 4;
constant CHAN2		: integer := 5;
constant CHAN3		: integer := 6;
constant CHAN4		: integer := 7;
constant REF		: integer := 8;
constant VERSION	: integer := 9;

-- SPI_MASTER_WRAP Input Signals

signal CLK		: std_logic := '0';
signal reset_n	: std_logic := '1';
signal addr		: std_logic_vector(3 downto 0) := (others => '0');
signal write_n	: std_logic := '1';
signal read_n	: std_logic := '1';
signal cs_n		: std_logic := '1';
signal din		: std_logic_vector(31 downto 0) := (others => '0');

-- SPI_MASTER_WRAP Output Signals

signal dout		: std_logic_vector(31 downto 0);

-- SPI_MASTER_WRAP External Signals

signal AD7817_MISO		: std_logic;
signal AD7817_MOSI		: std_logic;
signal AD7817_SCLK		: std_logic;
signal AD7817_WR_N		: std_logic;
signal AD7817_CONVST_N	: std_logic;
signal AD7817_BUSY		: std_logic;
signal AD7817_OTI_N		: std_logic;
signal AD7817_CS_N		: std_logic;

-- Read and Write Procedures

procedure WRITE_REG(
	ADDRESS	: in integer;
	WRITE_VALUE	: in integer;
	signal DIN	: out std_logic_vector(31 downto 0);
	signal DOUT	: in std_logic_vector(31 downto 0);
	signal ADDR : out std_logic_vector(3 downto 0);
	signal CS_N	: out std_logic;
	signal WRITE_N	: out std_logic;
	signal READ_N :	out std_logic
		) is
	
	variable buf: LINE;
begin

	READ_N <= '1';
	WRITE_N <= '0';
	DIN <= std_logic_vector(to_unsigned(WRITE_VALUE,32));
	ADDR <= std_logic_vector(to_unsigned(ADDRESS,4));
	wait for T;
	CS_N <= '0';
	wait for T;
	CS_N <= '1';
	wait for T;
	DIN <= (others => '0');
	ADDR <= (others => '0');
	WRITE_N <= '1';
	write(buf, Vector);
	write(buf, string'(" T: Write Reg Addr: "));
	write(buf, ADDRESS);
	write(buf, string'(" Data: "));
	write(buf, WRITE_VALUE);
	writeline(OUTPUT,buf);
end WRITE_REG;

procedure READ_REG (

	ADDRESS : in integer;
	EXP_VALUE : in integer;
	signal DIN: out std_logic_vector(31 downto 0);
	signal DOUT : in std_logic_vector(31 downto 0);
	signal ADDR : out std_logic_vector(3 downto 0);
	signal CS_N : out std_logic;
	signal WRITE_N : out std_logic;
	signal READ_N : out std_logic
	
	) is
	variable buf : LINE;
	variable READ_VALUE: integer;
	
begin

		CS_N <= '1';
		WRITE_N <= '1';
		READ_N <= '0';
		DIN <= (others => '0');
		ADDR <= std_logic_vector(to_unsigned(ADDRESS,4));
	wait for T;
		CS_N <= '0';
	wait for T;
		CS_N <= '1';
		READ_VALUE := to_integer(unsigned(DOUT));
	wait for T;
		DIN <= (others => '0');
		ADDR <= (others => '0');
		READ_N <= '1';
		write(buf, Vector);
		write(buf, string'(" T: Read Reg Addr: "));
		write(buf, ADDRESS);
		write(buf, string'(" Data: "));
		write(buf, READ_VALUE);
		write(buf, string'(" Expected: "));
		write(buf, EXP_VALUE);
		if EXP_VALUE /= READ_VALUE then
			write(buf, string'(" *******ERROR*******"));
		end if;
		writeline(OUTPUT,buf);
end READ_REG;

begin

-- SPI_MASTER Port Map

SPI_MASTER_WRAP0 : SPI_MASTER_WRAP
   port map
   (
   CLK		=> CLK,
   RESET_n	=> RESET_n,
   addr		=> addr,
   write_n	=> write_n,
   read_n	=> read_n,
   cs_n		=> cs_n,
   din		=> din,
   dout		=> dout,
   AD7817_SCLK		=> AD7817_SCLK,
   AD7817_MOSI		=> AD7817_MOSI,
   AD7817_MISO		=> AD7817_MISO,
   AD7817_CS_N		=> AD7817_CS_N,
   AD7817_WR_N		=> AD7817_WR_N,
   AD7817_CONVST_N	=> AD7817_CONVST_N,
   AD7817_BUSY		=> AD7817_BUSY,
   AD7817_OTI_N	=> AD7817_OTI_N
   );

	
	-- AD7817 Port Map

AD78170 : AD7817
   port map
   (
   SCLK		=> AD7817_SCLK,
   MOSI		=> AD7817_MOSI,
   MISO		=> AD7817_MISO,
   CS_N		=> AD7817_CS_N,
   WR_N		=> AD7817_WR_N,
   CONVST_N	=> AD7817_CONVST_N,
   BUSY		=> AD7817_BUSY,
   OTI_N	=> AD7817_OTI_N
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

-- Reset process

reset_process: process
begin
	reset_n <= '0';
	for i in 1 to 2 loop
		wait until clk = '1';
	end loop;
	reset_n <= '1';
	wait;
end process;

-- init process
-- READ_REG(ADDRESS,EXP_VALUE,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N)
-- WRITE_REG(ADDRESS,WRITE_VALUE,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N)
INIT : process
   begin
-- insert your stimuli here !
	-- The SCLK is such that it takes slightly less than 3 ms to read all the inputs.
   wait until reset_n = '1';
	READ_REG (VERSION,1,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N); -- Check the hardcoded version number is as excpected
	READ_REG (TEMP, 0,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N); -- Check that the register is initialized to 0
	WRITE_REG(CONTROL,1,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N); -- Start Continous mode
	wait for 1 ms;							
	READ_REG(CONTROL,3,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);	-- Check that busy is on and continous mode is still set
	wait for 2 ms;											-- Wait until finished reading all registers
	READ_REG (TEMP,16,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);	-- Check that the registers are at their expected testbench values set in AD7817.vhd
	READ_REG (CHAN1,33,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);
	READ_REG (CHAN2,50,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);
	READ_REG (CHAN3,67,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);
	READ_REG (CHAN4,84,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);
	READ_REG (REF,135,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);
	WRITE_REG (CONTROL,0,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);	-- Turn continous mode off
	WRITE_REG (RESET,1,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);		-- Return SPI_MASTER to idle state. Does not reset TEMP\AI etc values
	wait for 1 ms;
	WRITE_REG (ONESHOT,1,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);	-- Wait a bit then turn oneshot mode on
	wait for 1 ms;
	READ_REG(CONTROL,2,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);		-- Check that SPI_MASTER is busy but not in continous mode
	wait for 2 ms;												-- Wait untill finished
	READ_REG(CONTROL,0,DIN,DOUT,ADDR,CS_N,WRITE_N,READ_N);		-- Check that it finished.
	
	
	end process;
-- RESET		: integer := 0;
-- ONESHOT		: integer := 1;
-- CONTROL		: integer := 2;
-- TEMP			: integer := 3;
-- CHAN1		: integer := 4;
-- CHAN2		: integer := 5;
-- CHAN3		: integer := 6;
-- CHAN4		: integer := 7;
-- REF			: integer := 8;
-- VERSION		: integer := 9;
	

end BEHAV;
