
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
    CLK => CLK
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
         when "01000" =>   T_data_to_mem <= "0000000000000000000000000000" & dipsw;
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
