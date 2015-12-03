----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.09.2015 12:06:59
-- Design Name: 
-- Module Name: AD_comunicator - Behavioral
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

entity motorcontrol is
    Port ( 
           CLK : in STD_LOGIC;
    
           PWM : out STD_LOGIC;
           duty : in STD_LOGIC_VECTOR (7 downto 0)
           );
end motorcontrol;

architecture Behavioral of motorcontrol is
-- Signals --
-- motor signals --
SIGNAL pwm_out : STD_LOGIC := '0';
SIGNAL comp : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

---- Constants ----
begin

PWM <= pwm_out;
comp <= duty;

-- clk should be 25Mhz max
-- clk scaler to get less than 3.6MHz --
process(CLK)
variable scaler : integer range 0 to 255 := 1;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        if scaler > 255 then
            scaler := 1;
        end if;
        if scaler > comp then 
            pwm_out <= '0';
        else
            pwm_out <= '1';
        end if;
        
                
    end if;
end process;


end Behavioral;
