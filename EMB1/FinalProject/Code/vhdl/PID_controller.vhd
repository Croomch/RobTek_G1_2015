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
use IEEE.numeric_std.all;
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

    signal Paction, Iaction, Daction : integer range 0 to 2047 := 0;
    signal IState : integer range 0 to 2047 := 0;
    signal PreviousError : integer range 0 to 2047 := 0;
    
    constant PGAIN : integer := 1;
    constant IGAIN : integer := 0;
    constant DGAIN : integer := 0;
    
    constant IactionMAX : integer := 511;
    constant IactionMIN : integer := 0;
    

begin

process(CLK)  
    variable Error : integer range 0 to 2047  := 0;
    variable ispositive : STD_LOGIC := '0';
    variable TotalAction : integer range 0 to 2047 := 0;
    variable inclination : integer range 0 to 2047 := 0;
    variable error_vec : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    variable TotalAction_vec : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
begin  
    -- PID Control.
    if rising_edge(CLK) then
               
        if errorAngle >= DesiredAngle then
            error_vec := errorAngle-DesiredAngle;
            Error := conv_integer(unsigned(error_vec));
            ispositive := '1';
        else
            error_vec := DesiredAngle-errorAngle;
            Error := conv_integer(unsigned(error_vec));
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
        
        if TotalAction >= 2047 then
            TotalAction := 2047;
        end if;
        
        --Convert Action into 8 bits
        totalAction_vec := std_logic_vector(to_unsigned(TotalAction,11)); 
        MotorOutput <= ispositive & totalAction_vec(10 downto 3); 
        
    end if;

    end process;
        


end Behavioral;
