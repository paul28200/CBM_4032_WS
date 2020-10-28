----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:23:16 03/23/2019 
-- Design Name: 
-- Module Name:    Gestion_SPI_Flash - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gestion_SPI_Flash is
				Port (
				 clk      : in std_logic;
				 rst      : in std_logic;
				 spi_clk  : buffer std_logic;
				 spi_cs   : out std_logic;
				 spi_din  : in std_logic;
				 spi_dout : out std_logic;
				 data_read : out std_logic_vector(7 downto 0);
				 start_address : in std_logic_vector(23 downto 0);
				 ask_read_data : in std_logic;	-- 1 = ask for reading value in memory, 0 to ackknowledge
				 data_ready : out std_logic);				 
end Gestion_SPI_Flash;

architecture Behavioral of Gestion_SPI_Flash is


component spi_ctrl port (
				 clk_in      : in std_logic;
				 rst      : in std_logic;
				 spi_clk  : buffer std_logic;
				 spi_cs   : out std_logic;
				 spi_din  : in std_logic;
				 spi_dout : out std_logic;
				 sel      : in std_logic;
				 wr      : in std_logic;
				 addr     : in std_logic_vector (2 downto 0);	--000=data, 001=reg, 010=add_l, 011=add_m, 100=add_h
				 d_in     : in std_logic_vector (7 downto 0);
				 d_out    : out std_logic_vector (7 downto 0)
			  );
end component;

-- FLASH commands
constant NOP  : std_logic_vector (7 downto 0) := x"FF";  -- no cmd to execute
constant WREN : std_logic_vector (7 downto 0) := x"06";  -- write enable
constant WRDI : std_logic_vector (7 downto 0) := x"04";  -- write disable
constant RDSR : std_logic_vector (7 downto 0) := x"05";  -- read status reg
constant WRSR : std_logic_vector (7 downto 0) := x"01";  -- write stat. reg
constant RDCMD: std_logic_vector (7 downto 0) := x"03";  -- read data
constant F_RD : std_logic_vector (7 downto 0) := x"0B";  -- fast read data
constant PP :   std_logic_vector (7 downto 0) := x"02";  -- page program
constant SE :   std_logic_vector (7 downto 0) := x"D8";  -- sector erase
constant BE :   std_logic_vector (7 downto 0) := x"C7";  -- bulk erase
constant DP :   std_logic_vector (7 downto 0) := x"B9";  -- deep power down
constant RES :  std_logic_vector (7 downto 0) := x"AB";  -- read signature

-- States Definition
type state_t is (S0, S1, S2, S3, S4, S5, S6, S7, S8);
signal state : state_t;

-- Signals
signal sel: std_logic;
signal wr: std_logic;
signal addr: std_logic_vector (2 downto 0);
signal d_in, d_out : std_logic_vector(7 downto 0);

-- Two counters;
signal spi_clk_cnt, spi_clk_cnt_next: std_logic_vector (5 downto 0);
signal locations_cnt, locations_cnt_next: std_logic_vector (3 downto 0);

-- this is a signal that triggers re-setting counter1 to
-- the magic number 32, from where reading a new memory
-- location begins;
signal reset_spi_clk_cnt_to_32 : std_logic;

begin

	Inst_Flash_SPI : spi_ctrl port map(
		 clk_in   => clk,
		 rst      => rst,
		 spi_clk  => spi_clk,
		 spi_cs   => spi_cs,
		 spi_din  => spi_din,
		 spi_dout => spi_dout,
		 sel      => sel,
		 wr      => wr,
		 addr     => addr,
		 d_in     => d_in,
		 d_out    => d_out
	  );

-- counter that monitors chunks of 8 spi clocks;
counter1: process (rst, spi_clk, reset_spi_clk_cnt_to_32)
begin
	if rst = '1' then
		spi_clk_cnt <= "000000";
	elsif reset_spi_clk_cnt_to_32 = '1' then
		spi_clk_cnt <= "100000";
	elsif falling_edge (spi_clk) then
		spi_clk_cnt <= spi_clk_cnt + 1;	
	end if;
end process;

-- Read process
process (clk)
begin
	if clk='1' and clk'event then
		if rst='1' then
			state <= S0;
		else
			reset_spi_clk_cnt_to_32 <= '0';
			case state is
				when S0 =>	
					data_ready <= '0';
					addr <= "000"; wr <= '0'; d_in <= NOP;
					if ask_read_data ='1' then					
						sel <= '1'; 
							state <= S1;
					else
						sel <= '0';
							state <= S0;							
					end if;
				when S1 => -- the command 
					-- NOTE: there is a tricky subtlety about SPI controller in that
					-- here, I tell SPI controller that the command that needs to be
					-- communicated to the flash memory chip will be a reading from
					-- the chip, BUT, from the perspective of the application logic
					-- that talks to the SPI controller, the application logic "writes"
					-- something on d_in; that is why the bits formed by sel&addr&wr
					-- will be used to set a writing activity signal, wr_data, inside
					-- the SPI controller code spi_ctrl.vhd;
					-- NOTE: the notations all over the code are with the meaning that
					-- the SPI controller transmits (tx_) or receives (rx_) and the 
					-- aplication logic which uses the SPI controller, reads (rd_) or 
					-- writes (wr_) into the controller;
					data_ready <= '0';
					sel <= '1'; 
					addr <= "001"; -- tells the spi_ctrl this is a command 
					wr <= '1';
					d_in <= RDCMD; -- read command	 
					if spi_clk_cnt < "001000" then -- it takes 8 spi_clk ticks to transmit command 
						state <= S1;
					else
						state <= S2;
					end if;
				when S2 => -- address high 
					data_ready <= '0';
					sel <= '1'; 
					addr <= "100"; -- tells the spi_ctrl this is high byte of address in Flash
					wr <= '1';
					d_in <= start_address(23 downto 16); -- high byte of address	
					if spi_clk_cnt < "010000" then -- 8+8=16 more clock cycles 
						state <= S2;
					else
						state <= S3;
					end if;
				when S3 => -- address mid 
					data_ready <= '0';
					sel <= '1'; 
					addr <= "011"; -- tells the spi_ctrl this is mid byte of address in Flash
					wr <= '1';
					d_in <= start_address(15 downto 8); -- mid byte of address	  
					if  spi_clk_cnt < "011000" then -- 16+8=24
						state <= S3;
					else
						state <= S4;
					end if;
				when S4 => -- address low 
					data_ready <= '0';
					sel <= '1'; 
					addr <= "010"; -- tells the spi_ctrl this is low byte of address in Flash
					wr <= '1';
					d_in <= start_address(7 downto 0); -- low byte of address 
					if spi_clk_cnt < "100000" then -- 24+8=32
						state <= S4;
					else
						state <= S5;
					end if;
				when S5 => -- memory data is being received	 
					data_ready <= '0';
					sel <= '1'; addr <= "001"; wr <= '0'; d_in <= NOP;
					if  spi_clk_cnt < "101000" then -- 32+8=40
						state <= S5;
					else
						state <= S6;
					end if;
				when S6 => 
					-- at this time the contents of currently read memory location should've been 
					-- transmitted via SPI from Flash to the SPI controller; that is true, but
					-- we need a few more cycles to have basically the info going:
					-- rx_sreg --> rx_data --> d_out == leds_next --> leds
					data_ready <= '0';
					sel <= '1'; addr <= "001"; wr <= '0'; d_in <= NOP;	
					if d_out(2) = '0' then
						state <= S6;
					else
						-- If the reg bit is ready then next step
						sel <= '1'; addr <= "000"; wr <= '0'; d_in <= NOP;
						state <= S7;
					end if;
				when S7 => 
					data_read <= d_out;
					data_ready <= '1';
					
					if ask_read_data ='0' then	-- Go to next step only if data is aknowledged by receiver
						state <= S8;
					else
						state <= S7;
					end if;
				when S8 => 
					data_ready <= '0';
					addr <= "000"; wr <= '0'; d_in <= NOP;
					-- NOTE: locations_cnt is the one that keeps track - in this
					-- hard coded manner - of how many locations we want to read;
					-- NOTE on the Atlys board only the content of the last memory
					-- location will be displayed; well, in fact each, but they are
					-- displayed at high frequency and we cannot see it :);
					if ask_read_data ='1' then	
						-- reset counter1 to 32 and go back to state S5 to start
						-- receiving the contets of the next memory location;
						-- this is done by setting reset_spi_clk_cnt_to_32
						-- which triggers the counter reset in a different process;
						-- NOTE: you should study this (and convince yourself about it) with the
						-- Aldec-HDL simulations;
						reset_spi_clk_cnt_to_32 <= '1';
						sel <= '1'; 
						state <= S5; 
					else   
						reset_spi_clk_cnt_to_32 <= '0';
						sel <= '0';
						state <= S8;
					end if;				
					
			end case;
		end if;
	end if;
end process;


end Behavioral;



