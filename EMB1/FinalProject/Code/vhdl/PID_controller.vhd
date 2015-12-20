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

    
    constant PGAIN : integer := 50;
    constant SPEEDOFFSET : integer := 0;
    constant MAXERROR : integer := (256 * 256);
--    constant IGAIN : integer := 0;
    constant DGAIN : integer := 40;
    
--    constant IactionMAX : integer := 200;
--    constant IactionMIN : integer := -200;
     
    signal TotalAction_vec : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal ispositive : STD_LOGIC := '0';
        
    
begin

MotorOutput <= ispositive & totalAction_vec; 

process(CLK)  
    variable error : integer range 0 to MAXERROR  := 0;
    variable TotalAction : integer range -MAXERROR to MAXERROR := 0;
    variable error_vec : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    variable Paction, Daction : integer range 0 to MAXERROR := 0;
--    variable Iaction : integer range -MAXERROR to MAXERROR := 0;
    variable PreviousError : integer range 0 to 255 := 0;
--    variable IState : integer range -1023 to 1024 := 0;
            
begin  
    -- PID Control.
    if rising_edge(CLK) then
               
        if ErrorAngle >= DesiredAngle then
            error_vec := ErrorAngle - DesiredAngle;
            ispositive <= '1';
--            IState := IState + error;               
        else
            error_vec := (DesiredAngle - ErrorAngle);
            ispositive <= '0';
--            IState := IState - error;                  
        end if; 
                
        -- P action: 
        error := conv_integer(unsigned(error_vec));
        
        Paction := error * PGAIN;
           
        -- I action:
--        Iaction := IState * IGAIN;
        
--        if Iaction > IactionMAX then
--            Iaction := IactionMAX;
--        elsif Iaction < IactionMIN then
--            Iaction := IactionMIN;
--        end if;
        
        
        Daction := (PreviousError - error) * DGAIN;
        PreviousError := error;
        
--        TotalAction := Paction - Daction - Iaction;
        TotalAction := Paction - Daction;
--        TotalAction := Paction;
        
        if TotalAction >= 255 then
            TotalAction := 255;
        elsif TotalAction <= 0 then
            TotalAction := 0;
        elsif TotalAction <= 20 then
            TotalAction := 20;
        end if;        
           
        --Convert Action into 8 bits
        totalAction_vec <= std_logic_vector(to_unsigned(TotalAction,8));         
    end if;
end process;

--process(CLK)  
--    variable Error : integer range -1023 to 1024  := 0;
--    variable ispositive : STD_LOGIC := '0';
--    variable TotalAction : integer range -1023 to 1024 := 0;
--    variable error_vec : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
--    variable TotalAction_vec : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
--begin  
--    -- PID Control.
--    if rising_edge(CLK) then
               
--        if errorAngle >= DesiredAngle then
--            error_vec := errorAngle-DesiredAngle;
--            Error := conv_integer(unsigned(error_vec));
--        else
--            error_vec := DesiredAngle-errorAngle;
--            Error := -conv_integer(unsigned(error_vec));
--        end if; 
                
--        -- P action: 
--        Paction <= error * PGAIN;
           
--        -- I action:
--        IState <= IState+error;
--        Iaction <= IState * IGAIN;
        
--        if Iaction > IactionMAX then
--            Iaction <= IactionMAX;
--            else if Iaction < IactionMIN then
--                Iaction <= IactionMIN;
--            end if;
--        end if;
        
        
--        Daction <= (PreviousError - error) * DGAIN;
--        PreviousError <= error;
        
--        TotalAction := Paction+Daction+Iaction;

        
--        if TotalAction >= 1024 then
--            TotalAction := 1024;
--        else if TotalAction <= -1023 then
--                 TotalAction := -1023;
--             end if;
--        end if;
        
--        if TotalAction < 0 then
--            TotalAction := -TotalAction;
--            ispositive := '0';
--        else
--            ispositive := '1';    
--        end if;
        
           
--        --Convert Action into 8 bits
--        totalAction_vec := std_logic_vector(to_unsigned(TotalAction,10)); 
--        MotorOutput <= ispositive & totalAction_vec(9 downto 2); 
        
--    end if;

--    end process;
        


end Behavioral;