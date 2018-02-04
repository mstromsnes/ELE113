library ieee;
USE ieee.std_logic_1164.all;

Entity fifo_ms is
	port (
			clk			: in std_logic;
			data_in 	: in std_logic_vector(7 downto 0);
			wr			: in std_logic;
			rd			: in std_logic;
			rst			: in std_logic;
			
			fifo_cnt	: out std_logic_vector(4 downto 0);
			data_out	: out std_logic_vector(7 downto 0);
			full		: out std_logic;
			empty		: out std_logic);
end;

architecture rts of fifo_ms is

