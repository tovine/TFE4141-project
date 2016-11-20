----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2016 21:09:23
-- Design Name: 
-- Module Name: Datapath - Behavioral
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

entity Datapath is
    -- TODO: make global (or at least up to the Datapath), currently also defined in ALU.vhd
    generic (
        ADDER_WIDTH : integer := 128 -- 32
    );

    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (31 downto 0);
           data_out : out STD_LOGIC_VECTOR (31 downto 0);
           load_msg : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_n : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_e : in STD_LOGIC_VECTOR (3 downto 0);
           load_blakley_to_m_inverse : in STD_LOGIC;
           start_monpro : in STD_LOGIC;
           start_blakley : in STD_LOGIC;
           monpro_done : out STD_LOGIC;
           blakley_done : out STD_LOGIC;
           output_result : in STD_LOGIC_VECTOR (3 downto 0)
         );
end Datapath;

architecture Behavioral of Datapath is
    signal key_n : STD_LOGIC_VECTOR (127 downto 0);
    signal key_e : STD_LOGIC_VECTOR (127 downto 0);
    signal message : STD_LOGIC_VECTOR (127 downto 0);
    signal operand_a : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
    signal operand_b : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
    signal message_chunk_ret : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
    signal m_inverse : STD_LOGIC_VECTOR (127 downto 0);
    signal x_inverse : STD_LOGIC_VECTOR (127 downto 0);
    signal monpro_result : STD_LOGIC_VECTOR (127 downto 0);
    signal blakley_result : STD_LOGIC_VECTOR (127 downto 0);
begin
monpro : entity work.monpro
    port map(
        a => operand_a,
        b => operand_b,
        n => key_n,
        result => monpro_result,
        clk => clk,
        reset_n => reset_n,
        start => start_monpro,
        done => monpro_done
    );
    
blakley : entity work.blakley
    port map(
        a => operand_a,
        b => operand_b,
        n => key_n,
        p => blakley_result,
        clk => clk,
        reset_n => reset_n,
        start => start_blakley,
        done => blakley_done
    );

-- *************************************************************
-- Register declarations follow    
-- *************************************************************
-- Message registers
reg_msg0 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg(0),
        d => data_in,
        q => message(31 downto 0)
    );
    
reg_msg1 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg(1),
        d => data_in,
        q => message(63 downto 32)
    );

reg_msg2 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg(2),
        d => data_in,
        q => message(95 downto 64)
    );
    
reg_msg3 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg(3),
        d => data_in,
        q => message(127 downto 96)
    );
    
-- Key_n registers
reg_key_n0 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_n(0),
        d => data_in,
        q => key_n(31 downto 0)
    );
    
reg_key_n1 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_n(1),
        d => data_in,
        q => key_n(63 downto 32)
    );

reg_key_n2 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_n(2),
        d => data_in,
        q => key_n(95 downto 64)
    );
    
reg_key_n3 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_n(3),
        d => data_in,
        q => key_n(127 downto 96)
    );

-- Key_e registers
reg_key_e0 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_e(0),
        d => data_in,
        q => key_e(31 downto 0)
    );
    
reg_key_e1 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_e(1),
        d => data_in,
        q => key_e(63 downto 32)
    );

reg_key_e2 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_e(2),
        d => data_in,
        q => key_e(95 downto 64)
    );
    
reg_key_e3 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_key_e(3),
        d => data_in,
        q => key_e(127 downto 96)
    );

--load_registers : process (clk, reset_n)
--begin
--    if (reset_n = '0') then -- Reset all registers to known default values
--        key_n <= (others => '0');
--        key_e <= (others => '0');
--        message_reg <= (others => '0');
--        --operand_a <= (others => '0');
--        --operand_b <= (others => '0');
--        message_chunk_ret <= (others => '0');
--        m_inverse <= (others => '0');
--        x_inverse <= (others => '0');
--        monpro_result <= (others => '0');
--        blakley_result <= (others => '0');
--    elsif (clk'event AND clk = '1') then
--        --Load the various registers based on the incoming control signals
----        case (load_msg) is -- message
----        when "1000" =>
----        if (load_msg = "1XXX") then
----            message((127-32*0) downto (32*3)) <= data_in;
----        elsif (load_msg = "X1XX") then
------        when "0100" =>
----            message((127-32*1) downto (32*2)) <= data_in;
----        elsif (load_msg = "XX1X") then
------        when "0010" =>
----            message((127-32*2) downto (32*1)) <= data_in;
----        elsif (load_msg = "XXX1") then
------        when "0001" =>
----            message((127-32*3) downto (32*0)) <= data_in;
----        else
------        when others =>
----            message <= message;
------        end case;
----        end if;
----        case (load_key_n) is -- key_n
----        when "1000" =>
----            key_n((127-32*0) downto (32*3)) <= data_in;
----        when "0100" =>
----            key_n((127-32*1) downto (32*2)) <= data_in;
----        when "0010" =>
----            key_n((127-32*2) downto (32*1)) <= data_in;
----        when "0001" =>
----            key_n((127-32*3) downto (32*0)) <= data_in;
----        when others =>
----            key_n <= key_n;
----        end case;
--        case (load_key_e) is -- key_e
--        when "1000" =>
--            key_e((127-32*0) downto (32*3)) <= data_in;
--        when "0100" =>
--            key_e((127-32*1) downto (32*2)) <= data_in;
--        when "0010" =>
--            key_e((127-32*2) downto (32*1)) <= data_in;
--        when "0001" =>
--            key_e((127-32*3) downto (32*0)) <= data_in;
--        when others =>
--            key_e <= key_e;
--        end case;
--        case (output_result) is -- result chunk to output
--        when "1000" =>
--            data_out <= message_chunk_ret((127-32*0) downto (32*3));
--        when "0100" =>
--            data_out <= message_chunk_ret((127-32*1) downto (32*2));
--        when "0010" =>
--            data_out <= message_chunk_ret((127-32*2) downto (32*1));
--        when "0001" =>
--            data_out <= message_chunk_ret((127-32*3) downto (32*0));
--        when others =>
--            data_out <= (others => '0');
--        end case;
--        -- Load the result of blakley
--        if (load_blakley_to_m_inverse = '1') then
--            m_inverse <= blakley_result;
--        end if; 

--    end if;
--end process;

--arithmetics : entity work.ALU
--        port map (
--            operand_a => operand_a,
--            operand_b => operand_b,
--            result => message_chunk_ret,
--            sub_sel => operation_sel
--        );
end Behavioral;
