----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2015 01:29:25 PM
-- Design Name: 
-- Module Name: Communication - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Communication is
    Port (  CLK : in STD_LOGIC;
            RX : in STD_LOGIC;
            TX : out STD_LOGIC;
            instructions : out STD_LOGIC_VECTOR(8 downto 0);
            values : in STD_LOGIC_VECTOR(8 downto 0)
        );
end Communication;

architecture Behavioral of Communication is


signal BAUD_CLK: STD_LOGIC := '0';
signal inputSignal: STD_LOGIC_VECTOR(7 downto 0) := "111111111";


begin

--Syncronize?

--Check RX each BAUD_CLK cycle. process start communication
-- if not communication on, wait for '0'
-- if '0' -> start reading

process(CLK, com)
begin
    if (rising_edge(CLK) and com = 0) then
        inputSignal <= inputSignal(7 downto 1) & RX;
        if inputSignal < "111111100" then
        
        end if;
    end if;

end process;

-- READING 
-- if reading and communication starts -> add bytes to signal with each BAUD_CLK
-- when reading finish -> communication off

-- WRITING
-- if writing and communication starts -> put bytes from signal into TX.



end Behavioral;
