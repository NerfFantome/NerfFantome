--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:31:26 03/04/2015
-- Design Name:   
-- Module Name:   P:/NerfFantome/SlaveTest.vhd
-- Project Name:  NerfFantome
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Slave
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SlaveTest IS
END SlaveTest;
 
ARCHITECTURE behavior OF SlaveTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Slave
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         address : OUT  std_logic_vector(21 downto 0);
         memOutput : IN  std_logic_vector(15 downto 0);
         dacInput : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    
	component Memory
	port(
		writeEnabled	:	in  STD_LOGIC;
		dataIn	: in  STD_LOGIC_VECTOR;
		dataOut	: out STD_LOGIC_VECTOR
	);	  
	end component;

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal memOutput : std_logic_vector(15 downto 0) := (others => '0');
	signal writeE:	STD_LOGIC;
 	--Outputs
   signal address : std_logic_vector(21 downto 0);
   signal dacInput : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Slave PORT MAP (
          rst => rst,
          clk => clk,
          address => address,
          memOutput => memOutput,
          dacInput => dacInput
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';
      wait for clk_period*10;
		writeEnabled <= writeE;
      -- insert stimulus here 

      wait;
   end process;

END;
