----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.09.2015 12:06:59
-- Design Name: 
-- Module Name: AD_comunicator - Behavioral
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

entity SPI is
    Port ( 
           CLK : in STD_LOGIC;
    
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           
           output : out STD_LOGIC_VECTOR (7 downto 0);
           output_updated : out STD_LOGIC;
           
           getSample : in STD_LOGIC;
           SPI_MSG : in STD_LOGIC_VECTOR (7 downto 0)
           );
end SPI;

architecture Behavioral of SPI is
-- Signals --
-- spi signals --
SIGNAL CLK_SPI : STD_LOGIC := '0';
SIGNAL CS : STD_LOGIC := '1';
SIGNAL MOSI : STD_LOGIC := '1';
-- to get val --
SIGNAL CBS : STD_LOGIC_vector (7 downto 0) := "10100010";
-- data recieved 
SIGNAL data : STD_LOGIC_vector (7 downto 0) := "00000000";


---- Constants ----
-- spi supports max of 10MHz
-- scale down with factor 6 to get = 8.33MHz < 10MHz max
CONSTANT CLK_SCALING : INTEGER := 6;
-- data msg info
CONSTANT MSG_CS_START : INTEGER := 1;
CONSTANT MSG_CS_END : INTEGER := 8;
CONSTANT MSG_DATA_START : INTEGER := 9;
CONSTANT MSG_DATA_END : INTEGER := 16;
-- how often restart to sample --
CONSTANT MSG_PERIOD : INTEGER := MSG_DATA_END+1;

begin

-- first bit is R/W and remaining 7 (AD) is data, R/W = 1 for read, 0 for write, AD = address or index register 
CBS <= SPI_MSG;
SPI_CS <= CS;
SPI_MOSI <= MOSI;

---- data info ----
-- can be accessed using the cont. read if all 16 bits are required, ref. datasheet --
-- GYRO --
-- X_L X22, X_H X23
-- Y_L X24, Y_H X25
-- Z_L X26, Z_H X27

-- ACCELEROMETER --
-- X_L X28, X_H X29
-- Y_L X2A, Y_H X2B
-- Z_L X2C, Z_H X2D


-- actual data part --
process(CLK_SPI, CLK, getSample)
variable CLK_COUNT : integer range 0 to MSG_PERIOD := MSG_PERIOD;
-- var to make sure you only pulse once
variable pulsed : boolean := false;
begin
    if rising_edge(CLK) then 
        output_updated <= '0';
        -- signal new message 
        if CLK_COUNT = MSG_DATA_END+1 AND pulsed = false then
            pulsed := true;
            output_updated <= '1';
        elsif  CLK_COUNT = 0 then
            pulsed := false;           
        end if;
    end if;
    if rising_edge(CLK_SPI) then
        -- increment counter --
        if CLK_COUNT < MSG_PERIOD then 
            CLK_COUNT := CLK_COUNT + 1;
        end if;
        -- put data on bus
        if CLK_COUNT = MSG_DATA_END+1 then
            output <= data;
        end if;
        if CLK_COUNT >= MSG_PERIOD and getSample = '1' then
            CLK_COUNT := 0;            
        end if;
     
        -- process the msg --
        if CLK_COUNT >= MSG_DATA_START and CLK_COUNT <= MSG_DATA_END then
            -- recieve the data
            data <= data(6 downto 0) & SPI_MISO;
        end if;
    end if;
    if falling_edge(CLK_SPI) then
    -- send commands on falling edge
        if CLK_COUNT = 0 then
            -- drive CS low to initiate communication  
            CS <= '0';
            -- drive mosi high as startbit
            MOSI <= '1';  
        elsif CLK_COUNT >= MSG_CS_START and CLK_COUNT <= MSG_CS_END then
            -- send the Control selection
            MOSI <= CBS((MSG_CS_END - MSG_CS_START) - (CLK_COUNT - MSG_CS_START));
        end if;
        -- put CS low to prep for next read 
        if CLK_COUNT = MSG_DATA_END then
            CS <= '1';
        end if; 
    end if;
end process;


-- clk scaler to get less than 3.6MHz --
SPI_CLK <= CLK_SPI;
process(CLK)
variable scaler : integer range 0 to CLK_SCALING/2 := 0;
begin
    if rising_edge(CLK) then
        scaler := scaler + 1;
        if scaler >= CLK_SCALING/2 then 
            scaler := 0;
            CLK_SPI <= NOT(CLK_SPI);
        end if;
    end if;
end process;


end Behavioral;
