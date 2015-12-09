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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    
    ALIVE : out STD_LOGIC;
    TESTLED : out STD_LOGIC;
    
    XB_SERIAL_O   		: out	STD_LOGIC;                       -- Serial stream to PC
    XB_SERIAL_I	   	: in	STD_LOGIC;                       -- Serial stream from PC
    XB_LEDS_O			: out	STD_LOGIC_VECTOR(2 downto 0);    -- 3 LED's on expansion board
    XB_PSW_I        : in  STD_LOGIC_VECTOR(3 downto 0)    -- 4 dip switches
    );
end topmodule;

architecture Behavioral of topmodule is
---- SIGNALS ----
-- FSM states --
TYPE state IS (init_spi, send_data, get_au, get_al);
signal pr_state, nx_state : state;
-- data signals
signal acc_X : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
-- reinitiate signal
signal reinitiate : STD_LOGIC := '0';
-- signals for PWM
signal L_FWD, L_BACK, R_FWD, R_BACK : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal HIGH_L_FWD_PWM, HIGH_L_BACK_PWM, HIGH_R_FWD_PWM, HIGH_R_BACK_PWM : STD_LOGIC := '0';
signal ACTIVE_L_FWD, ACTIVE_L_BACK, ACTIVE_R_FWD, ACTIVE_R_BACK : STD_LOGIC :='0';
signal CLK_SLOW : STD_LOGIC := '0';
-- SPI data --
signal spi_rx : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal spi_rx_sig : STD_LOGIC := '0';
signal spi_tx_sig : STD_LOGIC := '0';
signal spi_tx_ctl : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal spi_tx_msg : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
-- alive signal --
signal ALIVE_LED : STD_LOGIC := '0';
-- PID signals --
signal MotorDuty : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
signal actualAngle : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
CONSTANT ZeroAngle : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
CONSTANT DutyTest : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
-- TosNet
signal data_Bluetooth : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";

---- CONSTANTS ----
CONSTANT CLK_FREQ : INTEGER := 50000000;
CONSTANT CLK_SCALING : INTEGER := 10; -- for the generation of clk signal for the motors
CONSTANT ALIVE_PERIOD : INTEGER := CLK_FREQ;
-- for SPI communication
-- set data
CONSTANT GET_CTRL9_XL : STD_LOGIC_VECTOR(7 downto 0) := "10011001";
CONSTANT SET_CTRL1_XL : STD_LOGIC_VECTOR(7 downto 0) := "00010000";
CONSTANT GET_CTRL1_XL : STD_LOGIC_VECTOR(7 downto 0) := "10010000";
CONSTANT SET_CTRL1_ON : STD_LOGIC_VECTOR(7 downto 0) := "10100101";
CONSTANT GET_STATUS : STD_LOGIC_VECTOR(7 downto 0) := "10011110";
-- ACC
CONSTANT GET_ACCX_H : STD_LOGIC_VECTOR(7 downto 0) := "10101001";
CONSTANT GET_ACCX_L : STD_LOGIC_VECTOR(7 downto 0) := "10101000";
CONSTANT GET_ACCY_H : STD_LOGIC_VECTOR(7 downto 0) := "10101011";
CONSTANT GET_ACCY_L : STD_LOGIC_VECTOR(7 downto 0) := "10101010";
CONSTANT GET_ACCZ_H : STD_LOGIC_VECTOR(7 downto 0) := "10101100";
CONSTANT GET_ACCZ_L : STD_LOGIC_VECTOR(7 downto 0) := "10101101";
-- GYR
CONSTANT GET_GYRX_H : STD_LOGIC_VECTOR(7 downto 0) := "10100010";
CONSTANT GET_GYRX_L : STD_LOGIC_VECTOR(7 downto 0) := "10100011";
CONSTANT GET_GYRY_H : STD_LOGIC_VECTOR(7 downto 0) := "10100100";
CONSTANT GET_GYRY_L : STD_LOGIC_VECTOR(7 downto 0) := "10100101";
CONSTANT GET_GYRZ_H : STD_LOGIC_VECTOR(7 downto 0) := "10100110";
CONSTANT GET_GYRZ_L : STD_LOGIC_VECTOR(7 downto 0) := "10100111";


---- COMPONENTS ----
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


COMPONENT motorcontrol IS
Port (     CLK : in STD_LOGIC;        
           PWM : out STD_LOGIC;
           ACTIVE : in STD_LOGIC;
           duty : in STD_LOGIC_VECTOR (7 downto 0)
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

-- spi with gyro/acc --
COMPONENT SPI IS
    Port (  CLK : in STD_LOGIC;
    
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           
           output : out STD_LOGIC_VECTOR (7 downto 0);
           output_updated : out STD_LOGIC;
           
           getSample : in STD_LOGIC;
           SPI_CONTROL : in STD_LOGIC_VECTOR (7 downto 0);
           SPI_MSG : in STD_LOGIC_VECTOR (7 downto 0)
            );
END COMPONENT;

-- PID --
COMPONENT PID_controller IS
    Port (  CLK : in STD_LOGIC;
            errorAngle : in STD_LOGIC_VECTOR (7 downto 0);
            DesiredAngle : in STD_LOGIC_VECTOR (7 downto 0);
            MotorOutput : out STD_LOGIC_VECTOR (8 downto 0)
            );
END COMPONENT;


begin
--------------------
---- Components ----
--------------------
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

-- init the components needed
MOTOR_CONTROL(0) <= ACTIVE_L_FWD;
MOTOR_CONTROL(1) <= ACTIVE_R_FWD;
MOTOR_CONTROL(4) <= ACTIVE_L_BACK;
MOTOR_CONTROL(5) <= ACTIVE_R_BACK;

MOTOR_CONTROL(2) <= HIGH_L_FWD_PWM;
MOTOR_CONTROL(3) <= HIGH_R_FWD_PWM;
MOTOR_CONTROL(6) <= HIGH_L_BACK_PWM;
 MOTOR_CONTROL(7) <= HIGH_R_BACK_PWM;

L_F : motorcontrol Port map (
    CLK => CLK_SLOW,
    PWM => HIGH_L_FWD_PWM,
    ACTIVE => ACTIVE_L_FWD,
    duty => L_FWD
);

L_B : motorcontrol Port map (
    CLK => CLK_SLOW,
    PWM => HIGH_L_BACK_PWM,
    ACTIVE => ACTIVE_L_BACK,
    duty => L_BACK
);

R_F : motorcontrol Port map (
    CLK => CLK_SLOW,
    PWM => HIGH_R_FWD_PWM,
    ACTIVE => ACTIVE_R_FWD,
    duty => R_FWD
);

R_B : motorcontrol Port map (
    CLK => CLK_SLOW,
    PWM => HIGH_R_BACK_PWM,
    ACTIVE => ACTIVE_R_BACK,
    duty => R_BACK
);

spi_c : SPI Port map (
    CLK => CLK,
    SPI_CLK => SPI_CLK,
    SPI_MOSI => SPI_MOSI,
    SPI_MISO => SPI_MISO,
    SPI_CS => SPI_CS,
    output => spi_rx,
    output_updated => spi_rx_sig,
    getSample => spi_tx_sig,
    SPI_MSG => spi_tx_msg,
    SPI_CONTROL => spi_tx_ctl
);

pid : component PID_controller 
    Port map(
        CLK => CLK,
        errorAngle => actualAngle,
        MotorOutput => MotorDuty,
        DesiredAngle => ZeroAngle

    );


-------------------
---- MAIN PART ----
-------------------
-- lower FSM - flip-flop part, optn. add reset?! --
process(CLK)
--variable rst_count : integer range 0 to CLK_SCALING + 1000 := 0;
begin
    if rising_edge(CLK) then -- update the state regularly
        pr_state <= nx_state;
--        rst_count := rst_count + 1;
--        if rst_count > CLK_SCALING then
--            reinitiate <= '1';
--        elsif rst_count  >= CLK_SCALING + 1000 then
--            rst_count := 0;
--        end if;
    end if;
end process;

-- upper FSM, could be concurrent code too - no flip-flops allowed --
-- see state diagram for the design
-- jump to init state once in a while to ensuree that communication is up and running
process(pr_state, spi_rx_sig) -- pr state and all other inputs
begin
    CASE pr_state IS
        WHEN init_spi =>
            -- output --
            spi_tx_ctl <= SET_CTRL1_XL;
            spi_tx_msg <= SET_CTRL1_ON;
            spi_tx_sig <= '1';
            -- what is nx-state?
            if spi_rx_sig = '1' then -- wait for timer run out signal
                --nx_state <= send_data;
                spi_tx_sig <= '1';
            --    if spi_rx(0) = '1' then -- if new data ready on accelerometer
                    nx_state <= get_au;
            --    else
            --        nx_state <= init_spi;
            --    end if;
            else -- stay in the state
                nx_state <= init_spi;
            end if;
        WHEN send_data =>
            -- output --
            spi_tx_ctl <= SET_CTRL1_XL;
            spi_tx_msg <= SET_CTRL1_ON;
            spi_tx_sig <= '1';
            -- what is nx-state? 
            --if reinitiate = '1' then
           --     nx_state <= init_spi;              
            --else
           --     nx_state <= get_au;
           -- end if;
           if spi_rx_sig = '1' then -- wait for timer run out signal
                --actualAngle <= spi_rx;
                spi_tx_sig <= '1';
                nx_state <= get_au;
           else -- stay in the state
                nx_state <= send_data;
           end if;
        WHEN get_au => 
            -- output --
            spi_tx_ctl <= GET_ACCY_H;
            spi_tx_msg <= "00000000";
            spi_tx_sig <= '1';
            actualAngle <= spi_rx;
            -- what is nx-state? 
            if spi_rx_sig = '1' then -- wait for timer run out signal
                --actualAngle <= spi_rx;
                spi_tx_sig <= '1';
                nx_state <= send_data;
            else -- stay in the state
                nx_state <= get_au;
            end if;
        WHEN get_al =>
--            -- output --
            --spi_tx_ctl <= data_Bluetooth(15 downto 8);
            --spi_tx_msg <= data_Bluetooth(7 downto 0);
            --spi_tx_sig <= '1';
--            -- what is nx-state? 
            --if spi_rx_sig = '1';
            --    spi_tx_sig <= '1';
            --    nx_state <= send_data;
            --else
                nx_state <= get_au;
            --end if
--            if spi_rx_sig = '1' then -- wait for timer run out signal
--                nx_state <= send_data, get_au, get_al;
--            else -- stay in the state
--            end if;
    END CASE; 
end process;

---------------------
---- Extra stuff ----
---------------------

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


--actualAngle <= spi_rx;

process(CLK)

begin 
    if rising_edge(CLK) then
        if MotorDuty(8) = '0' then
            TESTLED <= '0';
            ACTIVE_L_BACK <= '0';
            ACTIVE_R_BACK <= '0';
            ACTIVE_L_FWD <= '1';
            ACTIVE_R_FWD <= '1';

            L_FWD <= MotorDuty(7 downto 0);
           R_FWD <= MotorDuty(7 downto 0);
        else 
                
            TESTLED <= '1';
            ACTIVE_L_FWD <= '0';
            ACTIVE_R_FWD <= '0';
            ACTIVE_L_BACK <= '1';
            ACTIVE_R_BACK <= '1';
            L_BACK <= DutyTest(7 downto 0);
            R_BACK <= DutyTest(7 downto 0);
        end if;
    end if;
            
end process;

-- alive timer --
-- generate a regular blinking on the onboard led 
ALIVE <= ALIVE_LED;
process(CLK)
variable alive_scaler : integer range 0 to ALIVE_PERIOD/2 := 0;
begin
    if rising_edge(CLK) then
        alive_scaler := alive_scaler + 1;
        if alive_scaler >= ALIVE_PERIOD/2 then 
            alive_scaler := 0;
            ALIVE_LED <= NOT(ALIVE_LED);
        end if;
    end if;
    
end process;


-----------------
---- uTosNEt ----
-----------------
---------------------------------------------------------
-- Clocked process, to take data off the controller bus	
----------------------------------------------------------
  DatFromTosNet: 	
  process(CLK)
  begin -- process
    if (CLK'event and CLK='1' and T_data_from_mem_latch='1') then
	   case (T_reg_ptr & T_word_ptr) is                        -- The addresses are concatenated for compact code
		  when "00000" => data_Bluetooth <= T_data_from_mem;               -- Register 0, word 0 - all 32 bits
--		  when "00001" => pwm_value <= T_data_from_mem(15 downto 0);  -- Register 0, word 1 - low 16 bits
--		                  flash     <= T_data_from_mem(31 downto 24); --                      high 8 bits
--		  when "00100" => v_leds    <= T_data_from_mem;               -- Register 1, word 0 - all 32 bits
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
--       Etc. etc. etc.
			when others =>
		end case;		
	end process;

end Behavioral;
