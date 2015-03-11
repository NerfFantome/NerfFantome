library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package NerfFantome is
	component Memory
	port (
    clk	: in  STD_LOGIC;
    writeEnabled	:	in  STD_LOGIC;
    address	: in  STD_LOGIC_VECTOR(21 downto 0);
    dataIn	: in  STD_LOGIC_VECTOR(15 downto 0);
    dataOut	: out STD_LOGIC_VECTOR(15 downto 0)
	); 
	end component;
end NerfFantome;


package body NerfFantome is
     -- Definition of previously declared
        -- constants
        -- subprograms
     -- Declaration/definition of additional
        -- types and subtypes
        -- subprograms
        -- constants, signals and shared variables
end NerfFantome;
