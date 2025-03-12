----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2025 08:47:16 AM
-- Design Name: 
-- Module Name: hourglass_sorting_initial_node - Behavioral
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


entity hourglass_sorting_initial_node is
    Generic (
        KEY_WIDTH: integer := 7;
        VALUE_WIDTH: integer := 10
    );
    Port ( 
        clk, rst: in std_logic;
        load: in std_logic;
        in_key: in std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_out_key: out std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_out_valid: out std_logic;
        axis_out_ready: in std_logic 
    );
end hourglass_sorting_initial_node;

architecture Behavioral of hourglass_sorting_initial_node is
    signal reg_key: std_logic_vector(KEY_WIDTH - 1 downto 0);
    signal reg_full: std_logic;
begin

    axis_out_key <= reg_key;
    axis_out_valid <= reg_full;

    seq: process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_full <= '0';
            else
                if load = '1' then
                    reg_full <= '1';
                    reg_key <= in_key;
                elsif axis_out_ready = '1' then
                    reg_full <= '0';
                end if;
            end if;
        end if; 
    end process;


end Behavioral;
