----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 11:08:37 PM
-- Design Name: 
-- Module Name: hourglass_sorting_tree - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hourglass_sorting_tree is
    Generic (
        NUMBER_OF_ELEMENTS: integer := 21;
        KEY_WIDTH: integer := 8;
        VALUE_WIDTH: integer := 10;
        LOWEST_FIRST: boolean := true
    );
    Port ( 
        clk, rst: in std_logic;
        axis_in_keys: in std_logic_vector(NUMBER_OF_ELEMENTS*KEY_WIDTH - 1 downto 0);
        axis_in_values: in std_logic_vector(NUMBER_OF_ELEMENTS*VALUE_WIDTH - 1 downto 0);
        axis_in_valids: in std_logic_vector(NUMBER_OF_ELEMENTS - 1 downto 0);
        axis_in_readys: out std_logic_vector(NUMBER_OF_ELEMENTS - 1 downto 0);
        axis_out_key: out std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_out_value: out std_logic_vector(VALUE_WIDTH - 1 downto 0);
        axis_out_valid: out std_logic;
        axis_out_ready: in std_logic 
    );
end hourglass_sorting_tree;

architecture Behavioral of hourglass_sorting_tree is

    signal axis_keys: std_logic_vector(((NUMBER_OF_ELEMENTS+1)/2)*KEY_WIDTH - 1 downto 0);
    signal axis_values: std_logic_vector(((NUMBER_OF_ELEMENTS+1)/2)*VALUE_WIDTH - 1 downto 0);
    signal axis_valids: std_logic_vector(((NUMBER_OF_ELEMENTS+1)/2) - 1 downto 0);
    signal axis_readys: std_logic_vector(((NUMBER_OF_ELEMENTS+1)/2) - 1 downto 0);
begin

    gen_tree: for i in NUMBER_OF_ELEMENTS/2 - 1 downto 0 generate
        sorting_cell: entity work.hourglass_sorting_cell 
            Generic map(
                KEY_WIDTH => KEY_WIDTH,
                VALUE_WIDTH => VALUE_WIDTH,
                LOWEST_FIRST => LOWEST_FIRST
            )
            Port map (
                clk => clk, rst => rst,
                axis_in_left_key => axis_in_keys((i*2+2)*KEY_WIDTH - 1 downto (i*2+1)*KEY_WIDTH),
                axis_in_left_value => axis_in_values((i*2+2)*VALUE_WIDTH - 1 downto (i*2+1)*VALUE_WIDTH),
                axis_in_left_valid => axis_in_valids(i*2 + 1),
                axis_in_left_ready => axis_in_readys(i*2 + 1),
                axis_in_right_key => axis_in_keys((i*2+1)*KEY_WIDTH - 1 downto (i*2)*KEY_WIDTH),
                axis_in_right_value => axis_in_values((i*2+1)*VALUE_WIDTH - 1 downto (i*2)*VALUE_WIDTH),
                axis_in_right_valid => axis_in_valids(i*2),
                axis_in_right_ready => axis_in_readys(i*2),
                axis_out_key => axis_keys((i+1)*KEY_WIDTH - 1 downto i*KEY_WIDTH),
                axis_out_value => axis_values((i+1)*VALUE_WIDTH - 1 downto i*VALUE_WIDTH),
                axis_out_valid => axis_valids(i),
                axis_out_ready => axis_readys(i)
            );
    end generate;
    
    --for the outlier just pipe an axis and leave the other open 
    --let the tool optimize logic away
    gen_outlier: if NUMBER_OF_ELEMENTS mod 2 = 1 generate
        sorting_cell: entity work.hourglass_sorting_cell 
            Generic map(
                KEY_WIDTH => KEY_WIDTH,
                VALUE_WIDTH => VALUE_WIDTH,
                LOWEST_FIRST => LOWEST_FIRST
            )
            Port map (
                clk => clk, rst => rst,
                axis_in_left_key => axis_in_keys(axis_in_keys'length - 1 downto axis_in_keys'length - KEY_WIDTH),
                axis_in_left_value => axis_in_values(axis_in_values'length - 1 downto axis_in_values'length - VALUE_WIDTH),
                axis_in_left_valid => axis_in_valids(axis_in_valids'length - 1),
                axis_in_left_ready => axis_in_readys(axis_in_readys'length - 1),
                axis_in_right_key => (others => '0'),
                axis_in_right_value => (others => '0'),
                axis_in_right_valid => '0',
                axis_in_right_ready => open,
                axis_out_key => axis_keys(axis_keys'length - 1 downto axis_keys'length - KEY_WIDTH),
                axis_out_value => axis_values(axis_values'length - 1 downto axis_values'length - VALUE_WIDTH),
                axis_out_valid => axis_valids(axis_valids'length - 1),
                axis_out_ready => axis_readys(axis_readys'length - 1)
            );
    end generate;
    
    gen_next: if NUMBER_OF_ELEMENTS > 2 generate
        next_tree: entity work.hourglass_sorting_tree
        generic map (
            NUMBER_OF_ELEMENTS => (NUMBER_OF_ELEMENTS+1) / 2,
            KEY_WIDTH => KEY_WIDTH,
            VALUE_WIDTH => VALUE_WIDTH,
            LOWEST_FIRST => LOWEST_FIRST
        )
        port map (
            clk => clk, rst => rst,
            axis_in_keys => axis_keys,
            axis_in_values => axis_values,
            axis_in_valids => axis_valids,
            axis_in_readys => axis_readys,
            axis_out_key => axis_out_key,
            axis_out_value => axis_out_value,
            axis_out_valid => axis_out_valid,
            axis_out_ready => axis_out_ready
        );
    end generate;
    
    gen_end: if NUMBER_OF_ELEMENTS = 2 generate
        axis_out_key <= axis_keys;
        axis_out_value <= axis_values;
        axis_out_valid <= axis_valids(0);
        axis_readys(0) <= axis_out_ready;
    end generate;

end Behavioral;
