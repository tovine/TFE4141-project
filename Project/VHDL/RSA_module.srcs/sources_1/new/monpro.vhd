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
           done : out STD_LOGIC);
end monpro;

architecture Behavioral of monpro is
    signal counter: INTEGER range 0 to OPERAND_WIDTH;-- (7 downto 0);
begin
    process(clk, reset_n)
        variable should_add : STD_LOGIC;
        variable result_tmp : STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
    begin
        should_add := '0';
        if (reset_n = '0') then
            result_tmp := (others => '0');
            counter <= 0;
            done <= '0';
        elsif (clk'event AND clk = '1') then
            if (counter = OPERAND_WIDTH) then -- Done computing, reduce result and return
                if (result_tmp >= n) then
                    result_tmp := result_tmp - n;
                end if;
                done <= '1';
                counter <= 0;
            else
                should_add := a(counter);
                if (should_add = '1') then
                    result_tmp := result_tmp + b;
                end if;
                if (result_tmp(0) = '1') then
                    result_tmp := result_tmp + n;
                end if;
                result_tmp := ("0" & result_tmp(OPERAND_WIDTH-1 downto 1)); -- right shift by one
                counter <= counter + 1;
            end if;
        end if; -- clock edge
        result <= result_tmp(OPERAND_WIDTH-1 downto 0);
    end process;

end Behavioral;
