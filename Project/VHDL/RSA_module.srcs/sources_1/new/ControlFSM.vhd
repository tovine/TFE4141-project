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
           load_m_inverse : out STD_LOGIC;
           load_x_inverse : out STD_LOGIC;
           select_blakley_input : out STD_LOGIC;
           select_monpro_input_1 : out STD_LOGIC;
           select_monpro_input_2 : out STD_LOGIC;
           blakley_to_x_inverse : out STD_LOGIC;
           select_output : out STD_LOGIC_VECTOR (1 downto 0);
           start_monpro : out STD_LOGIC;
           start_blakley : out STD_LOGIC;
           current_e_bit : out INTEGER range 0 to 127;
           -- Status inputs from datapath
           monpro_done : in STD_LOGIC;
           blakley_done : in STD_LOGIC;
           current_e_bit_is_high : in STD_LOGIC
    );

end ControlFSM;

architecture Behavioral of ControlFSM is
    type state is (IDLE, LOAD_CONFIG, LOAD_MESSAGE, RUN_BLAKLEY, RUN_MONPRO, OUTPUT_DATA);
    signal current_state_reg : state;
    signal substate_counter: integer range 0 to 255;
    signal monpro_second_round: std_logic;
    signal increment_substate: std_logic;
    signal clear_substate: std_logic;
begin

StateProcess: process (current_state_reg, init_rsa, start_rsa, monpro_done, blakley_done, substate_counter, reset_n)
    variable current_state, next_state : state;
begin
    current_state := current_state_reg;
    next_state := current_state_reg;
    --if (reset_n = '0') then
    --end if;
    -- Set default values for internal signals
    monpro_second_round <= '0';
    increment_substate <= '0';
    clear_substate <= '0';
    core_finished <= '0';
    -- Set default values for load enable signals
    load_key_e <= "0000";
    load_key_n <= "0000";
    load_msg <= "0000";
    -- Set default value for datapath control signals
    select_blakley_input <= '0';
    start_blakley <= '0';
    blakley_to_x_inverse <= '0';
    load_m_inverse <= '0';
    load_x_inverse <= '0';
    select_monpro_input_1 <= '0';
    select_monpro_input_2 <= '0';
    start_monpro <= '0';
    current_e_bit <= 0;
    select_output <= "00";

    case (current_state_reg) is
    when IDLE =>
        load_msg <= "0000";
        load_key_n <= "0000";
        load_key_e <= "0000";
        select_output <= "00";
        start_monpro <= '0';
        start_blakley <= '0';
        core_finished <= '1';
        clear_substate <= '1';
        if (init_rsa = '1') then
            next_state := LOAD_CONFIG;
            current_state := LOAD_CONFIG;
            increment_substate <= '1';
            load_key_e <= "0001"; -- We need to do it here to save time
            core_finished <= '0';
        elsif (start_rsa = '1') then
            next_state := LOAD_MESSAGE;
            load_msg <= "0001";
            core_finished <= '0';
        else
            next_state := IDLE;
        end if;
    -- /IDLE
    when LOAD_CONFIG =>
        increment_substate <= '1';
        case (substate_counter) is
        when 0 => -- This case is theoretically not needed anymore
            load_key_e <= "0001";
        when 1 =>
            load_key_e <= "0010";
        when 2 =>
            load_key_e <= "0100";
        when 3 =>
            load_key_e <= "1000";
        when 4 =>
            load_key_n <= "0001";
        when 5 =>
            load_key_n <= "0010";
        when 6 =>
            load_key_n <= "0100";
        when 7 =>
            load_key_n <= "1000";
        when 8 =>
            select_blakley_input <= '1';
            start_blakley <= '1';
        when others =>
            select_blakley_input <= '1';
            blakley_to_x_inverse <= '1';
            increment_substate <= '0';
        end case;
        if (blakley_done = '1') then -- The last register has been loaded
            next_state := IDLE;
            clear_substate <= '1';
        else
            next_state := LOAD_CONFIG;
        end if;
    -- /LOAD_CONFIG
    when LOAD_MESSAGE =>
        next_state := LOAD_MESSAGE;
        increment_substate <= '1';
        case (substate_counter) is
        when 0 =>
            load_msg <= "0001";
        when 1 =>
            load_msg <= "0010";
        when 2 =>
            load_msg <= "0100";
        when 3 =>
            load_msg <= "1000";
        when 4 => 
            load_msg <= "0000";
            start_blakley <= '1';
        when others =>
            start_blakley <= '0';
            increment_substate <= '0';
            if (blakley_done = '1') then
                -- Once the first blakley run completes, load the result into the msg registers
                load_m_inverse <= '1';
                next_state := RUN_MONPRO;
            end if;
        end case;
    -- /LOAD_MESSAGE
    when RUN_MONPRO =>
        next_state := RUN_MONPRO;
        current_e_bit <= substate_counter; -- TODO: substate_counter + 1?
        if (substate_counter = 128) then -- TODO: 129 instead?
            select_monpro_input_2 <= '1';
            start_monpro <= '1';
            increment_substate <= '1';
        elsif (monpro_done = '1' AND substate_counter = 129) then -- TODO: 130 instead?
            next_state := OUTPUT_DATA;
        elsif (monpro_done = '1' OR substate_counter = 0) then
            start_monpro <= '1';
            if (monpro_second_round = '1') then -- Run monpro again with m_ as the first argument
                select_monpro_input_1 <= '1';
            else
                if (current_e_bit_is_high = '1' and monpro_second_round = '0') then
                    monpro_second_round <= '1';
                else
                    increment_substate <= '1';
                end if;
            end if;
        end if;
    when OUTPUT_DATA =>
        next_state := OUTPUT_DATA;
        core_finished <= '1';
        increment_substate <= '1';
        case (substate_counter) is
        when 0 =>
            select_output <= "00";
        when 1 =>
            select_output <= "01";
        when 2 =>
            select_output <= "10";
        when 3 =>
            select_output <= "11";
        when others => 
            next_state := IDLE;
        end case;
    when others =>
        -- Should never get here, something's wrong
        next_state := IDLE;
    end case; -- current_state
    if (current_state /= next_state) then -- Make sure to reset the substate counter when changing states
        clear_substate <= '1';
    end if;
    current_state_reg <= next_state;
end process;     
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

-- Process to keep track of incrementing the counter
SynchronousProcess: process(clk, reset_n)
begin
    if (reset_n = '0') then
        substate_counter <= 0;
    elsif (clk'event AND clk = '1') then
        if (increment_substate = '1') then
            substate_counter <= substate_counter + 1;
        end if;
        if (clear_substate = '1') then
            substate_counter <= 0;
        end if;
    end if; -- clk edge
end process;

end Behavioral;
