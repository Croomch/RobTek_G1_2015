----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2015 12:13:28
-- Design Name: 
-- Module Name: rom - Behavioral
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

entity rom is
    Port ( 
        CLK : in STD_LOGIC;
        address : in INTEGER RANGE 0 to 15;
        data_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
end rom;

architecture Behavioral of rom is

SIGNAL reg_address: INTEGER RANGE 0 to 15;
TYPE memory is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
SIGNAL rom:memory;
ATTRIBUTE ram_init_file: STRING;
ATTRIBUTE ram_init_file OF rom: Signal is "rom_init.hex";

begin

-- Register the address --
PROCESS(CLK)
BEGIN
    IF rising_edge(CLK) then
        reg_address <= address;
    end if;
END PROCESS;
-- get unregistered output --
data_out <= myrom(reg_address);

end Behavioral;
