----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:02:41 02/10/2019 
-- Design Name: 
-- Module Name:    CRTC_registres - Behavioral 
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

entity CRTC_registres is
    Port ( clk : in  STD_LOGIC;
           ena : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           rs : in  STD_LOGIC;
           we : in  STD_LOGIC;
           interligne : out  STD_LOGIC;
			  select_mode : out	STD_LOGIC);
end CRTC_registres;

architecture Behavioral of CRTC_registres is

	constant INDEX_HT	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"0";
	constant INDEX_HD	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"1";
	constant INDEX_HSP	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"2";
	constant INDEX_HSW	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"3";
	constant INDEX_VT	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"4";
	constant INDEX_ADJ	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"5";
	constant INDEX_VD	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"6";
	constant INDEX_VSP	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"7";
	constant INDEX_IM	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"8";
	constant INDEX_SL	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"9";
	constant INDEX_CURST	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"a";
	constant INDEX_CUREND	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"b";
	constant INDEX_SA_H	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"c";
	constant INDEX_SA_L	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"d";
	constant INDEX_CUR_H	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"e";
	constant INDEX_CUR_L	: STD_LOGIC_VECTOR (4 downto 0)	:= '0' & x"f";
	constant INDEX_LP_H	: STD_LOGIC_VECTOR (4 downto 0)	:= '1' & x"0";
	constant INDEX_LP_L	: STD_LOGIC_VECTOR (4 downto 0)	:= '1' & x"1";

	-- 6845 registers R0-R17
	signal REG_HT		: STD_LOGIC_VECTOR (7 downto 0);
	signal REG_HD		: STD_LOGIC_VECTOR (7 downto 0);
	signal REG_HSP		: STD_LOGIC_VECTOR (7 downto 0);
	signal REG_HSW		: STD_LOGIC_VECTOR (3 downto 0);
	signal REG_VT		: STD_LOGIC_VECTOR (6 downto 0);
	signal REG_ADJ		: STD_LOGIC_VECTOR (4 downto 0);
	signal REG_VD		: STD_LOGIC_VECTOR (6 downto 0);
	signal REG_VSP		: STD_LOGIC_VECTOR (6 downto 0);
	signal REG_IM		: STD_LOGIC_VECTOR (1 downto 0);
	signal REG_SL		: STD_LOGIC_VECTOR (4 downto 0);
	signal REG_CURST	: STD_LOGIC_VECTOR (6 downto 0);
	signal REG_CUREND	: STD_LOGIC_VECTOR (4 downto 0);
	signal REG_SA_H		: STD_LOGIC_VECTOR (5 downto 0);
	signal REG_SA_L		: STD_LOGIC_VECTOR (7 downto 0);
	signal REG_CUR_H	: STD_LOGIC_VECTOR (5 downto 0);
	signal REG_CUR_L	: STD_LOGIC_VECTOR (7 downto 0);
	signal REG_LP_H		: STD_LOGIC_VECTOR (5 downto 0);
	signal REG_LP_L		: STD_LOGIC_VECTOR (7 downto 0);
	
	-- I/O address register
	signal REGIO_AR		: STD_LOGIC_VECTOR (7 downto 0);

begin

--ext_read:
process(clk)
begin
	if rising_edge(clk) then
		if ena = '1' and we = '0' then
			if rs = '0' then
				 data_out (7 downto 0) <= REGIO_AR;
			else
				case REGIO_AR (4 downto 0) is
					when INDEX_HT =>
						data_out <= REG_HT;
					when INDEX_HD =>
						data_out <= REG_HD;
					when INDEX_HSP =>
						data_out <= REG_HSP;
					when INDEX_HSW =>
						data_out(3 downto 0) <= REG_HSW;
						data_out(7 downto 4) <= "0000";
					when INDEX_SL =>
						data_out(4 downto 0) <= REG_SL;
						data_out(7 downto 5) <= "000";
					when INDEX_VT =>
						data_out(6 downto 0) <= REG_VT;
						data_out(7) <= '0';
					when INDEX_ADJ =>
						data_out(4 downto 0) <= REG_ADJ;
						data_out(7 downto 5) <= "000";
					when INDEX_VD =>
						data_out(6 downto 0) <= REG_VD;
						data_out(7) <= '0';
					when INDEX_VSP =>
						data_out(6 downto 0) <= REG_VSP;
						data_out(7) <= '0';
					when INDEX_CURST =>
						data_out(6 downto 0) <= REG_CURST;
						data_out(7) <= '0';
					when INDEX_CUREND =>
						data_out(4 downto 0) <= REG_CUREND;
						data_out(7 downto 5) <= "000";
					when INDEX_SA_H =>
						data_out(5 downto 0) <= REG_SA_H;
						data_out(7 downto 6) <= "00";
					when INDEX_SA_L =>
						data_out <= REG_SA_L;
					when INDEX_CUR_H =>
						data_out(5 downto 0) <= REG_CUR_H;
						data_out(7 downto 6) <= "00";
					when INDEX_CUR_L =>
						data_out <= REG_CUR_L;
					when others =>
						null;
				end case;
			end if;
		end if;
	end if;
end process;

--ext_write:
process(clk)
begin
	if rising_edge(clk) then
		if ena = '1' and we = '1' then
			if rs = '0' then
				REGIO_AR <= data_in (7 downto 0);
			else
				case REGIO_AR (4 downto 0) is
					when INDEX_HT =>
						REG_HT <= data_in;
					when INDEX_HD =>
						REG_HD <= data_in;
					when INDEX_HSP =>
						REG_HSP <= data_in;
					when INDEX_HSW =>
						REG_HSW <= data_in(3 downto 0);
					when INDEX_SL =>
						REG_SL <= data_in(4 downto 0);
					when INDEX_VT =>
						REG_VT <= data_in(6 downto 0);
					when INDEX_ADJ =>
						REG_ADJ <= data_in(4 downto 0);
					when INDEX_VD =>
						REG_VD <= data_in(6 downto 0);
					when INDEX_VSP =>
						REG_VSP <= data_in(6 downto 0);
					when INDEX_CURST =>
						REG_CURST <= data_in(6 downto 0);
					when INDEX_CUREND =>
						REG_CUREND <= data_in(4 downto 0);
					when INDEX_SA_H =>
						REG_SA_H <= data_in(5 downto 0);
					when INDEX_SA_L =>
						REG_SA_L <= data_in;
					when INDEX_CUR_H =>
						REG_CUR_H <= data_in(5 downto 0);
					when INDEX_CUR_L =>
						REG_CUR_L <= data_in;
					when others =>
						null;
				end case;
			end if;
		end if;
	end if;
end process;

-- Test du registre REG_VT si mode interligne
-- Si mode interligne, alors REG_VT = $27, sinon mode graphic = $31
-- Test du resgistre REG_HT si 40 ou 80 caractères
process(clk)
begin
	if rising_edge(clk) then
		if REG_SL = "00111" then
			interligne <= '0';
		else
			interligne <= '1';
		end if;
		if REG_HT = x"31" then
			select_mode <= '0';
		else
			select_mode <= '1';
		end if;		
	end if;
end process;

end Behavioral;

