
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM is
    Port ( CLK : in STD_LOGIC;
           LED : out STD_LOGIC_VECTOR (2 downto 0);
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           PWM : out STD_LOGIC;
           ALIVE : out STD_LOGIC;
           LED_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           
           XB_SERIAL_O   		: out	STD_LOGIC;                       -- Serial stream to PC
           XB_SERIAL_I	   	: in	STD_LOGIC;                       -- Serial stream from PC
           XB_LEDS_O			: out	STD_LOGIC_VECTOR(2 downto 0);    -- 3 LED's on expansion board
           XB_PSW_I        : in  STD_LOGIC_VECTOR(3 downto 0)    -- 4 dip switches
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
-- sample adc
signal sample_adc : STD_LOGIC := '0';


-- Signals below is used to connect to the Pseudo TosNet Controller component  
signal T_reg_ptr                 : std_logic_vector(2 downto 0);
signal T_word_ptr                : std_logic_vector(1 downto 0);
signal T_data_to_mem             : std_logic_vector(31 downto 0);
signal T_data_from_mem           : std_logic_vector(31 downto 0);
signal T_data_from_mem_latch     : std_logic;

-- Here we define the signals used by the top level design
signal sys_cnt				: std_logic_vector(31 downto 0) := (others => '0');
signal freq_gen          : std_logic_vector(31 downto 0) := (others => '0');
signal freq_out          : std_logic := '0';
signal bb_leds				: std_logic_vector(7 downto 0);  -- register for 8 leds
signal dipsw             : std_logic_vector(3 downto 0);
signal frq,flsh      : std_logic;
    
-- The signals below is used to hold data for our I/O application
signal pwm_value         : std_logic_vector(15 downto 0); -- 16 bit register for pwm value
signal period		      : std_logic_vector(31 downto 0); -- 32 bit register for freq generator
signal flash             : std_logic_vector(7 downto 0); -- 8 bit register for flash duration
signal v_leds            : std_logic_vector(31 downto 0); -- 32 bit register to hold status for variable leds 
--  signal xb_leds           : std_logic_vector(2 downto 0);  -- register for 3 leds
 
 -- intensity values for the 3 different colors from the color detector
 signal i_red, i_green, i_blue : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
 -- tresholds for the color detector
 signal t_red_redmin, t_red_redMax, t_green_redmin, t_green_redMax, t_blue_redmin, t_blue_redMax : STD_LOGIC_VECTOR(9 downto 0) := "1000000000";
 signal t_red_greenmin, t_red_greenMax, t_green_greenmin, t_green_greenMax, t_blue_greenmin, t_blue_greenMax : STD_LOGIC_VECTOR(9 downto 0) := "1000000000";
 signal t_red_bluemin, t_red_blueMax, t_green_bluemin, t_green_blueMax, t_blue_bluemin, t_blue_blueMax : STD_LOGIC_VECTOR(9 downto 0) := "1000000000";
 
-- motor positions
signal mp_left : STD_LOGIC_VECTOR(8 downto 0) := "110000000"; -- W34 000000C0
signal mp_center : STD_LOGIC_VECTOR(8 downto 0) := "010001000"; -- W35 00000136
signal mp_right : STD_LOGIC_VECTOR(8 downto 0) := "011000011"; -- W36 00000187
signal mp_overwrite : STD_LOGIC_VECTOR(1 downto 0) := "11";

-- signals to count number of bricks
signal bricks_red, bricks_green, bricks_blue, nx_bricks_red, nx_bricks_green, nx_bricks_blue : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
    
---- Constants ----
-- board clk frequency --
CONSTANT CLK_FREQ : INTEGER := 50000000;
-- the period the alive-led has to blink with --     
CONSTANT ALIVE_PERIOD : INTEGER := CLK_FREQ;
-- the timeout before the state of the FSM is switched back to 'idle' from 'left-' or 'right-tray' --
CONSTANT CLK_TIMEOUT_PERIOD : INTEGER := CLK_FREQ / 4;


---- Components ----
-- motor control block - controls the pos. of the servo --
COMPONENT MotorControl IS
    Port (  motorposition : in STD_LOGIC_VECTOR (1 downto 0);
            PWM : out STD_LOGIC;
            CLK : in STD_LOGIC;
            mp_left, mp_center, mp_right : in STD_LOGIC_VECTOR(8 downto 0);
            mp_overwrite : in STD_LOGIC_VECTOR(1 downto 0)
            );
END COMPONENT;


-- Here we define the components we want to include in our design (there is only one)
-- The Port description is just copied from the components own source file
COMPONENT PseudoTosNet_ctrl is
Port (
    T_clk_50M							: in	STD_LOGIC;
    T_serial_out						: out STD_LOGIC;
    T_serial_in                   : in  STD_LOGIC;
    T_reg_ptr							: out std_logic_vector(2 downto 0);
    T_word_ptr							: out std_logic_vector(1 downto 0);
    T_data_to_mem						: in  std_logic_vector(31 downto 0);
    T_data_from_mem					: out std_logic_vector(31 downto 0);
    T_data_from_mem_latch			: out std_logic
    );
END COMPONENT;

-- ColorDetector --
COMPONENT ColorDetector IS
    Port (  CLK : in STD_LOGIC;
            color : out STD_LOGIC_VECTOR (2 downto 0);
            led : out STD_LOGIC_VECTOR (2 downto 0);
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
            tr_blue_bluemin, tr_blue_blueMax : in STD_LOGIC_VECTOR (9 downto 0);            getData : out STD_LOGIC
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
            output : out STD_LOGIC_VECTOR (9 downto 0);
            getSample : in STD_LOGIC
            );
END COMPONENT;

begin

-- Here we instantiate the Pseudo TosNet Controller component, and connect it's ports to signals	
	PseudoTosNet_ctrlInst : PseudoTosNet_ctrl
	Port map (
	   T_clk_50M          => CLK,
		T_serial_out       => XB_SERIAL_O,
		T_serial_in        => XB_SERIAL_I,
		T_reg_ptr		     => T_reg_ptr,					
		T_word_ptr		     => T_word_ptr,									
		T_data_to_mem	     => T_data_to_mem,					
		T_data_from_mem	     => T_data_from_mem,						
		T_data_from_mem_latch => T_data_from_mem_latch						
		);

-- servo control -- momentary
servo_control: MotorControl PORT MAP (
    motorposition =>  motor,
    PWM => PWM,
    CLK => CLK,
    mp_left => mp_left, 
    mp_center => mp_center, 
    mp_right => mp_right,
    mp_overwrite => mp_overwrite
);


-- adc --
-- LED_DATA <= color & spi_data_updated & spi_data(9 downto 6);--spi_data(9 downto 5); -- WHEN spi_data_updated = '1';
SPI_dev: SPI PORT MAP (
    CLK => CLK,
    SPI_CLK => SPI_CLK,
    SPI_MOSI => SPI_MOSI,
    SPI_MISO => SPI_MISO,
    SPI_CS => SPI_CS,
    output_updated => spi_data_updated,
    output => spi_data,
    getSample => sample_adc
);

-- color detector --
LED <= led_signal;
colordetector_dev: ColorDetector PORT MAP (
    CLK => CLK,
    color => color,
    led => led_signal,
    ligtlevel_updated => spi_data_updated,
    ligthlevel => spi_data,
    intensity_red => i_red, 
    intensity_green => i_green, 
    intensity_blue => i_blue,
    
    tr_red_redmin => t_red_redmin,
    tr_red_redMax => t_red_redMax,    
    tr_green_redmin => t_green_redmin,
    tr_green_redMax => t_green_redMax,
    tr_blue_redmin => t_blue_redmin,
    tr_blue_redMax => t_blue_redMax,
    
    tr_red_bluemin => t_red_bluemin,
    tr_red_blueMax => t_red_blueMax,
    tr_green_bluemin => t_green_bluemin,
    tr_green_blueMax => t_green_blueMax,
    tr_blue_bluemin => t_blue_bluemin,
    tr_blue_blueMax => t_blue_blueMax,
    
    tr_red_greenmin => t_red_greenmin,
    tr_red_greenMax => t_red_greenMax,
    tr_green_greenmin => t_green_greenmin,
    tr_green_greenMax => t_green_greenMax,
    tr_blue_greenmin => t_blue_greenmin,
    tr_blue_greenMax => t_blue_greenMax,
    
    getData => sample_adc
);



-- lower FSM - flip-flop part, optn. add reset?! --
process(CLK)
begin
    if rising_edge(CLK) then -- update the state regularly
        pr_state <= nx_state;
        bricks_blue <= nx_bricks_blue;
        bricks_red <= nx_bricks_red;
        bricks_green <= nx_bricks_green;
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
                nx_bricks_green <= bricks_green + 1; 
            elsif color = "001" then -- Blue
                nx_bricks_blue <= bricks_blue + 1;
                nx_state <= left_tray;
            elsif color = "100" then -- Red
                nx_state <= right_tray;
                nx_bricks_red <= bricks_red + 1;
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
                timer_start <= '0';
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
                timer_start <= '0';
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

---------------------------------------------------------
-- Clocked process, to take data off the controller bus	
----------------------------------------------------------
  DatFromTosNet: 	
  process(CLK)
  begin -- process
    if (CLK'event and CLK='1' and T_data_from_mem_latch='1') then
	   case (T_reg_ptr & T_word_ptr) is                        -- The addresses are concatenated for compact code
--		  when "00000" => period    <= T_data_from_mem;               -- Register 0, word 0 - all 32 bits
--		  when "00001" => pwm_value <= T_data_from_mem(15 downto 0);  -- Register 0, word 1 - low 16 bits
--		                  flash     <= T_data_from_mem(31 downto 24); --                      high 8 bits
--		  when "00100" => v_leds    <= T_data_from_mem;               -- Register 1, word 0 - all 32 bits

          when "00000" => LED_DATA <= T_data_from_mem(31 downto 24);  -- Register 0, word 1 - high 8 bits
          
          -- register 1, tresholds for the intensities
          when "00100" => t_red_redmin <= T_data_from_mem(29 downto 20);
                          t_green_redmin <= T_data_from_mem(19 downto 10);
                          t_blue_redmin <= T_data_from_mem(9 downto 0);
          when "00101" => t_red_redMax <= T_data_from_mem(29 downto 20);
                          t_green_redMax <= T_data_from_mem(19 downto 10);
                          t_blue_redMax <= T_data_from_mem(9 downto 0);
                          
          when "00110" => t_red_greenmin <= T_data_from_mem(29 downto 20);
                          t_green_greenmin <= T_data_from_mem(19 downto 10);
                          t_blue_greenmin <= T_data_from_mem(9 downto 0);
          when "00111" => t_red_greenMax <= T_data_from_mem(29 downto 20);
                          t_green_greenMax <= T_data_from_mem(19 downto 10);
                          t_blue_greenMax <= T_data_from_mem(9 downto 0);
                          
          -- register 2, tresholds for the intensities 
          when "01000" => t_red_bluemin <= T_data_from_mem(29 downto 20);
                          t_green_bluemin <= T_data_from_mem(19 downto 10);
                          t_blue_bluemin <= T_data_from_mem(9 downto 0);
          when "01001" => t_red_blueMax <= T_data_from_mem(29 downto 20);
                          t_green_blueMax <= T_data_from_mem(19 downto 10);
                          t_blue_blueMax <= T_data_from_mem(9 downto 0);
                          
          
          -- register 3, potor position values 
          when "01100" => mp_left <= T_data_from_mem(8 downto 0); -- R3W0
          when "01101" => mp_center <= T_data_from_mem(8 downto 0); -- R3W1
          when "01110" => mp_right <= T_data_from_mem(8 downto 0); -- R3W2
          when "01111" => mp_overwrite <= T_data_from_mem(1 downto 0); -- R3W3
          -- others
		  when others =>
		end case;
	 end if;
  end process;

----------------------------------------------------------
-- Unclocked process, to place data on the controller bus
----------------------------------------------------------
   DatToTosNet:
	process(T_reg_ptr,T_word_ptr)
	begin
		T_data_to_mem<="00000000000000000000000000000000";	-- default data
		case (T_reg_ptr & T_word_ptr) is                   -- The addresses are concatenated for compact code
		   -- Register 0, word 0-3 are hard coded to these values for test/demo purposes
			when "00000" =>	T_data_to_mem <= "00000000000000000000000000000001"; -- 1
			when "00001" =>	T_data_to_mem <= "00000000000000000000000000000010"; -- 2
			when "00010" =>   T_data_to_mem <= "00000000000000000000000000000100"; -- 3
			when "00011" => 	T_data_to_mem <= "00000000000000000000000000001000"; -- 4
         -- Register 1
			when "00100" =>	T_data_to_mem <= sys_cnt;  -- Word 0 gives the value of the system counter
			when "00101" =>	T_data_to_mem <= freq_gen; -- Word 1 gives the value of the frequency generator
         -- register 2
         when "01000" =>   T_data_to_mem <= "0000000000000000000000" & i_red; -- intensity of the red LED
         when "01001" =>   T_data_to_mem <= "0000000000000000000000" & i_green; -- intensity of the green LED
         when "01010" =>   T_data_to_mem <= "0000000000000000000000" & i_blue; -- intensity of the blue LED
         -- register 3
         when "01100" =>   T_data_to_mem <= bricks_red; -- brick count red
         when "01101" =>   T_data_to_mem <= bricks_green; -- brick count green
         when "01110" =>   T_data_to_mem <= bricks_blue; -- brick count blue
--       Etc. etc. etc.
			when others =>
		end case;		
	end process;

---------------------------------------------------------------------
-- Clocked process, that counts clk_50M edges
---------------------------------------------------------------------
  SystemCounter:
  process(CLK)
  begin -- process
    if (CLK'event and CLK='1') then
	   sys_cnt<=sys_cnt+1;
	 end if;
  end process;

-----------------------------------------------------------------
-- Clocked process to generate a square wave with variable period
-----------------------------------------------------------------
  FreqGen:
  process(CLK)
  begin -- process
    if (CLK'event and CLK='1') then
	   if period = 0 then
		  freq_gen <= (others => '0');
		  freq_out <= '0';
		elsif freq_gen > period then
		  freq_gen <= (others => '0');
		  freq_out <= not freq_out;
		else
		  freq_gen <= freq_gen +1;
		end if;
	 end if;
  end process;


end Behavioral;
