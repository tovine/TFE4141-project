----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2016 18:35:49
-- Design Name: 
-- Module Name: monpro - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monpro is

    generic (OPERAND_WIDTH : integer := 128);

    Port ( a : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           b : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           n : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           result : out STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           start : in STD_LOGIC;
           done : out STD_LOGIC);
end monpro;

architecture Behavioral of monpro is
    signal counter: INTEGER range 0 to 255;-- (7 downto 0);
    signal running: std_logic;
    signal result_next: STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
    signal result_now: STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
begin

    result <= result_now;
    
    process (reset_n, clk)
    begin
        if (reset_n = '0') then
            result_now <= (others => '0');
            counter <= 0;
            done <= '0';
        elsif (clk'event AND clk = '1') then
            result_now <= result_next;
            if (counter >= OPERAND_WIDTH) then
                done <= '1';
				counter <= 0;
            elsif (running = '1') then
                counter <= counter + 1;
                done <= '0';
			else
				counter <= 0;
            end if;
        end if;
    end process;

    process(start, result_now, running, a, b, n, counter)
        variable should_add : STD_LOGIC;
        variable result_tmp : STD_LOGIC_VECTOR (OPERAND_WIDTH downto 0);
    begin
		if (counter = 0 AND running = '1') then
			result_tmp := x"00000000000000000000000000000000" & '0';
		else
			result_tmp(OPERAND_WIDTH-1 downto 0) := result_now;
		end if;
        running <= '0';

        if (start = '1' AND running = '0' AND counter = 0) then
            running <= '1';
        end if;
        
        if (running = '1') then
            if (counter >= OPERAND_WIDTH) then -- Done computing, reduce result and return
                if (result_tmp >= n) then
                    result_tmp := result_tmp - n;
                end if;
                running <= '0';
            else
                if (a(counter) = '1') then
                    result_tmp := result_tmp + b;
                end if;
                if (result_tmp(0) = '1') then
                    result_tmp := result_tmp + n;
                end if;
                result_tmp := ("0" & result_tmp(OPERAND_WIDTH downto 1)); -- right shift by one
                running <= '1';
            end if;
        end if;
        result_next <= result_tmp(OPERAND_WIDTH-1 downto 0);
    end process;

end Behavioral;
