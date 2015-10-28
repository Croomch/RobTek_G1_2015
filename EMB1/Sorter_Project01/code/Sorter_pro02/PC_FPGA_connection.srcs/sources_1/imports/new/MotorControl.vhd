

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MotorControl is
    Port ( motorposition : in STD_LOGIC_VECTOR (1 downto 0);
            PWM : out STD_LOGIC;
            CLK : in STD_LOGIC
    );
end MotorControl;

architecture Behavioral of MotorControl is
-- clk frequency of input clk
CONSTANT CLK_FREQ : INTEGER := 50000000;
-- pulse widths of the different signals needed and update frequency     
CONSTANT SERVO_LEFT : INTEGER := CLK_FREQ / 1000; -- 1 ms
CONSTANT SERVO_CENTER : INTEGER := (3 * CLK_FREQ) / 2000; -- 1.5ms     
CONSTANT SERVO_RIGHT : INTEGER := CLK_FREQ / 500; -- 2ms
CONSTANT SERVO_UPDATE : INTEGER := CLK_FREQ / 50; -- updated with 50 Hz (20ms)
begin

-- set PWM high when less than the uptime, else it is low
process(CLK)
variable scaler : integer range 0 to SERVO_UPDATE := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        PWM <= '1'; -- is overwritten if any of the following conditions are meet.
        if scaler > SERVO_CENTER AND motorposition = "00" then
            PWM <= '0';
        elsif scaler > SERVO_RIGHT AND motorposition = "01" then
            PWM <= '0';
        elsif scaler > SERVO_LEFT AND motorposition = "10" then
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
