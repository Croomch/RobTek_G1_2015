----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2015 01:17:28 PM
-- Design Name: 
-- Module Name: PID_Controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PID_Controller is
    Port ( 
        CLK : in STD_LOGIC;
        Angle : in STD_LOGIC_VECTOR(15 downto 0);
        MotorSignal : out STD_LOGIC_VECTOR(15 downto 0);
    );
end PID_Controller;

architecture Behavioral of PID_Controller is
<
    signal AccError : integer := 0;
    constant Paction : integer := 1;
    constant Iaction : integer := 0.2;
    constant ZeroMot : STD_LOGIC_VECTOR(15 downto 0)

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            MotorSignal <= ZeroMot + Angle * Paction + AccError * Iaction;
            AccError = AccError + Angle;
            
        end if;
    
    
    end process;
    
        

end Behavioral;
