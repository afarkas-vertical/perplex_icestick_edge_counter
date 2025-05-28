library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;
        data_in             : in    std_logic_vector(23 downto 0);
        tx_start            : in    std_logic;
        rx                  : in    std_logic;
        tx                  : out   std_logic;
        busy                : out   std_logic
    );
end entity;

architecture Behavioral of uart_tx is
    constant BAUD_DIV : integer := 1250; -- 12 MHz / 9600 baud
    signal baud_cnt   : integer range 0 to BAUD_DIV-1 := 0;
    signal bit_cnt    : integer range 0 to 23 := 0;
    signal shift_reg  : std_logic_vector(29 downto 0) := (others => '1');
    signal sending    : std_logic := '0';
    signal tx_reg     : std_logic := '1';

    begin

        process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    baud_cnt    <= 0;
                    bit_cnt     <= 0;
                    sending     <= '0';
                    shift_reg   <= (others => '1');
                    tx_reg      <= '1';
                else
                    if sending = '0' then
                        if tx_start = '1' then
                            shift_reg <= -- startbit + data + stopbit
				'0' & data_in(7 downto 0) & '1' & 
    				'0' & data_in(15 downto 8) & '1' & 
    				'0' & data_in(23 downto 16) & '1';

				bit_cnt     <= 0;
                        	sending     <= '1';
                           	baud_cnt    <= 0;
                        end if;
                    else
                        if baud_cnt = BAUD_DIV-1 then
                            baud_cnt    <= 0;
                            tx_reg      <= shift_reg(0);
                            shift_reg   <= '1' & shift_reg(29 downto 1);
                            bit_cnt     <= bit_cnt + 1;
                            if bit_cnt = 29 then
                                sending <= '0';
                            end if;
                        else
                            baud_cnt    <= baud_cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end process;

        tx <= tx_reg;
        busy <= sending;
        -- loopback
        rx <= tx

end architecture;