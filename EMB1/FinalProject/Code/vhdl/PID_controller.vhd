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
            ErrorAngle : in STD_LOGIC_VECTOR(7 downto 0);
            DesiredAngle : in STD_LOGIC_VECTOR(7 downto 0);
            
            MotorOutput : out STD_LOGIC_VECTOR(8 downto 0)
            );
end PID_controller;

architecture Behavioral of PID_controller is

    signal Paction, Iaction, Daction : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal IState : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal PreviousError : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    
    constant PGAIN : STD_LOGIC_VECTOR := "00000001";
    constant IGAIN : STD_LOGIC_VECTOR := "00000000";
    constant DGAIN : STD_LOGIC_VECTOR := "00000000";
    
    constant IactionMAX : STD_LOGIC_VECTOR(7 downto 0) := "11111111";
    constant IactionMIN : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    

begin

process(CLK)  
    variable Error : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    variable ispositive : STD_LOGIC := '0';
    variable TotalAction : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
    variable inclination : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
begin  
    -- PID Control.
    if rising_edge(CLK) then
        
        inclination := ErrorAngle+DesiredAngle;
       
        if inclination >= "10000000" then
            Error := inclination - "10000000";
            ispositive := '1';
        else
            Error := "10000000" - inclination;
            ispositive := '0';
        end if; 
                
       -- P action: 
        Paction <= error * PGAIN;
    
        -- I action:
        IState <= IState+error;
        Iaction <= IState * IGAIN;
        
        if Iaction > IactionMAX then
            Iaction <= IactionMAX;
            else if Iaction < IactionMIN then
                Iaction <= IactionMIN;
            end if;
        end if;
        
        
        if PreviousError > errorAngle then
            Daction <= (PreviousError - error) * DGAIN;
            TotalAction := Paction+Daction+Iaction;
        else 
            Daction <= (error - PreviousError) * DGAIN;
            TotalAction := Paction+Daction-Iaction;
        end if;
        
        if TotalAction >= "0011111111" then
            TotalAction := "0011111111";
        end if;
        
        --Convert Action into 8 bits
        MotorOutput <= ispositive & TotalAction(7 downto 0); 
        
    end if;

    end process;
        


end Behavioral;
