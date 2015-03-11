----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:43:33 03/04/2015 
-- Design Name: 
-- Module Name:    NerfFantome - Behavioral 
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

entity NerfFantome is
port(     : in std_logic_vector(3 downto 0);  --4 bit input 1
            num2 :      in std_logic_vector(3 downto 0);  -- 4 bit input 2
            sum : out std_logic_vector(3 downto 0);   -- 4 bit sum
           carry :  out std_logic   -- carry out.
);
end NerfFantome;

architecture Behavioral of NerfFantome is
signal c0,c1,c2,c3 : std_logic := '0';
begin


end Behavioral;