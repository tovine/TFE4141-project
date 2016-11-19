----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2016 21:48:36
-- Design Name: 
-- Module Name: ControlFSM - Behavioral
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

entity ControlFSM is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           init_rsa : in STD_LOGIC;
           start_rsa : in STD_LOGIC;
           core_finished : out STD_LOGIC;
           -- Control signals for datapath
           load_msg : out STD_LOGIC_VECTOR (3 downto 0);
           load_key_n : out STD_LOGIC_VECTOR (3 downto 0);
           load_key_e : out STD_LOGIC_VECTOR (3 downto 0);
           output_result : out STD_LOGIC_VECTOR (3 downto 0);
           start_monpro : out STD_LOGIC;
           start_blakley : out STD_LOGIC;
           -- Status inputs from datapath
           monpro_done : in STD_LOGIC;
           blakley_done : in STD_LOGIC
    );

end ControlFSM;

architecture Behavioral of ControlFSM is

begin


end Behavioral;
