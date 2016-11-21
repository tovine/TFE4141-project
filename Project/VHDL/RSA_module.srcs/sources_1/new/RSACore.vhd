----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2016 21:09:23
-- Design Name: 
-- Module Name: RSACore - Behavioral
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

entity RSACore is
    Port ( Clk : in STD_LOGIC;
           Resetn : in STD_LOGIC;
           InitRsa : in STD_LOGIC;
           StartRsa : in STD_LOGIC;
           DataIn : in STD_LOGIC_VECTOR (31 downto 0);
           DataOut : out STD_LOGIC_VECTOR (31 downto 0);
           CoreFinished : out STD_LOGIC
    );
end RSACore;

architecture Behavioral of RSACore is
    signal load_msg : STD_LOGIC_VECTOR (3 downto 0);
    signal load_key_n : STD_LOGIC_VECTOR (3 downto 0);
    signal load_key_e : STD_LOGIC_VECTOR (3 downto 0);
    signal select_output : STD_LOGIC_VECTOR (1 downto 0);
    signal start_monpro : STD_LOGIC;
    signal start_blakley : STD_LOGIC;
    signal select_blakley_input : STD_LOGIC;
    signal select_monpro_input_1 : STD_LOGIC;
    signal select_monpro_input_2 : STD_LOGIC;
    signal blakley_done : STD_LOGIC;
    signal monpro_done : STD_LOGIC;
    signal load_m_inverse : STD_LOGIC;
    signal load_x_inverse : STD_LOGIC;
    signal blakley_to_x_inverse : STD_LOGIC;
    signal current_e_bit : INTEGER range 0 to 127;
    signal e_bit_is_high : STD_LOGIC;
        
begin
control: entity work.ControlFSM
    port map (
        clk => Clk,
        reset_n => Resetn,
        init_rsa => InitRsa,
        start_rsa => StartRsa,
        core_finished => CoreFinished,
        load_msg => load_msg,
        load_key_n => load_key_n,
        load_key_e => load_key_e,
        load_m_inverse => load_m_inverse,
        blakley_to_x_inverse => blakley_to_x_inverse,
        select_blakley_input => select_blakley_input,
        select_monpro_input_1 => select_monpro_input_1,
        select_monpro_input_2 => select_monpro_input_2,
        load_x_inverse => load_x_inverse,
        start_monpro => start_monpro,
        start_blakley => start_blakley,
        select_output => select_output,
        current_e_bit => current_e_bit,
        monpro_done => monpro_done,
        blakley_done => blakley_done,
        current_e_bit_is_high => e_bit_is_high
    );

datapath: entity work.Datapath
    port map (
        clk => Clk,
        reset_n => Resetn,
        data_in => DataIn,
        data_out => DataOut,
        load_msg => load_msg,
        load_key_n => load_key_n,
        load_key_e => load_key_e,
        load_blakley_to_msg => load_m_inverse,
        load_blakley_to_x_inverse => blakley_to_x_inverse,
        select_blakley_input => select_blakley_input,
        select_monpro_input_1 => select_monpro_input_1,
        select_monpro_input_2 => select_monpro_input_2,
        current_e_bit => current_e_bit,
        load_x_inverse => load_x_inverse,
        start_monpro => start_monpro,
        start_blakley => start_blakley,
        monpro_done => monpro_done,
        blakley_done => blakley_done,
        key_e_bit_is_high => e_bit_is_high,
        select_output => select_output
    );
end Behavioral;
