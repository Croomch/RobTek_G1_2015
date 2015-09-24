----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2015 07:43:54
-- Design Name: 
-- Module Name: BTN_debounce - Behavioral
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BTN_debounce is
    Port ( CLK : in STD_LOGIC;
           CLK_SLOW : in STD_LOGIC;
           PULSE : out STD_LOGIC;
           BTN : in STD_LOGIC
           );
end BTN_debounce;

architecture Behavioral of BTN_debounce is
    signal debounce : STD_LOGIC_VECTOR (3 downto 0) := "0000"; 
    signal p : STD_LOGIC := '0';
    
    CONSTANT pulse_length : integer := 1;
begin

debounce <= debounce(2 downto 0) & BTN WHEN rising_edge(CLK_SLOW);
PULSE <= p;


process(CLK)
    variable pl : integer range 0 to pulse_length := 0;
begin
   if rising_edge(CLK) then
       if (debounce = "1111" and pl < pulse_length) then
           p <= '1';
           pl := pl + 1;
       ELSIF (debounce = "1111" and pl = pulse_length) then
           p <= '0';
       ELSE
           pl := 0;
           p <= '0';
       END IF;
   end if;
end process;

end Behavioral;
