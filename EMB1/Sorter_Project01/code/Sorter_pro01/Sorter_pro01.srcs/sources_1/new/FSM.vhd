
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Port ( CLK : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (2 downto 0);
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           PWM : out STD_LOGIC;
           ALIVE : out STD_LOGIC;
           LED_DATA : out STD_LOGIC_VECTOR (7 downto 0)
           );
end FSM;

architecture Behavioral of FSM is

---- Signals ----
-- FSM states --
TYPE state IS (idle, left_tray, right_tray);
signal pr_state, nx_state : state;
-- signals for timeout, start for starting the timer, end to indicate that the time has gone by --
signal timer_start : STD_LOGIC := '0';
signal timer_end : STD_LOGIC := '0';
-- alive timer --
signal ALIVE_LED : STD_LOGIC := '0';
-- signal to be send to the motors to indicate which pos. to go to --
signal motor : STD_LOGIC_VECTOR(1 downto 0) := "00";
-- indicating which color has been seen --
signal color : STD_LOGIC_VECTOR(2 downto 0) := "000";
-- SPI data --
signal spi_data : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
signal spi_data_updated : STD_LOGIC := '0';
-- led driver signals --
signal led_signal : STD_LOGIC_VECTOR(2 downto 0) := "000";

---- Constants ----
-- board clk frequency --
CONSTANT CLK_FREQ : INTEGER := 50000000;
-- the period the alive-led has to blink with --     
CONSTANT ALIVE_PERIOD : INTEGER := CLK_FREQ;
-- the timeout before the state of the FSM is switched back to 'idle' from 'left-' or 'right-tray' --
CONSTANT CLK_TIMEOUT_PERIOD : INTEGER := CLK_FREQ;


---- Components ----
-- motor control block - controls the pos. of the servo --
COMPONENT MotorControl IS
    Port (  motorposition : in STD_LOGIC_VECTOR (1 downto 0);
            PWM : out STD_LOGIC;
            CLK : in STD_LOGIC
            );
END COMPONENT;

-- ColorDetector --
COMPONENT ColorDetector IS
    Port (  CLK : in STD_LOGIC;
            color : out STD_LOGIC_VECTOR (2 downto 0);
            led : out STD_LOGIC_VECTOR (2 downto 0);
            ligtlevel_updated : in STD_LOGIC;
            ligthlevel : in STD_LOGIC_VECTOR (9 downto 0)
           );
END COMPONENT;

-- ADC --
COMPONENT SPI IS
    Port (  CLK : in STD_LOGIC;
            SPI_CLK : out STD_LOGIC;
            SPI_MOSI : out STD_LOGIC;
            SPI_MISO : in STD_LOGIC;
            SPI_CS : out STD_LOGIC;
            output_updated : out STD_LOGIC; 
            output : out STD_LOGIC_VECTOR (9 downto 0)
            );
END COMPONENT;

begin

-- servo control -- momentary
servo_control: MotorControl PORT MAP (
    motorposition =>  motor,
    PWM => PWM,
    CLK => CLK
);


-- adc --
LED_DATA <= spi_data(9 downto 2);
SPI_dev: SPI PORT MAP (
    CLK => CLK,
    SPI_CLK => SPI_CLK,
    SPI_MOSI => SPI_MOSI,
    SPI_MISO => SPI_MISO,
    SPI_CS => SPI_CS,
    output_updated => spi_data_updated,
    output => spi_data
);

-- color detector --
LED <= led_signal;
colordetector_dev: ColorDetector PORT MAP (
    CLK => CLK,
    color => color,
    led => led_signal,
    ligtlevel_updated => spi_data_updated,
    ligthlevel => spi_data
);



-- lower FSM - flip-flop part, optn. add reset?! --
process(CLK)
begin
    if rising_edge(CLK) then -- update the state regularly
        pr_state <= nx_state;
    end if;
end process;

-- upper FSM, could be concurrent code too - no flip-flops allowed --
-- see state diagram for the design
process(pr_state, color, timer_end) -- pr state and all other inputs
begin
    CASE pr_state IS
        WHEN idle =>
            -- output --
            timer_start <= '0';
            motor <= "00";
            -- what is nx-state? 
            if color = "010" then -- Green
                nx_state <= left_tray;
            elsif color = "010" then -- Blue
                nx_state <= left_tray;
            elsif color = "100" then -- Red
                nx_state <= right_tray;
            else -- stay in the state
                nx_state <= idle;
            end if;
        WHEN left_tray =>
            -- output --
            timer_start <= '1';
            motor <= "10";
            -- what is nx-state? 
            if timer_end = '1' then -- wait for timer run out signal
                nx_state <= idle;
            else -- stay in the state
                nx_state <= left_tray;
            end if;
        WHEN right_tray =>
            -- output --
            timer_start <= '1';
            motor <= "01";
            -- what is nx-state? 
            if timer_end = '1' then -- wait for timer run out signal
                nx_state <= idle;
            else -- stay in the state
                nx_state <= right_tray;
            end if;
    END CASE; 
end process;


-- clk timeout --
-- generate a timer_end pulse x sec after timer_start has been stepped up 
process(CLK,timer_start)
variable scaler : integer range 0 to CLK_TIMEOUT_PERIOD := 0;
begin
    if rising_edge(CLK) then
        if timer_start = '1'then -- count up the timer only if asked for
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


-- alive timer --
-- generate a regular blinking on the onboard led 
ALIVE <= ALIVE_LED;
process(CLK)
variable scaler : integer range 0 to ALIVE_PERIOD/2 := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        if scaler >= ALIVE_PERIOD/2 then 
            scaler := 0;
            ALIVE_LED <= NOT(ALIVE_LED);
        end if;
    end if;
end process;



end Behavioral;
