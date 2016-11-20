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
           start_monpro : in STD_LOGIC;
           start_blakley : in STD_LOGIC;
           monpro_done : out STD_LOGIC;
           blakley_done : out STD_LOGIC;
           output_result : in STD_LOGIC_VECTOR (3 downto 0)
         );
           -- TODO: add control signals from state machine
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
        start => start_monpro,
        done => monpro_done
    );
    
load_registers : process (clk, reset_n)
begin
    if (reset_n = '0') then -- Reset all registers to known default values
        key_n <= (others => '0');
        key_e <= (others => '0');
        message <= (others => '0');
        --operand_a <= (others => '0');
        --operand_b <= (others => '0');
        message_chunk_ret <= (others => '0');
        m_inverse <= (others => '0');
        x_inverse <= (others => '0');
        monpro_result <= (others => '0');
        blakley_result <= (others => '0');
    elsif (clk'event AND clk = '1') then
        --
        case (load_msg) is
        when "1000" =>
            message((127-32*0) downto (32*3)) <= data_in;
        when "0100" =>
            message((127-32*1) downto (32*2)) <= data_in;
        when "0010" =>
            message((127-32*2) downto (32*1)) <= data_in;
        when "0001" =>
            message((127-32*3) downto (32*0)) <= data_in;
        when others =>
            message <= message;
        end case;
        case (load_key_n) is
        when "1000" =>
            key_n((127-32*0) downto (32*3)) <= data_in;
        when "0100" =>
            key_n((127-32*1) downto (32*2)) <= data_in;
        when "0010" =>
            key_n((127-32*2) downto (32*1)) <= data_in;
        when "0001" =>
            key_n((127-32*3) downto (32*0)) <= data_in;
        when others =>
            key_n <= key_n;
        end case;
        case (load_key_e) is
        when "1000" =>
            key_e((127-32*0) downto (32*3)) <= data_in;
        when "0100" =>
            key_e((127-32*1) downto (32*2)) <= data_in;
        when "0010" =>
            key_e((127-32*2) downto (32*1)) <= data_in;
        when "0001" =>
            key_e((127-32*3) downto (32*0)) <= data_in;
        when others =>
            key_e <= key_e;
        end case;
        case (output_result) is
        when "1000" =>
            data_out <= message_chunk_ret((127-32*0) downto (32*3));
        when "0100" =>
            data_out <= message_chunk_ret((127-32*1) downto (32*2));
        when "0010" =>
            data_out <= message_chunk_ret((127-32*2) downto (32*1));
        when "0001" =>
            data_out <= message_chunk_ret((127-32*3) downto (32*0));
        when others =>
            data_out <= (others => '0');
        end case;

    end if;
end process;

--arithmetics : entity work.ALU
--        port map (
--            operand_a => operand_a,
--            operand_b => operand_b,
--            result => message_chunk_ret,
--            sub_sel => operation_sel
--        );
end Behavioral;
