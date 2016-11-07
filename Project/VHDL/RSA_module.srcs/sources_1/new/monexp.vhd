----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2016 13:01:22
-- Design Name: 
-- Module Name: blakley - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blakley is
    generic (OPERAND_WIDTH : integer := 128);

    Port ( a : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           b : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           n : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           p : out STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           done : out STD_LOGIC);
end blakley;

architecture Behavioral of blakley is
    signal counter: INTEGER range 0 to OPERAND_WIDTH := 0;-- (7 downto 0);
    signal p_tmp : STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0); -- TODO: check if it must be 129 bits
    signal should_add : STD_LOGIC;
begin
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            p_tmp <= (others => '0');
            counter <= 0;
            should_add <= a(OPERAND_WIDTH-1);
            done <= '0';
        elsif (clk'EVENT AND clk='1') then
            if (counter = OPERAND_WIDTH) then    
                p <= p_tmp;
                done <= '1';
                counter <= 0;
            else
                --p_tmp <= shift_left(p_tmp, std_logic_vector(1));
                p_tmp <= p_tmp(OPERAND_WIDTH-2 DOWNTO 0) & "0";
                if (should_add = '1') then
                    p_tmp <= p_tmp + b;
                end if;
                if (p_tmp > n) then
                    p_tmp <= p_tmp - n;
                    if (p_tmp > n) then
                      p_tmp <= p_tmp - n;
                    end if;
                end if;
                counter <= counter + 1;
                should_add <= a(OPERAND_WIDTH - 1 - counter);
            end if;
        end if;
        
    end process;
    
end Behavioral;
