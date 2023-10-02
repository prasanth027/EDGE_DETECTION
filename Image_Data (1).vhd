----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.05.2020 18:16:26
-- Design Name: 
-- Module Name: Image_Data - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Image_Data is
 port (clk             : in  std_logic;
        reset           : in  std_logic;
        Pixel_fetch      : in  std_logic;  --- Starts fetching data ack
        Pixel_datacomp  : out std_logic;  --- Completed Extracting Data ACK to main controller
        data_pixel      : in  unsigned (7 downto 0);  ---- input data from the text file
        start_operation : in  std_logic;  ----- input ack to send the data from registers to
        pixel_out1       : out unsigned (23 downto 0);
         pixel_out2      : out unsigned (23 downto 0);
         pixel_out3      : out unsigned (23 downto 0)  ----- sends first 9 pixels for 3x3 convoluttion
        );
end Image_Data;

architecture Behavioral of Image_Data is
  type   state_type is (idle, fetch_data1,fetch_data2,fetch_data3,send_data);
  signal current_state, next_state : state_type;
  signal count, count_next         : unsigned(3 downto 0)   := (others => '0');
  signal register_matrix1,register_matrix_reg1,register_matrix2,register_matrix3,register_matrix_reg2,register_matrix_reg3: unsigned(23 downto 0):= (others => '0');

begin
  process(clk, reset, count)            -- The register process
  begin
    if reset = '1' then
      current_state <= idle;
      count         <= (others => '0');
       register_matrix1<= (others => '0');
       register_matrix2 <= (others => '0');
       register_matrix3<= (others => '0');
    elsif clk'event and clk = '1' then
      current_state <= next_state;
      count         <= count_next;
      register_matrix1 <= register_matrix_reg1;
      register_matrix2<= register_matrix_reg2;
      register_matrix3<= register_matrix_reg3;
    end if;
  end process;
  process(current_state,Pixel_fetch,register_matrix1,register_matrix2,register_matrix3,start_operation,count,data_pixel)
  begin
    next_state     <= current_state;
   Pixel_datacomp <= '0';
    pixel_out3     <= (others => '0');
    pixel_out1     <= (others => '0');
    pixel_out2    <= (others => '0');
    register_matrix_reg1 <= register_matrix1;
    register_matrix_reg2 <= register_matrix2;
    register_matrix_reg3 <= register_matrix3;
     count_next       <= count;
    case current_state is
      when idle =>
        if Pixel_fetch  = '1' then
          next_state <= fetch_data1;
        else
          next_state <= idle;
        end if;
      when fetch_data1 =>
        if count < "0011" then
          register_matrix_reg1 <= data_pixel & register_matrix1(23 downto 8) ;  ----- register for storing 3elements
          count_next      <= count + 1;
          next_state      <= fetch_data1;
        else
          register_matrix_reg1 <= register_matrix1;
           count_next      <= (others => '0');   
          next_state      <= fetch_data2;
        end if;
        when fetch_data2 =>
          if count < "0011" then
          register_matrix_reg2 <= data_pixel & register_matrix2(23 downto 8) ;  ----- register for storing 3 elements
          count_next      <= count + 1;
          next_state      <= fetch_data2;
        else
          register_matrix_reg2 <= register_matrix2;
         count_next      <= (others => '0');   
          next_state      <= fetch_data3;
        end if;
          when fetch_data3 =>
            if count < "0011" then
          register_matrix_reg3 <= data_pixel & register_matrix3(23 downto 8) ;  ----- register for storing 3 elements
          Pixel_datacomp  <= '0';
          count_next      <= count + 1;
          next_state      <= fetch_data3;
        else
          register_matrix_reg3 <= register_matrix3;
          Pixel_datacomp  <= '1';
          count_next      <= (others => '0');   
          next_state      <= send_data;
        end if;
      when send_data =>
        if start_operation = '1' then
         pixel_out1  <= register_matrix_reg1(23 downto 0);
         pixel_out2  <= register_matrix_reg2(23 downto 0);
         pixel_out3  <= register_matrix_reg3(23 downto 0);
          next_state <= idle;
        else
          pixel_out1  <= (others => '0');
          pixel_out2  <= (others => '0');
          pixel_out3  <= (others => '0');
          next_state <= send_data;
        end if;
             end case;
            end process;
end Behavioral;