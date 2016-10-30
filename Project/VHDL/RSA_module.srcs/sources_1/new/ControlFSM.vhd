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
           load_msg : out STD_LOGIC_VECTOR (3 downto 0);
           load_key_n : out STD_LOGIC_VECTOR (3 downto 0);
           load_key_e : out STD_LOGIC_VECTOR (3 downto 0);
           operation_sel : out STD_LOGIC);
end ControlFSM;

architecture Behavioral of ControlFSM is

begin


end Behavioral;
