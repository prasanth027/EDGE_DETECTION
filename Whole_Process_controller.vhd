----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.05.2020 09:42:00
-- Design Name: 
-- Module Name: controller - Behavioral
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
use ieee.numeric_std.all;


entity controller is
 Port (clk     : in  std_logic;
       reset   : in  std_logic;
       start_fetching : in  std_logic;   --- Start button 
       Pixel_datacomp : in  std_logic;   --- Completed Extracting D plication completed ack
       start_operation : out  std_logic;
        start_operation_conv : out  std_logic; --- starts convolution process
       conv_mul : in  std_logic;
        convol_out: out  std_logic;
        Pixel_fetch : out  std_logic      --- Starts fetching data 
         
 );
end Controller;

architecture Behavioral of controller is
type state_type is (idle,enable,fetch,save_data,start_conv,delay);
signal current_state, next_state : state_type;
signal count,count_next: unsigned(18 downto 0);

begin
process(clk,reset)              -- The register process
begin
  if reset ='1' then
    current_state <= idle;
    count  <= (others => '0'); 
  elsif clk'event and clk = '1' then
    current_state <= next_state;
    count <= count_next ;
   end if;
end process;
asdd: process(current_state,count,start_fetching,Pixel_datacomp,conv_mul)
begin
 next_state <= current_state;
Pixel_fetch <= '0';
 start_operation <= '0';
 start_operation_conv <= '0';
  count_next <= count ;
 convol_out <= '0';
 case current_state is
 when idle =>               ---   starts the operation after receving start operation
   if start_fetching = '1' then
     next_state <= enable;
    else 
     next_state <= idle;
     end if;
  when enable =>             ---- sends control signal to fetch pixel data 
       Pixel_fetch <= '1';
        next_state <= fetch;  
  when fetch =>
      if Pixel_datacomp = '1'  then
     next_state <= delay; 
      else
        next_state <= fetch;
      end if;
    when delay =>          --- delay state to stop the racing 
        next_state <= start_conv; 
    when start_conv =>  
       start_operation <= '1';
       start_operation_conv <= '1';
        next_state <= save_data;
   when save_data =>
      if conv_mul = '1' and count < "11000011100000100" then
       convol_out <= '1';
       count_next <= count+1;
           next_state <= enable;
         else 
       convol_out  <= '0';
        count_next <= (others => '0');       
        next_state <= idle;
      end if;
    end case;
   end process;
end Behavioral;
