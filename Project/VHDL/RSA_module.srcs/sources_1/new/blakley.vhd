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

    Port ( a : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0); -- TODO: not needed, always 2^128
           b : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           n : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           p : out STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           start : in STD_LOGIC;
           done : out STD_LOGIC);
end blakley;

architecture Behavioral of blakley is
    signal counter: INTEGER range 0 to OPERAND_WIDTH;-- (7 downto 0);
    signal running: std_logic;
begin

    process(start) -- simple process to start the blakley operation
    begin
        if (running = '0' AND start = '1') then -- TODO: replace runnig with done?
            running <= '1';
            done <= '0';
        end if;
    end process;
    
    process(clk, reset_n)
        variable should_add : STD_LOGIC;
        variable p_tmp : STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
    begin
        should_add := '0';
        if (reset_n = '0') then
            running <= '0';
            p_tmp := (others => '0');
            counter <= 0;
            done <= '0';
        elsif (running = '1' AND clk'EVENT AND clk='1') then
            if (counter = OPERAND_WIDTH) then    
                done <= '1';
                counter <= 0;
            else
                --p_tmp <= shift_left(p_tmp, std_logic_vector(1));
                p_tmp := p_tmp(OPERAND_WIDTH-2 DOWNTO 0) & "0";
                should_add := a(OPERAND_WIDTH - 1 - counter); -- TODO: can be greatly simplified as a will always be 2^128
                if (should_add = '1') then
                    p_tmp := p_tmp + b;
                end if;
                if ("0" & p_tmp(OPERAND_WIDTH-1 downto 1) > n) then
                    p_tmp := p_tmp - (n(OPERAND_WIDTH-2 downto 0) & "0");
                elsif (p_tmp > n) then
                    p_tmp := p_tmp - n;
                end if;
            
                counter <= counter + 1;
            end if;
        end if;
        p <= p_tmp;
    end process;
    
end Behavioral;
