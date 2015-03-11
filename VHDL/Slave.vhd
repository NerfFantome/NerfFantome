----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:55:59 03/04/2015 
-- Design Name: 
-- Module Name:    Slave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------
--------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use NerfFantomePackage.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Slave is

port(     
	rst	:	in	STD_LOGIC;
	clk	:	in	STD_LOGIC;
	address	:	out STD_LOGIC_VECTOR(21 downto 0);
	memOutput:	in	STD_LOGIC_VECTOR(15 downto 0);
	dacInput:	out STD_LOGIC_VECTOR(11 downto 0)
);
end Slave;

architecture Behavioral of Slave is


signal dataIn:	STD_LOGIC_VECTOR(15 downto 0);
signal writeE:	STD_LOGIC;
constant clkPeriod : time := 10 ns;

begin
	mem: Memory port map (
          clk,
			 writeE,
			 address,
			 dataIn,
			 dacInput
        );

	mainProcess: process
	begin
		address <= "0000000000000000000000";
		writeE <= '1';
		
		
	end process;

end Behavioral;


