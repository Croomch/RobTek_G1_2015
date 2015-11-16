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

constant CLK_SCALING: integer := 434; 


signal CLK_BAUD: STD_LOGIC := "0";
signal inputSignal: STD_LOGIC_VECTOR := "111111111";
signal com : STD_LOGIC := "0";

begin 

-- BAUD GENERATION
-- clk scaler to get 115200 bps == 115200 Hz
process(CLK)
variable scaler : integer range 0 to CLK_SCALING/2 := 0;
begin
    if rising_edge(CLK) and com = 1 then
    scaler := scaler + 1;
        if scaler >= CLK_SCALING/2 then 
            scaler := 0;
            CLK_BAUD <= NOT(CLK_BAUD);
        end if;
    end if;
    
end process;


--Syncronize?

--Check RX each BAUD_CLK cycle. process start communication
-- if not communication on, wait for '0'
-- if '0' -> start reading

process(CLK, com)
begin
    if (rising_edge(CLK) and comin = 0) then
        inputSignal <= inputSignal(8 downto 1) & RX;
        if (inputSignal < "111111100") then
            com <= 1;
        end if;        
    end if;

end process;

-- READING 
-- if reading and communication starts -> add bytes to signal with each BAUD_CLK
-- when reading finish -> communication off

process(CLK_BAUD,com)
begin
    if (rising_edge(CLK_BAUD) and com = 1) then 
        instructions <= instructions(7 downto 0) & RX;
        bitcounter <= bitcounter + "1";
    end if;
end process;


-- WRITING
-- if writing and communication starts -> put bytes from signal into TX.

    



end Behavioral;
