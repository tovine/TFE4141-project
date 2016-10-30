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
        ADDER_WIDTH : integer := 32
    );

    Port ( data_in : in STD_LOGIC_VECTOR (31 downto 0);
           data_out : out STD_LOGIC_VECTOR (31 downto 0);
           load_msg : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_n : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_e : in STD_LOGIC_VECTOR (3 downto 0);
           operation_sel : in STD_LOGIC
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
begin
arithmetics : entity work.ALU
        port map (
            operand_a => operand_a,
            operand_b => operand_b,
            result => message_chunk_ret,
            sub_sel => operation_sel
        );
end Behavioral;
