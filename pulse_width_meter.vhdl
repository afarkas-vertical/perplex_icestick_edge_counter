library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_width_meter is
	port(
		clk 				: in 	std_logic; 						-- FPGA clock (e.g., 100MHz)
		rst 				: in 	std_logic; 						-- Reset signal
		pulse_in			: in 	std_logic; 						-- Input signal from comparator
		pulse_out			: out	std_logic_vector(23 downto 0);
		ready				: out	std_logic
	);
end pulse_width_meter;

architecture Behavioral of pulse_width_meter is
	signal count		: unsigned(23 downto 0) := (others => '0');	-- 24 bit incremental counter
	signal c_width 		: unsigned(23 downto 0) := (others => '0'); -- Final quantized value of count in cycles
	signal pulse_in_d	: std_logic := '0'; 	-- Flag that indicates new measurement is available

	begin
		process(clk)
		begin
			-- Every rising edge, check if there is a pulse on the channel
			if rising_edge(clk) then
				if rst = '1' then
					count <= 0;
					c_width <= 0;
					pulse_in_d <= '0';
				else
					pulse_in_d <= pulse_in; -- pulse_in_d acts as a boolean to begin counting

					-- Increment the count every clock cycle
					if pulse_in_d = '1' then
						count <= count + 1;
					end if;

					-- Check if the pulse falling edge detected
					if pulse_in_d = '1' and pulse_in = '0' then
						c_width <= count; -- Transfer value to output
						count <= 0; -- Reset count
					end if;
				end if;
			end if;

			-- If c_width is higher than 0, then send the pulse value out
			if c_width >= 0 then
				pulse_out <= std_logic_vector(c_width);
				ready <= '1';
			end if;
		end process;
		
end architecture Behavioral;