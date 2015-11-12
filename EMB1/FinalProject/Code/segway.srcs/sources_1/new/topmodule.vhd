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
    CLK : in STD_LOGIC;
    
    MOTOR_CONTROL : out STD_LOGIC_VECTOR(7 downto 0);
    
    SPI_MISO : in STD_LOGIC;
    SPI_MOSI : out STD_LOGIC;
    SPI_CLK : out STD_LOGIC;
    SPI_CS : out STD_LOGIC;
    
    ALIVE : out STD_LOGIC
    );
end topmodule;

architecture Behavioral of topmodule is
---- SIGNALS ----
-- signals for PWM
signal L_FWD, L_BACK, R_FWD, R_BACK : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal L_FWD_PWM, L_BACK_PWM, R_FWD_PWM, R_BACK_PWM : STD_LOGIC := '0';
signal CLK_SLOW : STD_LOGIC := '0';
---- CONSTANTS ----
CONSTANT CLK_SCALING : INTEGER := 10;

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
CLK => CLK_SLOW,
PWM => L_FWD_PWM,
duty => L_FWD
);

L_B : motorcontrol Port map (
CLK => CLK_SLOW,
PWM => L_BACK_PWM,
duty => L_BACK
);

R_F : motorcontrol Port map (
CLK => CLK_SLOW,
PWM => R_FWD_PWM,
duty => R_FWD
);

R_B : motorcontrol Port map (
CLK => CLK_SLOW,
PWM => R_BACK_PWM,
duty => R_BACK
);


---- clk scaler for the pwm generators ----
process(CLK)
variable scaler : integer range 0 to CLK_SCALING/2 := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        if scaler >= CLK_SCALING/2 then
            CLK_SLOW <= not(CLK_SLOW);
            scaler := 0;
        end if;
    end if;
end process;

---- main part ----





end Behavioral;
