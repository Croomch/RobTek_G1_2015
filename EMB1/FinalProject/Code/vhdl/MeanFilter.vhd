----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2015 04:27:44 PM
-- Design Name: 
-- Module Name: MeanFilter - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MeanFilter is
    Port ( 
        newdata_sig : in STD_LOGIC;
	newdata_array : in STD_LOGIC_VECTOR (7 downto 0);
	filtered : out STD_LOGIC_VECTOR (7 downto 0)
    );
end MeanFilter;

architecture Behavioral of MeanFilter is
	signal val1, val2, val3, val4, val5, val6, val7, val8 : STD_LOGIC_VECTOR (11 downto 0) := "000000000000";
    signal sumofvalues : STD_LOGIC_VECTOR(11 downto 0) := "000000000000"; 

begin

	process(newdata_sig)
	   variable dataConverted : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
	begin

	if rising_edge(newdata_sig) then
	
	if newdata_array(7) = '0' then
	   dataConverted := "11111111"-newdata_array;
	   dataConverted := "10000000"+newdata_array;
   else 
	   dataConverted := newdata_array;
   end if;


--	    val8 <= val7;
--	    val7 <= val6;
--	    val6 <= val5;
--	    val5 <= val4;
		val4 <= val3;
		val3 <= val2;
		val2 <= val1;
		val1(7 downto 0) <= dataConverted;
		
	end if;

	end process;

    	sumofvalues <= val4 + val3 + val2 + val1+ val5 + val6 + val7 +val8;
		filtered <= sumofvalues(9 downto 2);


end Behavioral;
