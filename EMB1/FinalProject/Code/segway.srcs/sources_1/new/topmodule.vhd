----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2015 12:17:26
-- Design Name: 
-- Module Name: topmodule - Behavioral
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

entity topmodule is
    Port ( 
    CLK : STD_LOGIC;
    
    MOTOR_CONTROL : STD_LOGIC_VECTOR(7 downto 0);
    
    SPI_MISO : STD_LOGIC;
    SPI_MOSI : STD_LOGIC;
    SPI_CLK : STD_LOGIC;
    SPI_CS : STD_LOGIC;
    
    ALIVE : STD_LOGIC
    );
end topmodule;

architecture Behavioral of topmodule is
---- SIGNALS ----
-- signals for PWM
signal L_FWD, L_BACK, R_FWD, R_BACK : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal L_FWD_PWM, L_BACK_PWM, R_FWD_PWM, R_BACK_PWM : STD_LOGIC := '0';

---- CONSTANTS ----


---- COMPONENTS ----
COMPONENT SPI IS
Port ( 
           CLK : in STD_LOGIC;
    
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           
           output : out STD_LOGIC_VECTOR (9 downto 0);
           output_updated : out STD_LOGIC;
           
           getSample : in STD_LOGIC;
           SPI_MSG : in STD_LOGIC_VECTOR (3 downto 0)
           );
END COMPONENT;

COMPONENT motorcontrol IS
Port ( 
           CLK : in STD_LOGIC;
           
           PWM : out STD_LOGIC;
           duty : in STD_LOGIC_VECTOR (7 downto 0)
           );
END COMPONENT;

begin

-- init the components needed
MOTOR_CONTROL(1) <= L_FWD_PWM;
MOTOR_CONTROL(2) <= L_BACK_PWM;
MOTOR_CONTROL(3) <= R_FWD_PWM;
MOTOR_CONTROL(4) <= R_BACK_PWM;
L_F : motorcontrol Port map (
CLK => CLK,
PWM => L_FWD_PWM,
duty => L_FWD
);

L_B : motorcontrol Port map (
CLK => CLK,
PWM => L_BACK_PWM,
duty => L_BACK
);

R_F : motorcontrol Port map (
CLK => CLK,
PWM => R_FWD_PWM,
duty => R_FWD
);

R_B : motorcontrol Port map (
CLK => CLK,
PWM => R_BACK_PWM,
duty => R_BACK
);


---- main part ----





end Behavioral;
