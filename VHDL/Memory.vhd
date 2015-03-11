-- Simple generic RAM Model

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use NerfFantomePackage.all;

entity syncRam is
  port (
    clk	: in  STD_LOGIC;
    writeEnabled	:	in  STD_LOGIC;
    address	: in  STD_LOGIC_VECTOR(21 downto 0);
    dataIn	: in  STD_LOGIC_VECTOR(15 downto 0);
    dataOut	: out STD_LOGIC_VECTOR(15 downto 0)
  );
end entity syncRam;

architecture RTL of syncRam is
	Memory port map (clk,writeEnabled,address,dataIn,dataOut);
   type ramType is array (0 to (2**address'length)-1) of STD_LOGIC_VECTOR(dataIn'range);
   signal ram : ramType;
   signal readAddress : STD_LOGIC_VECTOR(address'range);

begin

  RamProc: process(clock) is

  begin
    if RISING_EDGE(clock) then
      if writeEnabled = '1' then
        ram(TO_INTEGER(unsigned(address))) <= dataIn;
      end if;
      readAddress <= address;
    end if;
  end process RamProc;

  dataout <= ram(TO_INTEGER(unsigned(readAddress)));

end architecture RTL;
