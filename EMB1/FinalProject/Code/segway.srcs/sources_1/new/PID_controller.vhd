----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2015 10:10:23 AM
-- Design Name: 
-- Module Name: PID_controller - Behavioral
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

entity PID_controller is
    Port (  CLK : in STD_LOGIC;
            errorAngle : in STD_LOGIC_VECTOR(7 downto 0);
            DesiredAngle : in STD_LOGIC_VECTOR(7 downto 0);
            
            MotorOutput : out STD_LOGIC_VECTOR(8 downto 0)
            );
end PID_controller;

architecture Behavioral of PID_controller is

    signal Paction, Iaction, Daction, TotalAction : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal IState : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal PreviousError : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    
    constant PGAIN : STD_LOGIC_VECTOR := "00000001";
    constant IGAIN : STD_LOGIC_VECTOR := "00000000";
    constant DGAIN : STD_LOGIC_VECTOR := "00000000";
    
    constant IactionMAX : STD_LOGIC_VECTOR(7 downto 0) := "11111111";
    constant IactionMIN : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    

begin
  
  process(CLK)
  
  begin  
    -- PID Control. 
    -- P action: 
    
    Paction <= errorAngle*PGAIN;
    
    -- I action:
    IState <= IState+errorAngle;
    Iaction <= IState * IGAIN;
    
    if Iaction > IactionMAX then
        Iaction <= IactionMAX;
        else if Iaction < IactionMIN then
            Iaction <= IactionMIN;
        end if;
    end if;
    
    
    if PreviousError > errorAngle then
        Daction <= (PreviousError - errorAngle) * DGAIN;
        TotalAction <= Paction+Daction+Iaction;
    else 
        Daction <= (errorAngle - PreviousError) * DGAIN;
        TotalAction <= Paction+Daction-Iaction;
    end if;
    
    --Convert Action into 8 bits
    
    end process;
    
    MotorOutput <= "0" & TotalAction; 

end Behavioral;