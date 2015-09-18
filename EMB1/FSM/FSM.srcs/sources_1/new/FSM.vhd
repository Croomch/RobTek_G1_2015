----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2015 07:43:54
-- Design Name: 
-- Module Name: FSM - Behavioral
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

entity FSM is
    Port ( LED : out STD_LOGIC_VECTOR (5 downto 0);
           SW : in STD_LOGIC_VECTOR (1 downto 0);
           CLK : in STD_LOGIC;
           ALIVE : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is

component BTN_debounce
    Port ( CLK : in STD_LOGIC;
           CLK_SLOW : in STD_LOGIC;
           PULSE : out STD_LOGIC;
           BTN : in STD_LOGIC
           );
end component;

    SIGNAL CLK_SLOW : STD_LOGIC := '0';
    SIGNAL PULSE : STD_LOGIC := '0';
    SIGNAL BTN : STD_LOGIC := '0';
    SIGNAL ALIVE_LED : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';

    TYPE state IS (LED1, LED2, LED3, LED4, LED5, LED6);
    SIGNAL pr_state, nx_state : state;    

    CONSTANT CLK_FREQ : INTEGER := 50000000;     
    CONSTANT ALIVE_PERIOD : INTEGER := CLK_FREQ;
    CONSTANT CLK_SLOW_PERIOD : INTEGER := 2 * CLK_FREQ / 1000;
begin

-- btn debounce
BTN <= SW(0);
BTN_c : BTN_debounce PORT MAP (
    CLK => CLK,
    CLK_SLOW => CLK_SLOW,
    PULSE => PULSE,
    BTN => BTN
);


-- clk scaler
process(CLK)
variable scaler : integer range 0 to CLK_SLOW_PERIOD/2 := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        if scaler >= CLK_SLOW_PERIOD/2 then
            scaler := 0;
            CLK_SLOW <= NOT(CLK_SLOW);
        end if;
    end if;
end process;


-- alive timer
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


-- lower FSM
rst <= SW(1);
process(CLK, rst)
begin
    if rst = '1' then
        pr_state <= LED1;
    elsif rising_edge(CLK) then
        pr_state <= nx_state;
    end if;
end process;

-- upper FSM
process(pr_state, PULSE)
begin
    CASE pr_state IS
        WHEN LED1 =>
            LED <= "000001";
            
            IF PULSE = '1' THEN
                nx_state <= LED2;
            ELSE
                nx_state <= LED1;
            END IF;
        WHEN LED2 =>
            LED <= "000010";
                        
            IF PULSE = '1' THEN
                nx_state <= LED3;
            ELSE
                nx_state <= LED2;
            END IF;
        WHEN LED3 =>
            LED <= "000100";
                                    
            IF PULSE = '1' THEN
                nx_state <= LED4;
            ELSE
                nx_state <= LED3;
            END IF;
        WHEN LED4 =>
            LED <= "001000";
                                                
            IF PULSE = '1' THEN
                nx_state <= LED5;
            ELSE
                nx_state <= LED4;
            END IF;
        WHEN LED5 =>
            LED <= "010000";
        
            IF PULSE = '1' THEN
                nx_state <= LED6;
            ELSE
                nx_state <= LED5;
            END IF;
        WHEN LED6 =>
            LED <= "100000";
                                                                        
            IF PULSE = '1' THEN
                nx_state <= LED1;
            ELSE
                nx_state <= LED6;
            END IF;
    END CASE;                                                             
end process;



end Behavioral;
