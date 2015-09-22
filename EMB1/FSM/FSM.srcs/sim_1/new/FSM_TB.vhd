----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.09.2015 08:46:21
-- Design Name: 
-- Module Name: FSM_TB - Behavioral
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

entity FSM_TB is
end FSM_TB;

architecture Behavioral of FSM_TB is

COMPONENT FSM
    Port ( LED : out STD_LOGIC_VECTOR (5 downto 0);
           SW : in STD_LOGIC_VECTOR (1 downto 0);
           CLK : in STD_LOGIC;
           ALIVE : out STD_LOGIC
           );
END COMPONENT;

    SIGNAL LED : STD_LOGIC_VECTOR (5 downto 0) := "000000";
    SIGNAL SW : STD_LOGIC_VECTOR (1 downto 0) := "00";
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL ALIVE : STD_LOGIC := '0';

    CONSTANT CLK_PER : TIME := 20ns;
    CONSTANT SW_TOGGLE_PER : TIME := 20ms;
    CONSTANT SW_RST_PER : TIME := 200ms;


begin

uut : FSM PORT MAP (
    LED => LED,
    SW => SW,
    CLK => CLK,
    ALIVE => ALIVE
);


clk_p : PROCESS
BEGIN
    CLK <= '0';
    WAIT FOR CLK_PER/2;
    CLK <= '1';
    WAIT FOR CLK_PER/2; 
END PROCESS;

sw_rst_p : PROCESS
BEGIN
    SW(1) <= '0';
    WAIT FOR SW_RST_PER*0.9;
    SW(1) <= '1';
    WAIT FOR SW_RST_PER*0.1; 
END PROCESS;

sw_toggle_p : PROCESS
BEGIN
    SW(0) <= '0';
    WAIT FOR SW_TOGGLE_PER/2;
    SW(0) <= '1';
    WAIT FOR SW_TOGGLE_PER/2; 
END PROCESS;

end Behavioral;
