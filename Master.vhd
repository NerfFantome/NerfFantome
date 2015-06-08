----------------------------------------------------------------------------------
-- Company: Polytech Montpellier
-- Engineer: Daniel Souza/ Jean-Baptiste Verroken
-- 
-- Create Date:    15:41:13 04/29/2015 
-- Design Name: 		
-- Module Name:    Master - Behavioral 
-- Project Name: 	Nerf Fantome
-- Target Devices: XC3S1600E
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use ieee.numeric_std.all;

entity master is
	port(    
				clk : in  std_logic; 
				clke : in  std_logic;
	         rst : in  std_logic;
				led : out std_logic_vector(7 downto 0);
					  
			-- SDRAM pins out
				dram_clkp   : out   std_logic; -- 0 deg phase 100mhz clock going out to SDRAM chip
				dram_clkn   : out   std_logic; -- 180 deg phase version of dram_clkp
				dram_clke   : out   std_logic; -- clock enable, owned by the init module
				dram_cs     : out   std_logic; -- tied low upon powerup
				dram_cmd    : out   std_logic_vector(2 downto 0); -- this is the command vector <we_n,cas_n,ras_n>
				dram_bank   : out   std_logic_vector(1 downto 0); -- bank address
				dram_addr   : out   std_logic_vector(12 downto 0); -- row/col/mode register
				dram_dm     : out   std_logic_vector(1 downto 0); -- masks used for writing
				dram_dqs    : inout std_logic_vector(1 downto 0); -- strobes used for writing
				dram_dq     : inout std_logic_vector(15 downto 0); -- data lines

			-- debug signals
				debug_reg   : out std_logic_vector(7 downto 0);
			  
			-- analog card signals/ 25 bits in total
			
			-- Inverted Signals
				analog_ldac   			: out   	std_logic; -- equivalent to ldac on the datasheet
				analog_reset_strobe	: out		std_logic; -- Reset Strobe/ Corresponds to RS in the datasheet
				analog_chip_select	: out		std_logic; -- Signal to determine if the chip given by the current address will be used/ Corresponds to CS in the datasheet
			
			-- Non-inverted Signals	
				analog_data   			: inout   	std_logic_vector(11 downto 0); -- Data to be converted/ Corresponds to DB0...DB11 in the datasheet
				analog_address 		: out   	std_logic_vector(1 downto 0); -- DAC addresses/ Corresponds to A0 and A1 in the datasheet
				analog_read_write 	: out   	std_logic; -- Read_write = 1 - Read Enabled/ Read_write = 0 - write enabled/ Corresponds to R/W in the datasheet	
				analog_msb				: out		std_logic -- MSB = 0, Reset to 000h/ MSB = 1, Reset to 800h/ Corresponds to MSB in the datasheet
				
			  );
end master;

architecture impl of master is

	type controllerState is (testWrite, waitWrite, readMem, waitRead, sendToDAC);
	type readControl is (waitForWrite, readInit, readAttempt, waitRead, sendData, readDone);
	type writeControl is (writeInit, writeAttempt, waitWrite, writeDone);
	type DACFlowControl is (DACAWriteTrans, DACBWriteTrans, DACCWriteTrans, DACDWriteTrans, DACAWriteHold, DACBWriteHold, DACCWriteHold, DACDWriteHold, DACAReadHold
	,DACBReadHold, DACCReadHold, DACDReadHold, DACHoldAll, DACUpdateAll, DACResetAll, DACFlowOver);
	signal DACFlowState : DACFlowControl := DACAWriteTrans;
	signal readState : readControl := waitForWrite;
	signal writeState : writeControl := writeInit;

	signal clk_bufd        : std_logic;
	signal clk100mhz       : std_logic;
	signal dcm_locked      : std_logic;
	signal dcm_clk_000     : std_logic;
	signal dcm_clk_raw_000 : std_logic;
	
	signal op      : std_logic_vector(1 downto 0);
	signal address    : std_logic_vector(25 downto 0);
	signal op_ack  : std_logic;
	signal busy_n  : std_logic;
	signal data_i  : std_logic_vector(7 downto 0);
	signal debug   : std_logic_vector(7 downto 0);
	signal data_o : std_logic_vector(7 downto 0) := "00000000";
	signal data0Ready : std_logic := '0';
	signal data1Ready : std_logic := '0';
	signal dataSent : std_logic := '0';
	signal dataRequired : std_logic := '0';
	signal output8bits : std_logic_vector(7 downto 0);
	signal output4bits0 : std_logic_vector(3 downto 0);
	signal output4bits1 : std_logic_vector(3 downto 0);
	signal divOutput : std_logic := '0';
	signal deliveryAllowed : std_logic := '0';
	signal deliveryFinished : std_logic := '1';
	signal dacCount : integer range 0 to 3;
	signal counter : integer range 0 to 1023;
	signal clk1khz : std_logic := '0';
	signal readRequired : std_logic := '0';
	signal dataNeeded : std_logic := '0';
begin

	BUFG_CLK: BUFG
	port map(
		O => clk_bufd,
		I => clk
	);
	
	TB_DCM : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                             --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => 2,                     --  Can be any integer from 1 to 32 
      CLKFX_MULTIPLY => 2,                   --  Can be any integer from 1 to 32
      CLKIN_DIVIDE_BY_2 => FALSE,            --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => 20.0,                  --  Specify period of input clock
      CLKOUT_PHASE_SHIFT => "NONE",          --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "1X",                  --  Specify clock feedback of "NONE", "1X" or "2X" 
      DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      DLL_FREQUENCY_MODE => "LOW",           -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE,         --  Duty cycle correction, TRUE or FALSE
      PHASE_SHIFT => 0,                      --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => FALSE)                 --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      CLK0     => dcm_clk_raw_000,       -- 0 degree DCM CLK ouptput
      CLK90    => open,                  -- 90 degree DCM CLK output
      CLK180   => open,                  -- 180 degree DCM CLK output
      CLK270   => open,                  -- 270 degree DCM CLK output
      CLK2X    => clk100mhz,             -- 2X DCM CLK output
      CLK2X180 => open,                  -- 2X, 180 degree DCM CLK out
      CLKDV    => open,                  -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX    => open,                  -- DCM CLK synthesis out (M/D) 
      CLKFX180 => open,                  -- 180 degree CLK synthesis out
      LOCKED   => dcm_locked,            -- DCM LOCK status output (means feedback is in phase with main clock)
      PSDONE   => open,                  -- Dynamic phase adjust done output
      STATUS   => open,                  -- 8-bit DCM status bits output
      CLKFB    => dcm_clk_000,           -- DCM clock feedback
      CLKIN    => clk_bufd,              -- Clock input (from IBUFG, BUFG or DCM)
      PSCLK    => '0',                   -- Dynamic phase adjust clock input
      PSEN     => '0',                   -- Dynamic phase adjust enable input
      PSINCDEC => '0',                   -- Dynamic phase adjust increment/decrement
      RST      => '0'                    -- DCM asynchronous reset input
   );	
	
	DCM_BUF_000: BUFG
	port map(
		O => dcm_clk_000,
		I => dcm_clk_raw_000
	);
	
	SDRAM: entity work.sdram_controller 
	port map(
		clk100mhz => clk100mhz,
	   reset => rst,
	   op => op,
	   addr => address,
	   op_ack => op_ack,
	   busy_n => busy_n,
	   data_o => data_o,
		data_i => data_i,
	             
		dram_clkp => dram_clkp,
		dram_clkn => dram_clkn,
		dram_clke => dram_clke,
		dram_cs => dram_cs,
		dram_cmd => dram_cmd,
		dram_bank => dram_bank,
		dram_addr => dram_addr,
		dram_dm => dram_dm,
		dram_dqs => dram_dqs,
		dram_dq => dram_dq,
		
		debug_reg => debug
	);
	
	debug_reg <= debug;
	
	clkDivide: process(clk_bufd)
	begin
		if (rising_edge(clk_bufd) and clke = '1') then
			counter <= counter + 1;
			if(counter = 1000) then
				clk1khz <= not clk1khz;
				counter <= 0;
			end if;
		end if;
	end process;
	
	process(clk_bufd, clke,readState)
	begin
	
		if (rising_edge(clk_bufd) and clke = '1') then	
			case WriteState is
				when writeInit =>
					if (busy_n = '1') then
						writeState <= writeAttempt;
					end if;
				when writeAttempt =>
					op <= "10";
					address <= "0000000000"& x"6001";
					data_i <= "11110001";
					if (op_ack = '1') then
						writeState <= waitWrite;
					end if;
				when waitWrite =>
					if (busy_n = '1') then
						writeState <= writeDone;
						readState <= readInit;
					end if;
					op <= "00";
				when writeDone =>		
			end case;
			case readState is
				when waitForWrite =>
				
				when readInit =>
					if (busy_n = '1') then
						readState <= readAttempt;
					end if;
				when readAttempt =>
					op <= "01";
					address <= "0000000000"& x"6001";
					if (op_ack = '1') then
						readState <= waitRead;
					end if;
				when waitRead =>
					if (busy_n = '1') then
						readState <= sendData;
					end if;
					op <= "00";
				when sendData => --choose which DAC to send data to
					if(dacCount = 0) then
						output8bits <= data_o(7 downto 0);
						dacCount <= dacCount +1;
					elsif(dacCount = 1) then
						output4bits0 <= data_o(3 downto 0);
						analog_data <= output8bits&output4bits0;
						output4bits1 <= data_o(7 downto 4);
						dacCount <= dacCount +1;
						data0Ready <= '1';
						led <= analog_data(7 downto 0);
					elsif(dataSent <= '1') then
						output8bits <= data_o(7 downto 0);
						analog_data <= output4bits1&output8bits;
						dacCount <= 0;
						data1Ready <= '1';
						led <= analog_data(7 downto 0);
						readState <= readDone;
					end if;
				when readDone =>
					if(readRequired = '1') then
						readRequired <= '0';
						readState <= readInit;
					end if;
			end case;
			if(data0Ready = '1' and dataNeeded = '1') then
				data0Ready <= '0';
			end if;
			if(data1Ready = '1' and dataNeeded = '1') then
				data1Ready <= '0';
			end if;
			if(dataNeeded = '1' and data0Ready = '0' and data1Ready = '0') then
				readRequired <= '1';
			else
				case DACFlowState is
					--DAC A Selected--
					when DACAWriteTrans => 
						--Transparent--
						analog_read_write <= '0';
						analog_chip_select <= '0';
						analog_ldac <= '0';
						analog_reset_strobe <= '1';
						dataNeeded <= '1';
						analog_address <= "00";
						DACFlowState <= DACAWriteHold;
					when DACAWriteHold =>
						--Hold Input--
						dataNeeded <= '0';
						analog_ldac <= '1';
						DACFlowState <= DACAReadHold;
					when DACAReadHold =>
						--ReadBack data--
						analog_read_write <= '1';
						DACFlowState <= DACBWriteTrans;
						
					--DAC B Selected--
					when DACBWriteTrans => 
						--Transparent--
						analog_read_write <= '0';
						analog_chip_select <= '0';
						analog_ldac <= '0';
						analog_reset_strobe <= '1';
						dataNeeded <= '1';
						analog_address <= "01";
						DACFlowState <= DACBWriteHold;
					when DACBWriteHold =>
						--Hold Input--
						dataNeeded <= '0';
						analog_ldac <= '1';
						DACFlowState <= DACBReadHold;
					when DACBReadHold =>
						--ReadBack data--
						analog_read_write <= '1';
						DACFlowState <= DACCWriteTrans;
						
					--DAC C Selected--
					when DACCWriteTrans => 
						--Transparent--
						analog_read_write <= '0';
						analog_chip_select <= '0';
						analog_ldac <= '0';
						analog_reset_strobe <= '1';
						dataNeeded <= '1';
						analog_address <= "10";
						DACFlowState <= DACCWriteHold;
					when DACCWriteHold =>
						--Hold Input--
						dataNeeded <= '0';
						analog_ldac <= '1';
						DACFlowState <= DACCReadHold;
					when DACCReadHold =>
						--ReadBack data--
						analog_read_write <= '1';
						DACFlowState <= DACDWriteTrans;
						
					--DAC D Selected--
					when DACDWriteTrans => 
						--Transparent--
						analog_read_write <= '0';
						analog_chip_select <= '0';
						analog_ldac <= '0';
						analog_reset_strobe <= '1';
						dataNeeded <= '1';
						analog_address <= "11";
						DACFlowState <= DACDWriteHold;
					when DACDWriteHold =>
						--Hold Input--
						dataNeeded <= '0';
						analog_ldac <= '1';
						DACFlowState <= DACDReadHold;
					when DACDReadHold =>
						--ReadBack data--
						analog_read_write <= '1';
						DACFlowState <= DACUpdateAll;
					
					--Update All DACs--					
					when DACUpdateAll =>
						analog_chip_select <= '1';
						analog_ldac <= '0';
						analog_reset_strobe <= '1';
						DACFlowState <= DACHoldAll;
						
						
					--Hold All--	
					when DACHoldAll =>
						analog_ldac <= '1';
						DACFlowState <= DACResetAll;
						
						
					--Reset All--	
					when DACResetAll =>
						analog_reset_strobe <= '0';
						DACFlowState <= DACFlowOver;
						
						
					when DACFlowOver =>
					
				end case;	
			end if;
		end if;
	end process;

	
end impl;

