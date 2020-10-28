----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:02:10 11/21/2018 
-- Design Name: 
-- Module Name:    Decodage_adresse - Behavioral 
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

entity Decodage_adresse is
						port (clk : in std_logic;
								adresse : in std_logic_vector(15 downto 0);
								data : out std_logic_vector(7 downto 0);								
								ena_user_RAM : out std_logic;
								read_only_RAM : out std_logic;
								data_user_RAM : in std_logic_vector(7 downto 0);
								ena_RAM_video : out std_logic;		--8000-87FF
								data_RAM_video : in std_logic_vector(7 downto 0);
								ena_RAM_9000 : out std_logic;		--A000-AFFF
								data_RAM_9000 : in std_logic_vector(7 downto 0);									
								ena_IO_clavier : out std_logic;		--E810-E813
								data_IO_clavier : in std_logic_vector(7 downto 0);
								ena_IEEE_488 : out std_logic;			--E820-E823
								data_IEEE_488 : in std_logic_vector(7 downto 0);
								ena_VIA : out std_logic;				--E840-E84F
								data_VIA : in std_logic_vector(7 downto 0);
								ena_CRTC : out std_logic;				--E880-E881
								data_CRTC : in std_logic_vector(7 downto 0);
								ena_Kernel : out std_logic;			--F000-FFFF
								data_Kernel : in std_logic_vector(7 downto 0));
end Decodage_adresse;

architecture Behavioral of Decodage_adresse is

signal ena_user_RAM_tmp, ena_RAM_video_tmp, ena_IO_clavier_tmp, ena_IEEE_488_tmp, ena_VIA_tmp, ena_CRTC_tmp, read_only_RAM_tmp : std_logic;
signal ena_RAM_9000_tmp : std_logic;

begin

process(clk)
begin
	if clk ='1' and clk'event then
		--ena_user_RAM
		if not (adresse(15 downto 11) = "10000") and not (adresse(15 downto 11) = "11101") and not (adresse(15 downto 12) = "1001") then
			ena_user_RAM_tmp <= '1';
			data <= data_user_RAM;
			--Write authorized in SDRAM
			if adresse(15) = '0'							--user_RAM
				or adresse(15 downto 12) = "1001"	--ROM_4k_n1
				or adresse(15 downto 12) = "1010"	--ROM_4K_n2
--				or (adresse(15 downto 12) = "1011" or adresse(15 downto 13) = "110")	--ROM_Basic
--				or adresse(15 downto 11) = "11100"	--IO_routines
--				or adresse(15 downto 12) = "1111"	--Kernel
					then
				read_only_RAM_tmp <= '1';	
			else
				read_only_RAM_tmp <= '0';
			end if;
		else
			ena_user_RAM_tmp <= '0';
			read_only_RAM_tmp <= '0';
		end if;
		--ena_RAM_video 8000-87FF
		if adresse(15 downto 11) = "10000" then
			ena_RAM_video_tmp <= '1';
			data <= data_RAM_video;
		else
			ena_RAM_video_tmp <= '0';
		end if;
		--ena_RAM_9000 9000-9FFF
		if adresse(15 downto 12) = "1001" then
			ena_RAM_9000_tmp <= '1';
			data <= data_RAM_9000;
		else
			ena_RAM_9000_tmp <= '0';
		end if;
		--ena_IO_clavier E810-E813
		if adresse(15 downto 2) = "11101000000100" then
			ena_IO_clavier_tmp <= '1';
			data <= data_IO_clavier;
		else
			ena_IO_clavier_tmp <= '0';
		end if;
		--ena_IEEE_488 E820-E823
		if adresse(15 downto 2) = "11101000001000" then
			ena_IEEE_488_tmp <= '1';
			data <= data_IEEE_488;
		else
			ena_IEEE_488_tmp <= '0';
		end if;
		--ena_VIA E840-E84F
		if adresse(15 downto 4) = "111010000100" then
			ena_VIA_tmp <= '1';
			data <= data_VIA;
		else
			ena_VIA_tmp <= '0';
		end if;
		--ena_CRTC E880-E881
		if adresse(15 downto 1) = "111010001000000" then
			ena_CRTC_tmp <= '1';
			data <= data_CRTC;
		else
			ena_CRTC_tmp <= '0';
		end if;
	end if;
	
	ena_user_RAM 		<= ena_user_RAM_tmp;
	ena_RAM_video 		<= ena_RAM_video_tmp;
	ena_IO_clavier 	<= ena_IO_clavier_tmp;
	ena_IEEE_488		<= ena_IEEE_488_tmp;
	ena_VIA				<= ena_VIA_tmp;
	ena_CRTC				<= ena_CRTC_tmp;
	read_only_RAM		<= read_only_RAM_tmp;
	ena_RAM_9000		<= ena_RAM_9000_tmp;
	
end process;
						
end Behavioral;


--		ena_user_RAM <= '1' when not (adresse(15 downto 11) = "10000") and not (adresse(15 downto 11) = "11101") else '0';	--ena_user_RAM 0400-7FFF pour 32k
--		ena_RAM_video <= '1' when adresse(15 downto 11) = "10000" else '0';	--ena_RAM_video 8000-87FF
--		ena_IO_clavier <= '1' when adresse(15 downto 2) = "11101000000100" else '0';	--ena_IO_clavier E810-E813
--		ena_IEEE_488 <= '1' when adresse(15 downto 2) = "11101000001000" else '0';	--ena_IEEE_488 E820-E823
--		ena_VIA <= '1' when adresse(15 downto 4) = "111010000100" else '0';	--ena_VIA E840-E84F
--		ena_CRTC <= '1' when adresse(15 downto 1) = "111010001000000" else '0';
--		
--		data_tmp <= 	data_user_RAM when not ((adresse(15 downto 11) = "10000")) and not (adresse(15 downto 11) = "11101") else
--					data_RAM_video when adresse(15 downto 11) = "10000" else
--					data_IO_clavier when adresse(15 downto 2) = "11101000000100" else
--					data_IEEE_488 when adresse(15 downto 2) = "11101000001000" else
--					data_VIA when adresse(15 downto 4) = "111010000100" else
--					data_CRTC when adresse(15 downto 1) = "111010001000000";
--
--		read_only_RAM_tmp <= 	'1' when adresse(15) = '0' else	--user_RAM
--								'1' when adresse(15 downto 12) = "1001" else		--ROM_4k_n1
--								'1' when adresse(15 downto 12) = "1010" else	--ROM_4K_n2
--								'0' when (adresse(15 downto 12) = "1011" or adresse(15 downto 13) = "110") else	--ROM_Basic
--								'0' when adresse(15 downto 11) = "11100" else	--IO_routines
--								'0' when adresse(15 downto 12) = "1111" else '-';	--Kernel
