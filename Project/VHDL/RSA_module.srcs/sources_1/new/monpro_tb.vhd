----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2016 14:12:22
-- Design Name: 
-- Module Name: blakley_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monpro_tb is
--  Port ( );
    generic( OPERAND_WIDTH : integer := 128);
end monpro_tb;

architecture Behavioral of monpro_tb is

    signal Clk_tb : std_logic:='0';
    signal Reset_n_tb : std_logic:='1';
    signal done : std_logic;
    signal start : std_logic;
    signal a_tb : std_logic_vector(OPERAND_WIDTH-1 downto 0);
    signal b_tb : std_logic_vector(OPERAND_WIDTH-1 downto 0);
    signal n_tb : std_logic_vector(OPERAND_WIDTH-1 downto 0);
    signal p_tb : std_logic_vector(OPERAND_WIDTH-1 downto 0);
    
begin
DUT : entity work.monpro
    port map(
        a => a_tb,
        b => b_tb,
        n => n_tb,
        start => start,
        result => p_tb,
        clk => Clk_tb,
        reset_n => Reset_n_tb,
        done => done
    );
    
    	--Clock process definitions--
    CLKGEN: process is
    begin
        Clk_tb <= '1';
        wait for 10 ns;
        Clk_tb <= '0';
        wait for 10 ns;
    end process;
    
    -- Stimuli generation --
    stim_proc: process
    begin
        Reset_n_tb <='0'; -- TODO: verify that test stimuli makes sense
--                a_tb <= x"00000000000000000000000100000000";
----                b_tb <= x"0000000000000000000000000aaabbbb";
----                n_tb <= x"000000000000000000000000819dc6b2";
--                b_tb <= x"0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
--                n_tb <= x"819DC6B2574E12C3C8BC49CDD79555FD";
            a_tb <= x"7e62394da8b1ed3c3743b632286aaa03";
            b_tb <= x"7e62394da8b1ed3c3743b632286aaa03";
            n_tb <= x"819dc6b2574e12c3c8bc49cdd79555fd";
        wait for 20 ns;
--        a_tb <= "0x0aaabbbb"; -- TODO: find good test stimuli
--        b_tb <= "0x
          Reset_n_tb <= '1';
        wait for 20 ns;
            start <= '1';
        --wait for 20 ns;
          --  start <= '0';
        wait for 20us;
        --wait for done = '1';
        -- Repeat
        --ASSERT 0;
    end process;

end Behavioral;
