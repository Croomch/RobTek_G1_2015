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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity topmodule is
    Port ( 
    CLK : STD_LOGIC;
    
    MOTOR_DIR : STD_LOGIC_VECTOR(3 downto 0);
    MOTOR_SPEED : STD_LOGIC_VECTOR(1 downto 0);
    
    SPI_MISO : STD_LOGIC;
    SPI_MOSI : STD_LOGIC;
    SPI_CLK : STD_LOGIC;
    SPI_CS : STD_LOGIC;
    
    ALIVE : STD_LOGIC
    );
end topmodule;

architecture Behavioral of topmodule is
---- SIGNALS ----


---- CONSTANTS ----


---- COMPONENTS ----
COMPONENT SPI IS
Port ( 
           CLK : in STD_LOGIC;
    
           SPI_CLK : out STD_LOGIC;
           SPI_MOSI : out STD_LOGIC;
           SPI_MISO : in STD_LOGIC;
           SPI_CS : out STD_LOGIC;
           
           output : out STD_LOGIC_VECTOR (9 downto 0);
           output_updated : out STD_LOGIC;
           
           getSample : in STD_LOGIC;
           SPI_MSG : in STD_LOGIC_VECTOR (3 downto 0)
           );
END COMPONENT;


begin





end Behavioral;
