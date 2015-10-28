----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.09.2015 12:06:59
-- Design Name: 
-- Module Name: ColorDetector - Behavioral
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

entity ColorDetector is
    Port (  CLK : in STD_LOGIC;
            color : out STD_LOGIC_VECTOR (2 downto 0); -- resulting color
            led : out STD_LOGIC_VECTOR (2 downto 0); -- LED control signal
            ligtlevel_updated : in STD_LOGIC;
            ligthlevel : in STD_LOGIC_VECTOR (9 downto 0)
           );
end ColorDetector;

architecture Behavioral of ColorDetector is
-- FSM states --
TYPE state IS (decide, red, green, blue);
signal pr_state, nx_state : state;
-- save the lighting intensities --
signal i_red, i_blue, i_green : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
-- intensity tresholds --
signal t_red, t_blue, t_green : STD_LOGIC_VECTOR (9 downto 0) := "1000000000";

begin
-- no PWM is needed due to the constant changing  between the different colors = 25% duty cycle 
-- lower FSM - flip-flop part, optn. add reset?! --
process(CLK)
begin
    if rising_edge(CLK) then -- update the state regularly
        pr_state <= nx_state;
    end if;
end process;

-- upper FSM, could be concurrent code too - no flip-flops allowed --
-- see state diagram for the design
process(pr_state, ligtlevel_updated) -- pr state and all other inputs
begin
    CASE pr_state IS
        WHEN decide =>
            -- output --
            led <= "000";
            -- find out which color it was using iintensity values (i_XYZ)
            if i_red >= t_red then
                color(2) <= '1';
            end if;
            if i_green >= t_green then
                color(1) <= '1';
            end if;
            if i_blue >= t_blue then
                color(0) <= '1';
            end if;
            -- what is nx-state?
            nx_state <= red;
        WHEN red =>
            -- output --
            color <= "000";
            i_red <= ligthlevel;
            led <= "100";
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= green;
            else -- stay in the state
                nx_state <= red;
            end if;
        WHEN green =>
            -- output --
            color <= "000";
            i_green <= ligthlevel;
            led <= "010";
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                    nx_state <= blue;
            else -- stay in the state
                nx_state <= green;
            end if;
        WHEN blue =>
            -- output --
            color <= "000";
            i_blue <= ligthlevel;
            led <= "001";
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= decide;
            else -- stay in the state
                nx_state <= blue;
            end if;
    END CASE; 
end process;


end Behavioral;
