library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

Architecture behavior of SPI_MASTER is 


	
	type state_type is (idle,send_address,wait_for_400ns,wait_for_reply,recieve_message, store_message);
	signal state: state_type := idle;
	
	signal address_counter : integer range 0 to 10 := 0;
	signal output_counter : integer range 0 to 5 := 0;
	signal address : std_logic_vector(7 downto 0);
	signal shift_data_in : std_logic_vector(9 downto 0) := (others => '0');
	
	signal BUSY_r, BUSY_rr, MISO_r, MISO_rr : std_logic;
	signal CONVST_N_r, CONVST_N_rr : std_logic := '1';
	signal SCLK_r, SCLK_rr, SPI_BUSY_r, CS_N_r, WR_N_r : std_logic := '0';
	
	signal count400ns : integer range 0 to 20 := 0;
	
	
	
	--Counter
	Signal count250: integer range 0 to 250:= 0;


	
	begin
	SCLK <= SCLK_r;
	SPI_BUSY <= SPI_BUSY_r;
	CS_N <= CS_N_r;
	WR_N <= WR_N_r;
	CONVST_N <= CONVST_N_r;
		
	synchronize_inputs: process(CLK)
		begin
			if rising_edge(CLK) then
				BUSY_r <= BUSY;
				BUSY_rr <= BUSY_r;
				MISO_r <= MISO;
				MISO_rr <= MISO_r;
			end if;
		end process;
		
	valid_addresses : process(CLK)
		begin
			if rising_edge(CLK) then
				case output_counter is
					when 0 =>	address <= x"00";
					when 1 =>	address <= x"01";
					when 2 =>	address <= x"02";
					when 3 =>	address <= x"03";
					when 4 =>	address <= x"04";
					when 5 =>	address <= x"07";
				end case;
			end if;
		end process;
	
	register_sclk : process(CLK)
		begin
			if rising_edge(CLK) then
				SCLK_rr <= SCLK_r;
			end if;
		end process;
		
	spi_control_state: process(CLK)
		begin
			if rising_edge(CLK) then
				if RESET = '1' then
					state <= idle;
					CS_N_r <= '1';
					WR_N_r <= '1';
					CONVST_N_r <= '1';
					SPI_BUSY_r <= '0';
					SCLK_r <= '0';
				end if;
				case state is
					when idle =>
						
						-- Control signals
						CS_N_r <= '1';
						WR_N_r <= '1';
						CONVST_N_r <= '1';
						SPI_BUSY_r <= '0';
						SCLK_r <= '1';

						
						-- Next state condition
						if ONESHOT = '1' or CONTINOUS = '1' then
							state <= send_address;
						end if;
						
					when send_address =>
						
						-- Control signals
						CS_N_r <= '0';
						WR_N_r <= '0';
						
						
						-- SCLK counter
						if count250 < 249 then
							count250<= count250 +1;
						elsif count250 = 249 then
							count250 <= 0;
							SCLK_r <= not SCLK_r;
						end if;
						
						-- Next state condition
						if address_counter = 8 and SCLK_r = '1' and SCLK_rr = '0' then
							state <= wait_for_400ns;
						end if;
						
					when wait_for_400ns =>
						
						-- Counter for 400ns
						convst_n_rr <= convst_n_r;
						if count400ns < 20 then
							count400ns <= count400ns + 1;
						else
							convst_n_r <= '0';
							
						end if;
						if convst_n_rr = '0' then
							convst_n_r <= '1';
							count400ns <= 0;
						end if;					
						-- Next state condition
						if BUSY_rr = '1' and convst_n_r = '1' then
							state <= wait_for_reply;
						end if;
						
					when wait_for_reply =>
						
						-- Control signals
						CS_N_r <= '1';
						WR_N_r <= '1';
						if CS_N_r = '1' then
							SCLK_r <= '1';
						end if;

						count400ns <= 0;
					
						-- Next state condition
						if BUSY_rr = '0' then
							state <= recieve_message;
						end if;
						
					when recieve_message =>
						
						-- Control signals						
						WR_N_r <= '1';
						CS_N_r <= '0';
						SPI_BUSY_r <= '1';			
						
						-- SCLK counter
						if count250 < 249 then
							count250<= count250 +1;
						elsif count250 = 249 then
							count250 <= 0;
							SCLK_r <= not SCLK_r;
						end if;
						
						-- Next state condition
						if address_counter = 10 then
							state <= store_message;
						end if;
						
					when store_message =>
						-- Control signals
						WR_N_r <= '1';
						CS_N_r <= '1';
						SPI_BUSY_r <= '0';
						-- Next state condition
						if continous = '1' or output_counter < 5 then
							state <= send_address;
						else
							state <= idle;
						end if;
				end case;
			end if;
		end process;
	
	spi_work_state: process(CLK)
		begin
			if rising_edge(CLK) then
				case state is
					when idle =>
						MOSI <= 'Z';
					when send_address =>

						if SCLK_r = '0' and SCLK_rr = '1' then
							address_counter <= address_counter + 1;
							MOSI <= address(7-address_counter);
						end if;

					
					when wait_for_400ns =>
						-- The low SCLK makes this pretty irrelevant, but keeping this will allow us to speed up SCLK later and doesn't make much impact on low speeds
						
							
						
					when wait_for_reply =>
						address_counter <= 0;
						MOSI <= 'Z';
						
					when recieve_message =>
									
						if SCLK_r = '1' and SCLK_rr = '0' then
							shift_data_in <= shift_data_in(8 downto 0) & miso_rr;
							address_counter <= address_counter + 1;
						end if;
					
					when store_message =>
						
						address_counter <= 0;
						case output_counter is
							when 0 =>	
								TEMP <= shift_data_in;
								output_counter <= 1;
							when 1 =>	
								AI1 <= shift_data_in;
								output_counter <= 2;
							when 2 =>	
								AI2 <= shift_data_in;
								output_counter <= 3;
							when 3 =>	
								AI3 <= shift_data_in;
								output_counter <= 4;
							when 4 =>	
								AI4 <= shift_data_in;
								output_counter <= 5;
							when 5 =>	
								REFERENCE <= shift_data_in;
								output_counter <= 0;
						end case;
				end case;
			end if;
		end process;
	END;
		