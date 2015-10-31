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
            ligthlevel : in STD_LOGIC_VECTOR (9 downto 0);
            intensity_red, intensity_green, intensity_blue : out STD_LOGIC_VECTOR (9 downto 0);

            tr_red_redmin, tr_red_redMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_green_redmin, tr_green_redMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_blue_redmin, tr_blue_redMax : in STD_LOGIC_VECTOR (9 downto 0);

            tr_red_greenmin, tr_red_greenMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_green_greenmin, tr_green_greenMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_blue_greenmin, tr_blue_greenMax : in STD_LOGIC_VECTOR (9 downto 0);

            tr_red_bluemin, tr_red_blueMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_green_bluemin, tr_green_blueMax : in STD_LOGIC_VECTOR (9 downto 0);
            tr_blue_bluemin, tr_blue_blueMax : in STD_LOGIC_VECTOR (9 downto 0);

            getData : out STD_LOGIC
           );
end ColorDetector;

architecture Behavioral of ColorDetector is
-- FSM states --
TYPE state IS (decide, red, green, blue);
signal pr_state, nx_state : state;
-- save the lighting intensities --
signal i_red, i_blue, i_green : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
-- intensity tresholds --
signal t_red_redmin, t_red_redMax, t_blue_redmin, t_blue_redMax, t_green_redmin, t_green_redMax : STD_LOGIC_VECTOR (9 downto 0) := "1000000000";
signal t_red_greenmin, t_red_greenMax, t_blue_greenmin, t_blue_greenMax, t_green_greenmin, t_green_greenMax : STD_LOGIC_VECTOR (9 downto 0) := "1000000000";
signal t_red_bluemin, t_red_blueMax, t_blue_bluemin, t_blue_blueMax, t_green_bluemin, t_green_blueMax : STD_LOGIC_VECTOR (9 downto 0) := "1000000000";


-- timer signal
signal timer_end, timer_start : STD_LOGIC := '0';

---- Constants ----
-- board clk frequency --
CONSTANT CLK_FREQ : INTEGER := 50000000;
-- constant for defining wait period from LED is switched on till the adc has to be sampled
CONSTANT CLK_TIMEOUT_PERIOD : INTEGER := CLK_FREQ/ 30000;

begin
-- load tresholds
t_red_redmin <= tr_red_redmin;
t_red_redMax <= tr_red_redMax;
t_green_redmin <= tr_green_redmin;
t_green_redMax <= tr_green_redMax;
t_blue_redmin <= tr_blue_redmin;
t_blue_redMax <= tr_blue_redMax;

t_red_bluemin <= tr_red_bluemin;
t_red_blueMax <= tr_red_blueMax;
t_green_bluemin <= tr_green_bluemin;
t_green_blueMax <= tr_green_blueMax;
t_blue_bluemin <= tr_blue_bluemin;
t_blue_blueMax <= tr_blue_blueMax;

t_red_greenmin <= tr_red_greenmin;
t_red_greenMax <= tr_red_greenMax;
t_green_greenmin <= tr_green_greenmin;
t_green_greenMax <= tr_green_greenMax;
t_blue_greenmin <= tr_blue_greenmin;
t_blue_greenMax <= tr_blue_greenMax;

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
process(pr_state, ligtlevel_updated, timer_end) -- pr state and all other inputs

begin
    CASE pr_state IS
        WHEN decide =>
            -- output --
            timer_start <= '0';
            led <= "000";
            intensity_red <= i_red;
            intensity_green <= i_green;
            intensity_blue <= i_blue;
            
            -- Find the actual color comparing the light levels
            if (i_red >= t_red_redmin and 
                i_red <= t_red_redMax and 
                i_blue >= t_blue_redmin and 
                i_blue <= t_blue_redMax and
                i_green >= t_green_redmin and
                i_green <= t_green_redMax) then
                
                color(2) <= '1';
            
            end if;             

            if (i_red >= t_red_greenmin and 
                i_red <= t_red_greenMax and 
                i_blue >= t_blue_greenmin and 
                i_blue <= t_blue_greenMax and
                i_green >= t_green_greenmin and
                i_green <= t_green_greenMax) then
                
                color(1) <= '1';
            
            end if;        

            if (i_red >= t_red_bluemin and 
                i_red <= t_red_blueMax and 
                i_blue >= t_blue_bluemin and 
                i_blue <= t_blue_blueMax and
                i_green >= t_green_bluemin and
                i_green <= t_green_blueMax) then
                
                color(0) <= '1';
            
            end if;                  
            
            -- find out which color it was using iintensity values (i_XYZ)
            --if i_red >= t_red then
            --    color(2) <= '1';
            --end if;
            --if i_green >= t_green then
            --    color(1) <= '1';
            --end if;
            --if i_blue >= t_blue then
            --    color(0) <= '1';
            --end if;
            -- also wait here for 25% duty cycle
            --timer_start <= '1';
            --getData <= '0';
            --if timer_end = '1' then
            --    timer_start <= '0';
            --    getData <= '1';
            --end if;
            -- what is nx-state?
            --if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= red;
            --    led <= "100";
            --    timer_start <= '0';
            --else -- stay in the state
            --    nx_state <= decide;
            --end if;
        WHEN red =>
            -- output --
            color <= "000";
            i_red <= ligthlevel;
            led <= "100";
            -- timeout to get data
            timer_start <= '1';
            getData <= '0';
            if timer_end = '1' then
                timer_start <= '0';
                getData <= '1';
            end if;
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= green;
                led <= "010";
                timer_start <= '0';
            else -- stay in the state
                nx_state <= red;
            end if;
        WHEN green =>
            -- output --
            color <= "000";
            i_green <= ligthlevel;
            led <= "010";
            -- timeout to get data
            timer_start <= '1';
            getData <= '0';
            if timer_end = '1' then
                timer_start <= '0';
                getData <= '1';
            end if;
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= blue;
                led <= "001";
                timer_start <= '0';
            else -- stay in the state
                nx_state <= green;
            end if;
        WHEN blue =>
            -- output --
            color <= "000";
            i_blue <= ligthlevel;
            led <= "001";
            -- timeout to get data
            timer_start <= '1';
            getData <= '0';
            if timer_end = '1' then
                timer_start <= '0';
                getData <= '1';
            end if;
            -- what is nx-state? 
            if ligtlevel_updated = '1' then -- wait for new sensor value
                nx_state <= decide;
                timer_start <= '0';
            else -- stay in the state
                nx_state <= blue;
            end if;
    END CASE; 
end process;


-- clk timeout --
-- generate a timer_end pulse x sec after timer_start has been stepped up 
process(CLK,timer_start)
variable scaler : integer range 0 to CLK_TIMEOUT_PERIOD := 0;
begin
    if rising_edge(CLK) then
        if timer_start = '1' then -- count up the timer only if asked for
            scaler := scaler + 1;
            if scaler >= CLK_TIMEOUT_PERIOD then -- time period reached
                scaler := 0;
                timer_end <= '1'; -- send signal
            end if;
        else -- if not asked for, keep scaler rst
            scaler := 0;
            timer_end <= '0';
        end if;
    end if;
end process;


end Behavioral;
