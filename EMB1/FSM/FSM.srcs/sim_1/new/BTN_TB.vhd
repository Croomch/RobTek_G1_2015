----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2015 08:11:44
-- Design Name: 
-- Module Name: BTN_TB - Behavioral
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

entity BTN_TB is
end BTN_TB;

architecture Behavioral of BTN_TB is

COMPONENT BTN_debounce
    Port ( CLK : in STD_LOGIC;
           CLK_SLOW : in STD_LOGIC;
           PULSE : out STD_LOGIC;
           BTN : in STD_LOGIC
           );
END COMPONENT;

    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL CLK_SLOW : STD_LOGIC := '0';
    SIGNAL PULSE : STD_LOGIC := '0';
    SIGNAL BTN : STD_LOGIC := '0';

    CONSTANT CLK_PER : TIME := 20ns;
    CONSTANT CLK_SLOW_PER : TIME := 40ns;
    CONSTANT BTN_PER : TIME := 500ns; 

begin


uut : BTN_debounce PORT MAP (
    CLK => CLK,
    CLK_SLOW => CLK_SLOW,
    PULSE => PULSE,
    BTN => BTN
);


clk_p : PROCESS
BEGIN
    CLK <= '0';
    WAIT FOR CLK_PER/2;
    CLK <= '1';
    WAIT FOR CLK_PER/2; 
END PROCESS;

slow_clk_p : PROCESS
BEGIN
    CLK_SLOW <= '0';
    WAIT FOR CLK_SLOW_PER/2;
    CLK_SLOW <= '1';
    WAIT FOR CLK_SLOW_PER/2; 
END PROCESS;

btn_p : PROCESS
BEGIN
    BTN <= '0';
    WAIT FOR BTN_PER/2;
    BTN <= '1';
    WAIT FOR BTN_PER/2; 
END PROCESS;

end Behavioral;
