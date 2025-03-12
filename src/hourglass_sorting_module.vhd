----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2025 08:46:33 AM
-- Design Name: 
-- Module Name: hourglass_sorting_module - Behavioral
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
use ieee.numeric_std.all;

entity hourglass_sorting_module is
    Generic (
        NUMBER_OF_ELEMENTS: integer := 882;
        KEY_WIDTH: integer := 8;
        VALUE_WIDTH: integer := 10;
        LOWEST_FIRST: boolean := true
    );
    Port ( 
        clk, rst: in std_logic;
        load: in std_logic;
        in_keys: in std_logic_vector(NUMBER_OF_ELEMENTS*KEY_WIDTH - 1 downto 0);
        axis_out_key: out std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_out_value: out std_logic_vector(VALUE_WIDTH - 1 downto 0);
        axis_out_valid: out std_logic;
        axis_out_ready: in std_logic 
    );
end hourglass_sorting_module;

architecture Behavioral of hourglass_sorting_module is

    signal axis_keys: std_logic_vector(NUMBER_OF_ELEMENTS*KEY_WIDTH - 1 downto 0);
    signal axis_values: std_logic_vector(NUMBER_OF_ELEMENTS*VALUE_WIDTH - 1 downto 0);
    signal axis_valids: std_logic_vector(NUMBER_OF_ELEMENTS - 1 downto 0);
    signal axis_readys: std_logic_vector(NUMBER_OF_ELEMENTS - 1 downto 0);
    
begin


    initial_node: for i in NUMBER_OF_ELEMENTS - 1 downto 0 generate
        node: entity work.hourglass_sorting_initial_node
            Generic map (
                KEY_WIDTH => KEY_WIDTH,
                VALUE_WIDTH => VALUE_WIDTH
            )
            Port map ( 
                clk => clk, rst => rst,
                load => load,
                in_key => in_keys((i+1)*KEY_WIDTH - 1 downto i*KEY_WIDTH),
                axis_out_key => axis_keys((i+1)*KEY_WIDTH - 1 downto i*KEY_WIDTH),
                axis_out_valid => axis_valids(i),
                axis_out_ready => axis_readys(i)
            );
            
        axis_values((i+1)*VALUE_WIDTH - 1 downto i*VALUE_WIDTH) <= std_logic_vector(to_unsigned(i, VALUE_WIDTH));
    end generate;

    tree: entity work.hourglass_sorting_tree
        generic map (
            NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
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
    
    

end Behavioral;
