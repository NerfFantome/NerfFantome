----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:55:45 03/04/2015 
-- Design Name: 
-- Module Name:    Master - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Master is
port( 
		rst	:	in	STD_LOGIC;
		clk	:	in	STD_LOGIC;
		outputDAC	:	out	STD_LOGIC_VECTOR(11 downto 0)
);
end Master;

architecture Behavioral of Master is

--COMPONENT Slave

--        PORT(rst2	:	in	STD_LOGIC);
		  
--END COMPONENT;


begin

	process(clk,rst) begin
		
		outputDAC <= "111111111111";
	end process;

end Behavioral;
