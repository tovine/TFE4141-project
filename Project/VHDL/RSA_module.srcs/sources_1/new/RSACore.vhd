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
    signal output_result : STD_LOGIC_VECTOR (3 downto 0);
    signal start_monpro : STD_LOGIC;
    signal start_blakley : STD_LOGIC;
    signal blakley_done : STD_LOGIC;
    signal monpro_done : STD_LOGIC;
        
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
        start_monpro => start_monpro,
        start_blakley => start_blakley,
        output_result => output_result,
        monpro_done => monpro_done,
        blakley_done => blakley_done
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
        start_monpro => start_monpro,
        start_blakley => start_blakley,
        monpro_done => monpro_done,
        blakley_done => blakley_done,
        output_result => output_result
    );
end Behavioral;
