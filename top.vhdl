library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		clk_12mhz			: in 	std_logic; 			-- FPGA clock (e.g., 12MHz)
		rst_btn				: in 	std_logic; 			-- Reset signal
		pulse_in				: in 	std_logic; 			-- Input signal from comparator
		uart_tx				: out	std_logic			-- UART TX 
		uart_rx				: in	std_logic			-- UART RX for loopback purposes only
	);
end entity;

architecture Behavioral of top is
	signal pulse_val	: std_logic_vector(23 downto 0) := 0;
	signal pulse_ready	: std_logic := '0';
	signal tx_start		: std_logic := '0';
	signal tx_busy		: std_logic := '0';
	signal last_ready	: std_logic := '0';
	--signal rst_btn		: std_logic := '0';
	signal data_to_send	: std_logic_vector(23 downto 0) := (others => '0');
	

	-- Heartbeat signal
	--signal heartbeat_counter	: unsigned(1 downto 0) := (others => '0');

	begin
		counter_inst: entity work.pulse_width_meter
			port map (
				clk 		=> clk_12mhz,
				rst 		=> rst_btn,
				pulse_in 	=> pulse_in,
				pulse_out	=> pulse_val,
				ready		=> pulse_ready
			);
		
		uart_inst: entity work.uart_tx
			port map (
				clk			=> clk_12mhz,
				rst			=> rst_btn,
				data_in		=> data_to_send,
				tx_start	=> tx_start,
				tx			=> uart_tx,
				rx			=> uart_rx,
				busy		=> tx_busy
			);

		process(clk_12mhz)
		begin
			if rising_edge(clk_12mhz) then
				if rst_btn = '1' then
					tx_start <= '0';
					last_ready <= '0';
					--heartbeat_counter <= (others => '0');
					data_to_send <= (others => '0');
				else
					-- Heartbeat Logic TODO
					--if (heartbeat_counter /= half_hz_rate) = '0' then
					--	heartbeat_counter <= '1'; --Change to high
					--else
					--	heartbeat_counter <= '0'; --Change to low
					--end if;

					-- UART start control
					if tx_busy = '0' then
						if (last_ready = '0' and pulse_ready = '1') then
							tx_start <= '1';
							data_to_send <= pulse_val;
						else
							tx_start <= '0';
						end if;
					end if;

					last_ready <= pulse_ready;

				end if;
			end if;
		end process;

end architecture Behavioral;