

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MotorControl is
    Port ( motorposition : in STD_LOGIC_VECTOR (1 downto 0);
            PWM : out STD_LOGIC;
            CLK : in STD_LOGIC;
            mp_left, mp_center, mp_right : in STD_LOGIC_VECTOR(8 downto 0);
            mp_overwrite : in STD_LOGIC_VECTOR(1 downto 0)
    );
end MotorControl;

architecture Behavioral of MotorControl is
-- clk frequency of input clk
CONSTANT CLK_FREQ : INTEGER := 50000000;
-- pulse widths of the different signals needed and update frequency     
--CONSTANT SERVO_LEFT : INTEGER := CLK_FREQ / 1000; -- 1 ms
--CONSTANT SERVO_CENTER : INTEGER := (3 * CLK_FREQ) / 2000; -- 1.5ms     
--CONSTANT SERVO_RIGHT : INTEGER := CLK_FREQ / 500; -- 2ms
CONSTANT SERVO_UPDATE : INTEGER := CLK_FREQ / 100; -- updated with 100 Hz (10ms)

-- signal for the motor pos
signal left : STD_LOGIC_VECTOR(16 downto 0) :=   "01100001101010000"; 
signal right : STD_LOGIC_VECTOR(16 downto 0) :=  "11000011101010000"; 
signal center : STD_LOGIC_VECTOR(16 downto 0) := "10010011101010000"; 
signal overwrite : STD_LOGIC_VECTOR(1 downto 0) := "11"; 

signal mp : STD_LOGIC_VECTOR(1 downto 0) := "00";

begin
overwrite <= mp_overwrite;
-- values for the position
left <= "10010011101010000" WHEN mp_left = "000000000" ELSE (mp_left & "01010000");
center <= "10010011101010000" WHEN mp_center = "000000000" ELSE  (mp_center & "01010000");
right <= "10010011101010000" WHEN mp_right = "000000000" ELSE (mp_right & "01010000");


-- motorposition overwrite
mp <= motorposition WHEN overwrite = "11" ELSE overwrite;

-- set PWM high when less than the uptime, else it is low
process(CLK)
variable scaler : integer range 0 to SERVO_UPDATE := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        PWM <= '1'; -- is overwritten if any of the following conditions are meet.
        if scaler > center AND mp = "00" then
            PWM <= '0';
        elsif scaler > right AND mp = "01" then
            PWM <= '0';
        elsif scaler > left AND mp = "10" then
            PWM <= '0';
        elsif motorposition = "11" then
            PWM <= '0';
        end if;
        -- reset scaler iff too high
        if scaler > SERVO_UPDATE then
            scaler := 0;
        end if;           
    end if;
end process;

end Behavioral;
