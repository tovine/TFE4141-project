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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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

    Port ( -- Clock and reset signals
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           -- Data busses
           data_in : in STD_LOGIC_VECTOR (31 downto 0);
           data_out : out STD_LOGIC_VECTOR (31 downto 0);
           -- Control signals from state machine
           load_msg : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_n : in STD_LOGIC_VECTOR (3 downto 0);
           load_key_e : in STD_LOGIC_VECTOR (3 downto 0);
           load_blakley_to_msg : in STD_LOGIC;
           load_blakley_to_x_inverse : in STD_LOGIC;
           select_blakley_input : in STD_LOGIC;
           select_monpro_input_1 : in STD_LOGIC;
           select_monpro_input_2 : in STD_LOGIC;
           load_x_inverse : in STD_LOGIC;
           start_monpro : in STD_LOGIC;
           start_blakley : in STD_LOGIC;
           select_output : in STD_LOGIC_VECTOR (1 downto 0);
           current_e_bit : in INTEGER range 0 to 127;
           -- Status feedback to state machine
           monpro_done : out STD_LOGIC;
           blakley_done : out STD_LOGIC;
           key_e_bit_is_high : out STD_LOGIC
         );
end Datapath;

architecture Behavioral of Datapath is
    signal key_n : STD_LOGIC_VECTOR (127 downto 0);
    signal key_e : STD_LOGIC_VECTOR (127 downto 0);
    signal message : STD_LOGIC_VECTOR (127 downto 0);
    signal msg_0 : STD_LOGIC_VECTOR ( 31 downto 0);
    signal msg_1 : STD_LOGIC_VECTOR ( 31 downto 0);
    signal msg_2 : STD_LOGIC_VECTOR ( 31 downto 0);
    signal msg_3 : STD_LOGIC_VECTOR ( 31 downto 0);
    signal load_msg_0 : STD_LOGIC;
    signal load_msg_1 : STD_LOGIC;
    signal load_msg_2 : STD_LOGIC;
    signal load_msg_3 : STD_LOGIC;
    signal operand_a : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
    signal operand_b : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0); 
    signal blakley_input : STD_LOGIC_VECTOR (127 downto 0);
    
--    signal message_chunk_ret : STD_LOGIC_VECTOR (ADDER_WIDTH-1 downto 0);
    signal x_inverse : STD_LOGIC_VECTOR (127 downto 0);
    signal x_inverse_next : STD_LOGIC_VECTOR (127 downto 0);
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
        b => blakley_input,
        n => key_n,
        p => blakley_result,
        clk => clk,
        reset_n => reset_n,
        start => start_blakley,
        done => blakley_done
    );
    
-- Return the selected but from key_e
get_e_bit : process (current_e_bit, key_e)
begin
	if (current_e_bit < 128) then
		key_e_bit_is_high <= key_e(current_e_bit);
	else 
		key_e_bit_is_high <= '0';
	end if;
end process;

-- Route the correct input to the x_ register
select_x_inverse_input : process (load_blakley_to_x_inverse, blakley_result, monpro_result)
begin
    if (load_blakley_to_x_inverse = '1') then
        x_inverse_next <= blakley_result;
    else
        x_inverse_next <= monpro_result;
    end if;
end process;

-- Select the correct input for blakley
blakley_input_proc : process (select_blakley_input, message)
begin
    if (select_blakley_input = '1') then
        blakley_input(0) <= '1';
        blakley_input(127 downto 1) <= (others => '0');
    else
        blakley_input <= message;
    end if;
end process;

-- Select the correct input for monpro
monpro_input_proc : process (select_monpro_input_1, select_monpro_input_2, message, x_inverse)
begin
    if (select_monpro_input_1 = '1') then
        operand_a <= message;
    else
        operand_a <= x_inverse;
    end if;
    if (select_monpro_input_2 = '1') then
        operand_b(0) <= '1';
        operand_b(127 downto 1) <= (others => '0');
    else
        operand_b <= x_inverse;
    end if;
end process;


-- Route the correct input to the message registers
select_message_input : process (load_blakley_to_msg, data_in, blakley_result)
begin
    if (load_blakley_to_msg = '1') then
        msg_3 <= blakley_result(127 downto 96);
        msg_2 <= blakley_result(95 downto 64);
        msg_1 <= blakley_result(63 downto 32);
        msg_0 <= blakley_result(31 downto 0);        
    else
        msg_3 <= data_in;
        msg_2 <= data_in;
        msg_1 <= data_in;
        msg_0 <= data_in;
    end if;
end process;

-- In case load_blakley_to_msg is used, one shouldn't have to activate all load_msg signals
load_msg_0 <= load_msg(0) OR load_blakley_to_msg;
load_msg_1 <= load_msg(1) OR load_blakley_to_msg;
load_msg_2 <= load_msg(2) OR load_blakley_to_msg;
load_msg_3 <= load_msg(3) OR load_blakley_to_msg;   

-- Route the correct 32 bits to the output
select_output_register : process (select_output, monpro_result)
begin
    case(select_output) is
    when "11" =>
        data_out <= monpro_result(127 downto 96);
    when "10" =>
        data_out <= monpro_result(95 downto 64);
    when "01" =>
        data_out <= monpro_result(63 downto 32);
    when others => -- "00"
        data_out <= monpro_result(31 downto 0);
    end case;
end process;

-- *************************************************************
-- Register declarations follow    
-- *************************************************************
-- Message registers
reg_msg0 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg_0,
        d => msg_0,
        q => message(31 downto 0)
    );
    
reg_msg1 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg_1,
        d => msg_1,
        q => message(63 downto 32)
    );

reg_msg2 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg_2,
        d => msg_2,
        q => message(95 downto 64)
    );
    
reg_msg3 : entity work.register_enable_reset_n
    port map(
        clk => clk,
        reset_n => reset_n,
        en => load_msg_3,
        d => msg_3,
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

--reg_m_inverse : entity work.register_enable_reset_n
--    generic map(REGISTER_WIDTH => 128)
--    port map(
--        clk => clk,
--        reset_n => reset_n,
--        en => load_blakley_to_msg,
--        d => blakley_result,
--        q => m_inverse
--    );

reg_x_inverse : entity work.register_enable_reset_n
        generic map(REGISTER_WIDTH => 128)
        port map(
            clk => clk,
            reset_n => reset_n,
            en => load_x_inverse,
            d => x_inverse_next,
            q => x_inverse
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
--        case (select_output) is -- result chunk to output
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
--        if (load_blakley_to_msg = '1') then
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
