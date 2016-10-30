----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.10.2016 21:09:23
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    -- TODO: extract and make global (or at least up to the Datapath)
    generic (
        ADDER_WIDTH : integer := 32
    );

    Port ( operand_a : in STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
           operand_b : in STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
           result : out STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
           sub_sel : in STD_LOGIC); -- Selects operation: 0 = add, 1 = subtract
end ALU;

architecture Behavioral of ALU is

begin


end Behavioral;
