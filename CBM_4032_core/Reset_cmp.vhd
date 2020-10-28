----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:10:52 01/13/2019 
-- Design Name: 
-- Module Name:    Reset - Behavioral 
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

entity Reset_cmp is
    Port ( clk, bouton_rst, done : in  STD_LOGIC;
         reset_0, reset, reset_n : out  STD_LOGIC);
end Reset_cmp;

architecture Behavioral of Reset_cmp is

signal compteur : integer range 0 to 500000:=0;
signal rst_tmp : std_logic :='1';

begin

process(clk)
	begin
	if (clk'event and clk='1') then
		if compteur < 50000 and bouton_rst = '0' then
			compteur <= compteur + 1;
			rst_tmp <= '1';
			reset_0 <= '1';
		elsif bouton_rst = '0' and done = '0' then
			reset_0 <= '0';
			rst_tmp <= '1';
		elsif bouton_rst = '1' then
			compteur <= 0;
		else
			reset_0 <= '0';
			rst_tmp <= '0';
		end if;
	end if;
	reset <= rst_tmp;
	reset_n <= not rst_tmp;
	end process;


end Behavioral;

