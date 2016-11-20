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
           load_m_inverse : out STD_LOGIC; -- TODO: set this signal
           load_x_inverse : out STD_LOGIC; -- TODO: set this signal
           blakley_to_x_inverse : out STD_LOGIC; -- TODO: set this signal
           select_output : out STD_LOGIC_VECTOR (1 downto 0);
           start_monpro : out STD_LOGIC;
           start_blakley : out STD_LOGIC;
           -- Status inputs from datapath
           monpro_done : in STD_LOGIC;
           blakley_done : in STD_LOGIC
    );

end ControlFSM;

architecture Behavioral of ControlFSM is
    type state is (IDLE, LOAD_CONFIG, LOAD_MESSAGE, RUN_BLAKLEY, RUN_MONPRO, OUTPUT_DATA);
    signal curr_state, next_state : state;
    signal substate_counter: integer range 0 to 128;
begin

-- *********************************************************************
-- Things to do in the different states:
-- *********************************************************************
-- LOAD_CONFIG:
--  - load keys n and e
--  - compute x_ (blakley using 2^128, 1 and n)
--  - return to IDLE
-- LOAD_MESSAGE:
--  - Load the message (should take 4 cycles)
--  - compute m_ (blakley using 2^128, message and n)
--  - go to RUN_MONPRO
-- RUN_MONPRO: TODO: rename this state?
--  - Do the following 128 (or 127?) times:
--    - start the monpro block using x_, x_ and n
--    - if (bit i of key_e is 1): run monpro again using m_, x_ and n
--  - start the monpro block using x_, 1 and n
--  - go to OUTPUT_DATA
-- OUTPUT_DATA:
--  - Set core_finished to 1
--  - For 4 clock periods, output a new 32-bit chunk of data
--  - return to IDLE


StateProcess: process (curr_state, init_rsa, start_rsa, monpro_done, blakley_done, reset_n)
begin
    case (curr_state) is
    when IDLE =>
    -- TODO: does all the data-changing parts belong in the clocked process?
        load_msg <= "0000";
        load_key_n <= "0000";
        load_key_e <= "0000";
        select_output <= "00";
        start_monpro <= '0';
        start_blakley <= '0';
        core_finished <= '1';
        if (init_rsa = '1') then
            next_state <= LOAD_CONFIG;
        elsif (start_rsa = '1') then
            next_state <= LOAD_MESSAGE;
        end if;
        
    when LOAD_CONFIG =>
        -- TODO: load all config registers, in sequence KeyN[3..0], KeyE[3..0]
        if (substate_counter = 7) then -- The last register has been loaded
            next_state <= IDLE;
            substate_counter <= 0; -- TODO: must this be done in sync?
        end if;
    when LOAD_MESSAGE =>
        if (substate_counter = 7) then -- The last register has been loaded
            next_state <= RUN_BLAKLEY;
            substate_counter <= 0; -- TODO: must this be done in sync?
        end if;
    when RUN_BLAKLEY =>
        if (blakley_done = '1') then
            next_state <= RUN_MONPRO;
        end if;
    when RUN_MONPRO =>
        if (monpro_done = '1') then
            next_state <= OUTPUT_DATA;
        end if;
    when OUTPUT_DATA =>
        if (substate_counter = 4) then -- TODO: should it be 3 instead?
            next_state <= IDLE;
        end if;
    -- TODO: add 'otherwise' case?
    end case;
end process; 

end Behavioral;
