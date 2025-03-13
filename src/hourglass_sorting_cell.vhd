----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2025 02:52:32 PM
-- Design Name: 
-- Module Name: hourglass_sorting_cell - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity hourglass_sorting_cell is
    Generic (
        KEY_WIDTH: integer := 7;
        INDEX_WIDTH: integer := 10;
        LOWEST_FIRST: boolean := true
    );
    Port (
        clk, rst: in std_logic;
        axis_in_left_key: in std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_in_left_index: in std_logic_vector(INDEX_WIDTH - 1 downto 0);
        axis_in_left_valid: in std_logic;
        axis_in_left_ready: out std_logic;
        axis_in_right_key: in std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_in_right_index: in std_logic_vector(INDEX_WIDTH - 1 downto 0);
        axis_in_right_valid: in std_logic;
        axis_in_right_ready: out std_logic;
        axis_out_key: out std_logic_vector(KEY_WIDTH - 1 downto 0);
        axis_out_index: out std_logic_vector(INDEX_WIDTH downto 0);
        axis_out_valid: out std_logic;
        axis_out_ready: in std_logic 
    );
end hourglass_sorting_cell;

architecture Behavioral of hourglass_sorting_cell is

    signal win_left, select_bit: std_logic;

    signal reg_0_key, reg_1_key: std_logic_vector(KEY_WIDTH - 1 downto 0);
    signal reg_0_index, reg_1_index: std_logic_vector(INDEX_WIDTH downto 0);
    signal reg_0_full, reg_1_full: std_logic;
    
    signal axis_in_index: std_logic_vector(INDEX_WIDTH - 1 downto 0);
    signal axis_in_key: std_logic_vector(KEY_WIDTH - 1 downto 0);
    signal axis_in_valid: std_logic;
    signal axis_in_ready: std_logic;
    

begin
    
    --input control
    axis_in_ready <= '1' when reg_0_full = '0' else '0';
    gen_lowest: if LOWEST_FIRST generate
        win_left <= '1' when unsigned(axis_in_left_key) <= unsigned(axis_in_right_key) else '0';
    end generate;
    gen_highest: if not LOWEST_FIRST generate
        win_left <= '1' when unsigned(axis_in_left_key) >= unsigned(axis_in_right_key) else '0';
    end generate;
                         
                         
    mux_input: process(axis_in_left_key, axis_in_left_valid, axis_in_left_index,
                       axis_in_right_key, axis_in_right_valid, axis_in_right_index,
                       axis_in_ready, win_left) begin
        --if the first is lower
        if win_left = '1' then
            --if it is valid, output it, otherwise output right
            if (axis_in_left_valid = '1') then
                --mux current side
                axis_in_index <= axis_in_left_index;
                axis_in_key <= axis_in_left_key;
                axis_in_valid <= axis_in_left_valid;
                axis_in_left_ready <= axis_in_ready;
                --supress other side
                axis_in_right_ready <= '0';
                select_bit <= '0';
            else
                --mux current side
                axis_in_index <= axis_in_right_index;
                axis_in_key <= axis_in_right_key;
                axis_in_valid <= axis_in_right_valid;
                axis_in_right_ready <= axis_in_ready;
                --supress other side
                axis_in_left_ready <= '0';
                select_bit <= '1';
            end if;
        else
            --right is >=, if it is valid, output it
            if (axis_in_right_valid = '1') then
                --mux current side
                axis_in_index <= axis_in_right_index;
                axis_in_key <= axis_in_right_key;
                axis_in_valid <= axis_in_right_valid;
                axis_in_right_ready <= axis_in_ready;
                --supress other side
                axis_in_left_ready <= '0';
                select_bit <= '1';
            else
                --mux current side
                axis_in_index <= axis_in_left_index;
                axis_in_key <= axis_in_left_key;
                axis_in_valid <= axis_in_left_valid;
                axis_in_left_ready <= axis_in_ready;
                --supress other side
                axis_in_right_ready <= '0';
                select_bit <= '0';
            end if;
        end if;
    end process;
    
    
        
    seq: process(clk, rst) begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_0_full <= '0';
                reg_1_full <= '0';
            else
                --both empty
                if (reg_0_full = '0') then
                    --writing to first register
                    reg_0_full <= axis_in_valid;
                    reg_0_key <= axis_in_key;
                    reg_0_index <= select_bit & axis_in_index;
                --first is full
                elsif (reg_1_full = '0') then
                    --grab input if reg0 goes away
                    if (axis_out_ready = '1') then
                        reg_0_full <= axis_in_valid;
                        reg_0_key <= axis_in_key;
                        reg_0_index <= select_bit & axis_in_index;
                    else
                        reg_1_full <= axis_in_valid;
                        reg_1_key <= axis_in_key;
                        reg_1_index <= select_bit & axis_in_index;
                    end if;
                elsif (axis_out_ready = '1') then
                    --shift regs
                    reg_0_full <= reg_1_full;
                    reg_0_key <= reg_1_key;
                    reg_0_index <= reg_1_index;
                    reg_1_full <= '0';
                end if;
            end if;
        end if;
    end process;


    axis_out_valid <= reg_0_full;
    axis_out_key <= reg_0_key;
    axis_out_index <= reg_0_index;
    


end Behavioral;
