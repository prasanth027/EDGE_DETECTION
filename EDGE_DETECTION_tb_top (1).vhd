library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.tb_pkg .all;


entity EDGE_DETECTION_tb_top is
end EDGE_DETECTION_tb_top;

architecture behavior of EDGE_DETECTION_tb_top is

component EDGE_DETECTION_top_top is
port (
	     clk     : in  std_logic;
       reset   : in  std_logic;
       start_fetching : in  std_logic;   --- Start button
       data_pixel      : in  unsigned (7 downto 0);
       read_start : out  std_logic;
       pixel_out   : out unsigned (7 downto 0);
       convol_out: out  std_logic
        );
end component;	
type state_type is (idle, inputfetch1,inputfetch2,inputfetch3,new_pixel,column_inc,delay,read_dataout,delay1);
type data_out is array (100100 downto 0) of unsigned(7 downto 0);
signal rdataout : data_out; 
signal current_state, next_state : state_type; 
signal clk_top, rst_top, convol_out_tb,read_start_tb: std_logic := '0';
signal input_pixel : unsigned(7 downto 0) := (others => '0');
signal  start_top: std_logic:='0';
signal pixel_each : unsigned(7 downto 0);
 signal check1: std_logic;
signal x_n,x, y_n,y, x1_n,x1,y1_n,y1,x2_n,x2,y2_n,y2,n_next,n,i,i_next,counter_current_read, counter_nxt_read,count1,countnext1,count11,countnext11,count,countnext : integer := 0;	

signal input_data : word_arr := GetCodeFromFile("/h/d6/y/pr1133ka-s/Desktop/binary_try2.txt");

       
  function out_text_serial ( input_srr: in data_out;  inputfilename: in string ) return std_logic is
    file outputfile_handle         : text;
    variable outputfileline : line;
    variable result            : std_logic;
    variable ww            : std_logic_vector(6 downto 0);
    variable i            : integer := 0;
    variable count : integer:= 100100;
    variable dig : std_logic_vector(7 downto 0);
	
  begin
      
    file_open(outputfile_handle, inputfilename ,  write_mode);
    while (i < count ) loop
      dig := std_logic_vector(input_srr(i));
      write(outputfileline, conv_integer(dig));
      writeline(outputfile_handle, outputfileline);
      i := i + 1;
    end loop;return result;
  end function;
 begin
 rst_top <= '1' after 1 ns,
         '0' after 150 ns;
	clk_top <= not (clk_top) after 250 ns;	  
	--start_top <= '1' after 3*period;	 
top: EDGE_DETECTION_top_top
   port map ( clk   => clk_top,     
          reset  => rst_top,   
          start_fetching   => start_top, 
          data_pixel =>  input_pixel,  
           pixel_out =>  pixel_each,
          read_start => read_start_tb,   
           convol_out  => convol_out_tb     
           );
	   tb_sequential: process(rst_top, clk_top)
begin
    if rst_top = '1' then
	  current_state <= idle;
	       x <= 0;
          y <= 0;
         x1 <= 0;
          y1 <= 0;
         x2 <= 0;
          y2 <= 0;
          n <= 0;
          i <= 0;
          counter_current_read <= 0;
          count1<= 0;
          count11<= 0;
          count <= 0;
     elsif clk_top 'event and clk_top = '1' then
        current_state <= next_state;
        x <= x_n;
          y <= y_n;
         x1 <= x1_n;
          y1 <= y1_n;
         x2 <= x2_n;
          y2 <= y2_n;
          n <= n_next;
          i <= i_next;
          counter_current_read <= counter_nxt_read;
          count1 <= countnext1;
          count11 <= countnext11;
          count <= countnext;
     end if;	
end process tb_sequential;

tb_comb: process(current_state, input_data, start_top,x,y,x1,y1,x2,y2,n,i,convol_out_tb,counter_current_read,read_start_tb,count1,count11,count) 
begin

next_state <= current_state;
 input_pixel <= (others => '0');
        x_n<= x;
          y_n <= y;
         x1_n <= x1;
          y1_n <= y1;
         x2_n <= x2;
          y2_n <= y2;
          n_next <= n;
          i_next <= i;
          countnext1 <= count1;
          countnext11 <= count11;
          countnext <= count;
case current_state is    
				 
when idle =>
      if (i < 1) then
        start_top <= '1';
       next_state <= delay;
      else
	     start_top <= '0';
	       next_state <= idle;
        end if;
when delay =>
      next_state <= inputfetch1;
when inputfetch1 =>
    if (x < 288 and y < 3 ) then
     input_pixel <= unsigned(input_data((n*288)+x));
       x_n <= x + 1;   
     y_n <= y + 1;    ---- counter for 3 elements in a row
    next_state <= inputfetch1;
    elsif(x < 288 and y = 3) then
    x_n <= x - 2;
    y_n <= 0;
   next_state <= inputfetch2;
    else
    x_n <= 0;
     y_n <= 0;
    next_state <= inputfetch2;
  end if;
when inputfetch2 =>
   if (x1 < 288 and y1 < 3 ) then
     input_pixel <= unsigned(input_data(((n+1)*288)+x1));
    x1_n <= x1 + 1;
    y1_n <= y1 + 1;
   next_state <= inputfetch2;
    elsif(x1 < 288 and y1 = 3) then
     x1_n <= x1 - 2;
    y1_n <= 0;
    next_state <= inputfetch3;
    else
    x1_n <= 0;
     y1_n <= 0;
    next_state <= inputfetch3;
   end if;
when inputfetch3 =>
   if (x2 < 288 and y2 < 3 ) then
     input_pixel <= unsigned(input_data(((n+2)*288)+x2));
    x2_n <= x2 + 1;
    y2_n <= y2 + 1;
     next_state <= inputfetch3;
    elsif(x2 < 288 and y2 = 3) then
     x2_n <= x2 - 2;
    y2_n <= 0;
    next_state <= new_pixel;
    else
    x2_n <= 0;
     y2_n <= 0;
    next_state <= new_pixel;
  end if;
when new_pixel =>
     if (convol_out_tb = '1' and count11 < 285 ) then
       countnext11 <= count11 +1;
      next_state <= delay;
    elsif (convol_out_tb = '1' and count11 = 285 ) then
      countnext11 <= 0;
      next_state <= column_inc;
     else
       next_state <= new_pixel;
      end if;
when column_inc  =>
     if (n < 349) then
       n_next <= n + 1;
       next_state <= inputfetch1;
       elsif (read_start_tb = '1' ) then
      next_state <= read_dataout;
       n_next <= 0;
       i_next <= i + 1;
     end if;
   when delay1 =>
     next_state <= read_dataout;
     when read_dataout =>  
     if (count1 = 0 and count < 9600) then
       countnext1 <= count1 +1;
       countnext <= count +1;
    next_state <= read_dataout;
    
     elsif (counter_current_read < 100100 and count1 < 8 and count1 /= 0) then
      rdataout(counter_current_read) <= pixel_each;
            counter_nxt_read <= counter_current_read + 1;
            countnext1 <= count1 +1;
         next_state <= read_dataout;
       elsif (counter_current_read < 100100 and count1 = 8) then  
        rdataout(counter_current_read) <= pixel_each;
           counter_nxt_read <= counter_current_read + 1;
            countnext1 <= 0;
        next_state <= read_dataout;
        elsif (counter_current_read < 100100 and count = 9600 and count1 = 0) then
       counter_nxt_read <= counter_current_read;
        countnext <= 0;
        next_state <= read_dataout;
      else 
         check1 <= out_text_serial(rdataout, "/h/d6/y/pr1133ka-s/Desktop/output_serial.txt");
          counter_nxt_read <= 0;
          next_state <= new_pixel;
        end if;
end case;
end process tb_comb;
end behavior;
