----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:07:37 04/11/2019 
-- Design Name: 
-- Module Name:    RAM_Init - Behavioral 
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
use ieee.numeric_std.all;
	 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_Init is
    Port ( clk : in  STD_LOGIC;
			  select_mode : in STD_LOGIC;		-- Select 0 = CBM 4032, 1 = CBM 8032
           reset : in  STD_LOGIC;
           done : out  STD_LOGIC;
			  -- Parallel RAM
           address : out  STD_LOGIC_VECTOR (15 downto 0);
           data : out  STD_LOGIC_VECTOR (7 downto 0);
           ena : out  STD_LOGIC;
           wr : out  STD_LOGIC;
			  -- SPI Flash
			  spi_clk  : buffer STD_LOGIC;
			  spi_cs   : out STD_LOGIC;
			  spi_din  : in STD_LOGIC;
			  spi_dout : out STD_LOGIC);
end RAM_Init;

architecture Behavioral of RAM_Init is

	component Gestion_SPI_Flash Port (
				 clk      : in std_logic;
				 rst      : in std_logic;
				 spi_clk  : buffer std_logic;
				 spi_cs   : out std_logic;
				 spi_din  : in std_logic;
				 spi_dout : out std_logic;
				 data_read : out std_logic_vector(7 downto 0);
				 start_address : in std_logic_vector(23 downto 0);
				 ask_read_data : in std_logic;
				 data_ready : out std_logic);				 
	end component;
	
  TYPE CONTROL IS(power_up, load_data, enable, disable, init_done);
  SIGNAL state : CONTROL :=power_up;
  signal address_tmp : integer range 0 to 65535 :=0;
  
  signal ask_data_from_Flash, data_Flash_ready : std_logic;
  signal data_read_Flash : std_logic_vector(7 downto 0);
  
  signal clk_count : INTEGER := 0; --event counter for timing


	-- start read address signal
	signal start_address: std_logic_vector (23 downto 0);

begin

	Inst_Gestion_SPI_Flash : Gestion_SPI_Flash Port map(
				 clk      => clk,
				 rst      => reset,
				 spi_clk  => spi_clk,
				 spi_cs   => spi_cs,
				 spi_din  => spi_din,
				 spi_dout => spi_dout,
				 data_read => data_read_Flash,
				 start_address => start_address,
				 ask_read_data => ask_data_from_Flash,
				 data_ready => data_Flash_ready);	

process(clk)
begin
if clk'event and clk='1' then
	if reset='1' then
		if select_mode = '0' then
			start_address <= x"008000";	-- ROM Data start at 64000 (M25P16) for a CBM 4032
		else
			start_address <= x"000000";	-- ROM Data start at 56000 (M25P16) for a CBM 8032
		end if;
		state <= power_up;
	else
		CASE state IS
			WHEN power_up =>
				done <= '0';
				ena <= '0';
				wr <= '0';
				data <= x"00";
				address_tmp <= 32768;
				address <= x"0000";
				ask_data_from_Flash <= '1';
				state <= load_data;
				
			WHEN load_data =>
				done <= '0';
				if data_Flash_ready ='1' then	-- Waiting for data read from SIP Flash
					ena <= '1';
					wr <= '1';
					data <= data_read_Flash;
					ask_data_from_Flash <= '0'; -- acknoledge data received
					address <= std_logic_vector(to_unsigned(address_tmp, 16));
					state <= enable;
				else
					state <= load_data;
				end if;
			WHEN enable =>
				done <= '0';
				wr <= '0';
				state <= disable;
			WHEN disable =>
				done <= '0';
				ena <= '0';
				wr <= '0';
				data <= x"00";
				address <= x"0000";
				if address_tmp < 65535 then
					if data_Flash_ready ='0' then
						ask_data_from_Flash <= '1';
						address_tmp <= address_tmp + 1;					
						state <= load_data;
					else
						state <= disable;
					end if;
				else
					state <= init_done;
				end if;
				
			WHEN init_done =>
				done <= '1';
				ena <= '0';
				wr <= '0';
				data <= x"00";
				address_tmp <= 0;
				address <= x"0000";
				state <= init_done;
				
				--test
--				if clk_count < 100000 then
--					clk_count <= clk_count + 1;
--				else
--					clk_count <= 0;
--					if address_tmp < 65535 then
--						address_tmp <= address_tmp + 1;
--					else
--						address_tmp <= 49152;
--					end if;
--				address <= conv_std_logic_vector(address_tmp, 16);
--				end if;
				
		END CASE;
	end if;
end if;

end process;

end Behavioral;

