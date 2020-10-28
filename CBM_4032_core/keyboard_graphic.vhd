-- ZX Spectrum for Altera DE1
--
-- Copyright (c) 2009-2011 Mike Stirling
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without 
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

-- PS/2 scancode to 8032 matrix conversion
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keyboard is
port (
	CLK			:	in	std_logic;
	nRESET		:	in	std_logic;

	-- PS/2 interface
	PS2_CLK		:	in	std_logic;
	PS2_DATA	:	in	std_logic;
	
	-- CPU address bus (row)
	A			:	in	std_logic_vector(3 downto 0);
	-- Column outputs to ULA
	KEYB		:	out	std_logic_vector(7 downto 0)
	);
end keyboard;

architecture rtl of keyboard is

-- PS/2 interface
component ps2_intf is
generic (filter_length : positive := 8);
port(
	CLK			:	in	std_logic;
	nRESET		:	in	std_logic;
	
	-- PS/2 interface (could be bi-dir)
	PS2_CLK		:	in	std_logic;
	PS2_DATA	:	in	std_logic;
	
	-- Byte-wide data interface - only valid for one clock
	-- so must be latched externally if required
	DATA		:	out	std_logic_vector(7 downto 0);
	VALID		:	out	std_logic;
	ERROR		:	out	std_logic
	);
end component;

-- Interface to PS/2 block
signal keyb_data	:	std_logic_vector(7 downto 0);
signal keyb_valid	:	std_logic;
signal keyb_error	:	std_logic;

-- Internal signals
type key_matrix is array (10 downto 0) of std_logic_vector(7 downto 0);
signal keys		:	key_matrix;
signal release	:	std_logic;
signal extended	:	std_logic;
begin	

	ps2 : ps2_intf port map (
		CLK, nRESET,
		PS2_CLK, PS2_DATA,
		keyb_data, keyb_valid, keyb_error
		);

	-- Output addressed row to ULA
	KEYB <= keys(0) when A = x"0" else
		keys(1) when A = x"1" else
		keys(2) when A = x"2" else
		keys(3) when A = x"3" else
		keys(4) when A = x"4" else
		keys(5) when A = x"5" else
		keys(6) when A = x"6" else
		keys(7) when A = x"7" else
		keys(8) when A = x"8" else
		keys(9) when A = x"9" else
		keys(10) when A = x"A" else
		(others => '1');

	process(nRESET,CLK)
	begin
		if nRESET = '0' then
			release <= '0';
			extended <= '0';
			
			keys(0) <= (others => '1');
			keys(1) <= (others => '1');
			keys(2) <= (others => '1');
			keys(3) <= (others => '1');
			keys(4) <= (others => '1');
			keys(5) <= (others => '1');
			keys(6) <= (others => '1');
			keys(7) <= (others => '1');
			keys(8) <= (others => '1');
			keys(9) <= (others => '1');
			keys(10) <= (others => '1');			
		elsif rising_edge(CLK) then
			if keyb_valid = '1' then
				if keyb_data = X"e0" then
					-- Extended key code follows
					extended <= '1';
				elsif keyb_data = X"f0" then
					-- Release code follows
					release <= '1';
				else
					-- Cancel extended/release flags for next time
					release <= '0';
					extended <= '0';
				
					case keyb_data & extended is									
					-- Qwerty Keyboard
					when X"16"&'0' => keys(0)(0) <= release; -- !
					when X"26"&'0' => keys(0)(1) <= release; -- #
					when X"2E"&'0' => keys(0)(2) <= release; -- %
					when X"3D"&'0' => keys(0)(3) <= release; -- &
					when X"46"&'0' => keys(0)(4) <= release; -- (
					when X"0E"&'0' => keys(0)(5) <= release; -- Left Arrow
					when X"14"&'1' => keys(0)(6) <= release; -- Clr/Home
					when X"74"&'1' => keys(0)(7) <= release; -- Horiz_Crsr
					when X"6B"&'1' => keys(0)(7) <= release; -- Shift_Horiz_Crsr
											keys(8)(5) <= release;
											
					when X"1E"&'0' => keys(1)(0) <= release; -- "				
					when X"25"&'0' => keys(1)(1) <= release; -- $				
					when X"36"&'0' => keys(1)(2) <= release; -- '				
					when X"3E"&'0' => keys(1)(3) <= release; -- \
					when X"45"&'0' => keys(1)(4) <= release; -- )			
--					when X""&'1' => keys(1)(5) <= release; -- 
					when X"72"&'1' => keys(1)(6) <= release; -- Vert_Crsr
					when X"75"&'1' => keys(1)(6) <= release; -- Shift_Vert_Crsr
											keys(8)(5) <= release;
					
					when X"66"&'0' => keys(1)(7) <= release; -- Backspace
					
					when X"15"&'0' => keys(2)(0) <= release; -- Q
					when X"24"&'0' => keys(2)(1) <= release; -- E
					when X"2C"&'0' => keys(2)(2) <= release; -- T
					when X"3C"&'0' => keys(2)(3) <= release; -- U
					when X"44"&'0' => keys(2)(4) <= release; -- O
					when X"4E"&'0' => keys(2)(5) <= release; -- Top Arrow
					when X"6C"&'0' => keys(2)(6) <= release; -- 7
					when X"7D"&'0' => keys(2)(7) <= release; -- 9
					
					when X"1D"&'0' => keys(3)(0) <= release; -- W
					when X"2D"&'0' => keys(3)(1) <= release; -- R
					when X"35"&'0' => keys(3)(2) <= release; -- Y
					when X"43"&'0' => keys(3)(3) <= release; -- I
					when X"4D"&'0' => keys(3)(4) <= release; -- P
--					when X""&'0' => keys(3)(5) <= release; -- 
					when X"75"&'0' => keys(3)(6) <= release; -- 8
					when X"4A"&'1' => keys(3)(7) <= release; -- /
					
					when X"1C"&'0' => keys(4)(0) <= release; -- A
					when X"23"&'0' => keys(4)(1) <= release; -- D
					when X"34"&'0' => keys(4)(2) <= release; -- G
					when X"3B"&'0' => keys(4)(3) <= release; -- J
					when X"4B"&'0' => keys(4)(4) <= release; -- L
--					when X""&'0' => keys(4)(5) <= release; -- 
					when X"6B"&'0' => keys(4)(6) <= release; -- 4
					when X"74"&'0' => keys(4)(7) <= release; -- 6

					when X"1B"&'0' => keys(5)(0) <= release; -- S
					when X"2B"&'0' => keys(5)(1) <= release; -- F
					when X"33"&'0' => keys(5)(2) <= release; -- H
					when X"42"&'0' => keys(5)(3) <= release; -- K
					when X"49"&'0' => keys(5)(4) <= release; -- :
--					when X""&'1' => keys(5)(5) <= release; -- 
					when X"73"&'0' => keys(5)(6) <= release; -- 5
					when X"7C"&'0' => keys(5)(7) <= release; -- *
					
					when X"1A"&'0' => keys(6)(0) <= release; -- Z
					when X"21"&'0' => keys(6)(1) <= release; -- C
					when X"32"&'0' => keys(6)(2) <= release; -- B
					when X"3A"&'0' => keys(6)(3) <= release; -- M
					when X"4C"&'0' => keys(6)(4) <= release; -- ;
					when X"5A"&'0' => keys(6)(5) <= release; -- Return
					when X"5A"&'1' => keys(6)(5) <= release; -- Return num
					when X"69"&'0' => keys(6)(6) <= release; -- 1
					when X"7A"&'0' => keys(6)(7) <= release; -- 3
					
					when X"22"&'0' => keys(7)(0) <= release; -- X
					when X"2A"&'0' => keys(7)(1) <= release; -- V
					when X"31"&'0' => keys(7)(2) <= release; -- N
					when X"41"&'0' => keys(7)(3) <= release; -- ,
					when X"4A"&'0' => keys(7)(4) <= release; -- ?
					when X"76"&'0' => keys(7)(5) <= release; -- Escape
					when X"72"&'0' => keys(7)(6) <= release; -- 2
					when X"79"&'0' => keys(7)(7) <= release; -- +
										
					when X"12"&'0' => keys(8)(0) <= release; -- Left Shift
					when X"58"&'0' => keys(8)(0) <= '0'; 	-- Shift Lock
					when X"1F"&'1' => keys(8)(1) <= release; -- @
					when X"5B"&'0' => keys(8)(2) <= release; -- ]
					when X"0D"&'0' => keys(8)(3) <= release; -- Tab
					when X"5D"&'0' => keys(8)(4) <= release; -- >
					when X"59"&'0' => keys(8)(5) <= release; -- Right Shift
					when X"70"&'0' => keys(8)(6) <= release; -- 0
					when X"7B"&'0' => keys(8)(7) <= release; -- -
					
					when X"27"&'1' => keys(9)(0) <= release; -- Reverse
					when X"54"&'0' => keys(9)(1) <= release; -- [
					when X"29"&'0' => keys(9)(2) <= release; -- Space
					when X"52"&'0' => keys(9)(3) <= release; -- <
					when X"77"&'0' => keys(9)(4) <= release; -- Run/Stop
					when X"2F"&'1' => keys(9)(5) <= release; -- Repeat
					when X"71"&'0' => keys(9)(6) <= release; -- .
					when X"55"&'0' => keys(9)(7) <= release; -- =
				
					when others =>
						null;
					end case;
				end if;
			end if;
		end if;
	end process;

end architecture;
