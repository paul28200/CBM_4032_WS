----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:09 06/04/2013 
-- Design Name: 
-- Module Name:    Clock_div - Behavioral 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clock_div_32MHz is
    Port ( clk_32MHz : in  STD_LOGIC;
			clk_16MHz : out  STD_LOGIC;
			clk_8MHz : out  STD_LOGIC;
			clk_4MHz : out  STD_LOGIC;
         clk_2MHz : out  STD_LOGIC;
			clk_1MHz : out  STD_LOGIC;
			phi2 : out STD_LOGIC);
end Clock_div_32MHz;

architecture Behavioral of Clock_div_32MHz is
	signal clk_16tmp : std_logic := '0';
	signal clk_8tmp : std_logic := '0';
	signal clk_4tmp : std_logic := '0';
	signal clk_2tmp : std_logic := '0';	
	signal clk_1tmp : std_logic := '0';
	signal phi2_tmp : std_logic := '0';
	signal count1MHz : integer range 0 to 16:= 0;

	signal clk_4M_en, p2_h, clk_1M_pulse : std_logic;

begin
	process(clk_32MHz)
	begin
		if (clk_32MHz'event and clk_32MHz='1') then
			if count1MHz >= 15 then
				clk_1tmp <= not clk_1tmp;	--Division encore par 2 ce qui fait 32
				clk_2tmp <= '0';	--Le clk_2MHz est à l'état bas après chaque transition de clk_1MHz
				clk_4tmp <= '0';
				clk_8tmp <= '0';
				clk_16tmp <= '0';
				count1MHz <= 0;
			else	
				clk_16tmp <= not clk_16tmp;
				if count1MHz = 3 or count1MHz = 7 or count1MHz = 11 then
					clk_4tmp <= not clk_4tmp;
				end if;		
				if not((count1MHz mod 2) = 0) then
					clk_8tmp <= not clk_8tmp;
				end if;
				if count1MHz = 7 then
					clk_2tmp <= '1';	--Le clk_2MHz est à l'état haut à mi-période de clk_1MHz
				end if;
				clk_1tmp <= clk_1tmp;
				count1MHz <= count1MHz + 1;
			end if;
			phi2_tmp <= clk_1tmp;
		end if;			
	end process;
	--Sorties des valeurs
	clk_1MHz <= clk_1tmp;
	clk_2MHz <= clk_2tmp;
	clk_4MHz <= clk_4tmp;
	clk_8MHz <= clk_8tmp;
	clk_16MHz <= clk_16tmp;
	phi2 <= clk_1tmp; --phi2_tmp;

	
end Behavioral;