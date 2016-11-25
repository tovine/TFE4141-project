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

    Port ( b : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           n : in STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           p : out STD_LOGIC_VECTOR (OPERAND_WIDTH-1 downto 0);
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           start : in STD_LOGIC;
           done : out STD_LOGIC);
end blakley;

architecture Behavioral of blakley is
    signal counter: INTEGER range 0 to 255;-- (7 downto 0);
    signal running: std_logic;
begin

    process(clk, reset_n, start, running)
        variable p_tmp : STD_LOGIC_VECTOR (OPERAND_WIDTH downto 0);
    begin
        if (reset_n = '0') then
            running <= '0';
            p_tmp := (others => '0');
            done <= '0';
        elsif (start = '1' AND running = '0') then
            running <= '1';
            done <= '0';
            counter <= 0;
        end if;
        if (running = '1' AND clk'EVENT AND clk='1') then
            if (counter = OPERAND_WIDTH+1) then    
                done <= '1';
                counter <= 0;
                running <= '0';
            else
                p_tmp := p_tmp(OPERAND_WIDTH-1 DOWNTO 0) & "0";
                if (counter = 0) then -- 2^128 means only the MSb is '1'
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
        p <= p_tmp(OPERAND_WIDTH-1 downto 0);
    end process;
    
end Behavioral;
