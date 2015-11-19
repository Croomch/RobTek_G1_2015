----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2015 10:22:39
-- Design Name: 
-- Module Name: anglePredictor - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity anglePredictor is
    Port (
        CLK : in STD_LOGIC;
        ACC_X : in STD_LOGIC_VECTOR(7 downto 0);
        ACC_Y : in STD_LOGIC_VECTOR(7 downto 0);
        GYR_X : in STD_LOGIC_VECTOR(7 downto 0);
        GYR_Y : in STD_LOGIC_VECTOR(7 downto 0);
        
        ANGLE : out STD_LOGIC_VECTOR(7 downto 0)
        
    );
end anglePredictor;

architecture Behavioral of anglePredictor is
---- signals ----
signal acc_angle : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
signal acc_ratio : STD_LOGIC_VECTOR(7 downto 0) := "10000000";


begin

---- main part ----
-- http://www.pieter-jan.com/node/11 for complimentary filter
-- atan approx 
--% from 0 to 0.32
--y_a = x_a;
--% from 0.32 to 0.91
--y_b = x_b * 0.75 + 0.08
--% from 0.91 to pi/2
--y_c = x_c * 0.375 + 0.42

-- x is fwd, y is down
-- atan(acc_x / acc_y)

acc_ratio <= (ACC_X < 4) / ACC_Y;
acc_angle <= acc_ratio;


end Behavioral;
