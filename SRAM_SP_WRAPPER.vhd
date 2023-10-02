library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- -- ST_SPHDL_4800x64m16
--words = 4800
--bits  = 64

entity SRAM_SP_WRAPPER is
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (12 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (63 downto 0);
    DataxDO : out std_logic_vector (63 downto 0)
    );
end SRAM_SP_WRAPPER;


architecture rtl of SRAM_SP_WRAPPER is
  
  component ST_SPHDL_4800x64m16
    port (
        Q : OUT std_logic_vector(63 DOWNTO 0);
        RY : OUT std_logic;
        CK : IN std_logic;
        CSN : IN std_logic;
        TBYPASS : IN std_logic;
        WEN : IN std_logic;
        A : IN std_logic_vector(12 DOWNTO 0);
        D : IN std_logic_vector(63 DOWNTO 0)
       );  
  end component;

  signal LOW  : std_logic;
  signal HIGH : std_logic;

begin

  LOW  <= '0';
  HIGH <= '1';

-- mem2011
  DUT_ST_SPHDL_4800x64m16 : ST_SPHDL_4800x64m16
    port map(
      Q       => DataxDO,
      RY      => RYxSO,
      CK      => ClkxCI,
      CSN     => CSxSI,
      TBYPASS => LOW,
      WEN     => WExSI,
      A       => AddrxDI,
      D       => DataxDI
      );

end rtl;

