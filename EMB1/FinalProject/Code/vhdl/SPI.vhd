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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

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
           SPI_CONTROL : in STD_LOGIC_VECTOR (7 downto 0);
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
SIGNAL MSG : STD_LOGIC_vector (7 downto 0) := "00000000";
-- data recieved 
SIGNAL data : STD_LOGIC_vector (7 downto 0) := "00000000";


---- Constants ----
-- spi supports max of 10MHz
-- scale down with factor 6 to get = 8.33MHz < 10MHz max
CONSTANT CLK_SCALING : INTEGER := 100;
-- data msg info
CONSTANT MSG_CS_START : INTEGER := 0;
CONSTANT MSG_CS_END : INTEGER := 7;
CONSTANT MSG_DATAW_START : INTEGER := 8; -- write
CONSTANT MSG_DATAW_END : INTEGER := 15;
CONSTANT MSG_DATAR_START : INTEGER := 9; -- read
CONSTANT MSG_DATAR_END : INTEGER := 16;
-- how often restart to sample --
CONSTANT MSG_PERIOD : INTEGER := 17;

begin

-- first bit is R/W and remaining 7 (AD) is data, R/W = 1 for read, 0 for write, AD = address or index register 
CBS <= SPI_CONTROL;
MSG <= SPI_MSG;
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


-- notify arrival of data
process(CLK)
-- var to make sure you only pulse once
variable pulsed : boolean := false;
begin
if rising_edge(CLK) then 
    -- signal new message 
    if CS = '1' and pulsed = false then
        pulsed := true;
        output_updated <= '1';
    elsif  CS = '0' then
        pulsed := false;
        output_updated <= '0';           
    end if;
end if;
end process;

-- actual data part --
process(CLK_SPI)
variable CLK_COUNT : integer range 0 to MSG_PERIOD+1 := MSG_PERIOD;
begin
    if rising_edge(CLK_SPI) then
        -- increment counter --
        if CLK_COUNT <= MSG_PERIOD then 
            CLK_COUNT := CLK_COUNT + 1;
        elsif CLK_COUNT > MSG_PERIOD and getSample = '1' then
            CLK_COUNT := 0;
        else
            CLK_COUNT := MSG_PERIOD+1;             
        end if;
        -- put data on bus
        
        if CLK_COUNT >= MSG_CS_START and CLK_COUNT <= MSG_DATAR_END then
        -- put CS low to prep for next read
            CS <= '0';
        else
            CS <= '1';
        end if; 
        -- process the msg --
        if CLK_COUNT >= MSG_DATAR_START and CLK_COUNT <= MSG_DATAR_END then
            -- recieve the data
            data <= data(6 downto 0) & SPI_MISO;
        end if;
        if CLK_COUNT = MSG_DATAR_END + 1 then
            output <= data;
        end if;
    end if;
    if falling_edge(CLK_SPI) then
    -- send commands on falling edge
        if CLK_COUNT >= MSG_CS_START and CLK_COUNT <= MSG_CS_END then
            -- send the Control selection
            MOSI <= CBS((MSG_CS_END - MSG_CS_START) - (CLK_COUNT - MSG_CS_START));
        elsif CLK_COUNT >= MSG_DATAW_START and CLK_COUNT <= MSG_DATAW_END then
            MOSI <= MSG((MSG_DATAW_END - MSG_DATAW_START) - (CLK_COUNT - MSG_DATAW_START));
        end if;
    end if;
end process;


-- clk scaler to get less than 3.6MHz --
SPI_CLK <= CLK_SPI OR CS;
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
