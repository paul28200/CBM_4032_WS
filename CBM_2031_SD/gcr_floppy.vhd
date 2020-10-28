---------------------------------------------------------------------------------
-- Commodore 1541 gcr floppy (read only) by Dar (darfpga@aol.fr) 02-April-2015
-- http://darfpga.blogspot.fr
--
-- produces GCR data, byte(ready) and sync signal to feed c1541_logic from current
-- track buffer ram which contains D64 data
--
-- Input clk 32MHz
--     
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity gcr_floppy is
port(
	clk32  : in  std_logic;
	do     : out std_logic_vector(7 downto 0);   -- disk read data
	di     : in std_logic_vector(7 downto 0);   	-- disk write data
	mode   : in  std_logic;                      -- read/write
	stp    : in  std_logic_vector(1 downto 0);   -- stepper motor control
	mtr    : in  std_logic;                      -- stepper motor on/off
	freq   : in  std_logic_vector(1 downto 0);   -- motor (gcr_bit) frequency
	sync_n : out std_logic;                      -- reading SYNC bytes
	byte_n : out std_logic;                      -- byte ready
	disk_id : in std_logic_vector(15 downto 0);	-- disk ID
	
	track       : in  std_logic_vector(5 downto 0);
	track_adr   : out std_logic_vector(12 downto 0);
	track_adr_w : out std_logic_vector(12 downto 0);
	track_data  : in  std_logic_vector(7 downto 0);
	track_data_w : out std_logic_vector(7 downto 0);
	track_wr		: out std_logic;
	track_ready : in  std_logic
);
end gcr_floppy;

architecture struct of gcr_floppy is

signal bit_clk_en  : std_logic;
signal sync_cnt    : std_logic_vector(5 downto 0) := (others => '0');
signal byte_cnt    : std_logic_vector(8 downto 0) := (others => '0');
signal byte_cnt_wr : std_logic_vector(8 downto 0) := (others => '0');
signal nibble      : std_logic := '0';
signal nibble_w    : std_logic := '0';
signal gcr_bit_cnt : std_logic_vector(3 downto 0) := (others => '0');
signal gcr_bit_cnt_w : std_logic_vector(3 downto 0) := (others => '0');
signal bit_cnt     : std_logic_vector(2 downto 0) := (others => '0');
signal bit_cnt_w   : std_logic_vector(2 downto 0) := (others => '0');

signal sync_in_n   : std_logic;
signal byte_in_n   : std_logic;

signal sector      : std_logic_vector(4 downto 0) := (others => '0');
signal state       : std_logic                    := '0';

signal data_header : std_logic_vector(7 downto 0);
signal data_body   : std_logic_vector(7 downto 0);
signal data        : std_logic_vector(7 downto 0);
signal data_cks    : std_logic_vector(7 downto 0);
signal gcr_nibble  : std_logic_vector(4 downto 0);
signal gcr_nibble_w : std_logic_vector(4 downto 0);
signal gcr_bit     : std_logic;
signal gcr_byte    : std_logic_vector(7 downto 0);

-- Disk ID
signal disk_ID_HI, disk_ID_LO : std_logic_vector(7 downto 0) := x"20";

-- Write signals
signal gcr_bit_w   : std_logic;
signal gcr_byte_w  : std_logic_vector(7 downto 0);

-- Read Lut
type gcr_array is array(0 to 15) of std_logic_vector(4 downto 0);

signal gcr_lut : gcr_array := 
	("01010","11010","01001","11001",
	 "01110","11110","01101","11101",
	 "10010","10011","01011","11011",
	 "10110","10111","01111","10101");

-- Write Lut
type gcr_array_w is array(0 to 31) of std_logic_vector(3 downto 0);

signal gcr_lut_w : gcr_array_w := 
	("0000","0000","0000","0000",	--0	1	2	3
	 "0000","0000","0000","0000",	--4	5	6	7
	 "0000","0010","0000","1010",	--8	9	10	11
	 "0000","0110","0100","1110",	--12	13	14	15
	 "0000","0000","1000","1001",	--16	17	18	19
	 "0000","1111","1100","1101",	--20	21	22	23
	 "0000","0011","0001","1011",	--24	25	26	27
	 "0000","0111","0101","0000");--28	29	30	31

	 
signal sector_max : std_logic_vector(4 downto 0);

begin

sync_n <= sync_in_n when mtr = '1' and track_ready = '1' else '1';

with byte_cnt select
  data_header <= 
	  X"08"                       when "000000000",		--Header Block starts with $08
	  "00"&track xor "000"&sector xor disk_ID_LO xor disk_ID_HI
											when "000000001",		--Header Block cheksum = track xor sector xor disk_id
	  "000"&sector                when "000000010",		--Sector
	  "00"&track                  when "000000011",		--Track
	  disk_ID_LO			         when "000000100",		--Disk ID byte #2 (or LSB)
	  disk_ID_HI			        	when "000000101",		--Disk ID byte #1 (or MSB)
	  X"0F"                       when others;			--Header Gap

with byte_cnt select
	data_body <=
		X"07"          when "000000000",		--Data Block start with $07
		data_cks       when "100000001",		--Data cheksum after reading all 256 bytes of data, xor each byte of data
		X"00"          when "100000010",		--Tail Gap
		X"00"          when "100000011",
		X"0F"          when "100000100",
		X"0F"          when "100000101",
		X"0F"          when "100000110",
		X"0F"          when "100000111",
		X"0F"          when "100001000",
		X"0F"          when "100001001",
		X"0F"          when "100001010",
		X"0F"          when "100001011",
		X"0F"          when "100001100",
		X"0F"          when "100001101",
		X"0F"          when "100001110",
		X"0F"          when "100001111",
		X"0F"          when "100010000",
		X"0F"          when "100010001",
		track_data     when others;			--256 bytes of data
	
with state select
  data <= data_header when '0', data_body when others;

with nibble select
	gcr_nibble <=
		gcr_lut(to_integer(unsigned(data(7 downto 4)))) when '0',
		gcr_lut(to_integer(unsigned(data(3 downto 0)))) when others;

gcr_bit <= gcr_nibble(to_integer(unsigned(gcr_bit_cnt)));


sector_max <=  "10100" when track < std_logic_vector(to_unsigned(18,6)) else 
               "10010" when track < std_logic_vector(to_unsigned(25,6)) else
			   "10001" when track < std_logic_vector(to_unsigned(31,6)) else
 	           "10000" ;

	
process (clk32)
	variable bit_clk_cnt : std_logic_vector(7 downto 0) := (others => '0');
	begin
		if rising_edge(clk32) then
			bit_clk_en <= '0';
			if bit_clk_cnt = X"6F" then
				bit_clk_en <= '1';
				bit_clk_cnt := (others => '0');
			else
				bit_clk_cnt := std_logic_vector(unsigned(bit_clk_cnt) + 1);
			end if;
			
			byte_n <= '1';
			if byte_in_n = '0' and mtr = '1' and track_ready = '1' then
				if bit_clk_cnt > X"10" then
					if bit_clk_cnt < X"5E" then
						byte_n <= '0';
					end if;
				end if;
			end if;
			
		end if;
end process;

-- Read process
process (clk32, bit_clk_en)
	begin
		if rising_edge(clk32) and bit_clk_en = '1' then
			
			if sync_in_n = '0'  then
			
				byte_cnt    <= (others => '0');
				nibble      <= '0';
				gcr_bit_cnt <= (others => '0');
				bit_cnt     <= (others => '0');
				do          <= (others => '0');
				gcr_byte    <= (others => '0');
				data_cks    <= (others => '0');
			
				if sync_cnt = X"31" then 
					sync_cnt <= (others => '0');
					sync_in_n <= '1';
				else
					sync_cnt <= std_logic_vector(unsigned(sync_cnt +1));
				end if;
				
			else
			
				gcr_bit_cnt <= std_logic_vector(unsigned(gcr_bit_cnt)+1);
				if gcr_bit_cnt = X"4" then
					gcr_bit_cnt <= (others => '0');
					if nibble = '1' then 
						nibble <= '0';
						track_adr <= sector & byte_cnt(7 downto 0);
						if byte_cnt = "000000000" then
							data_cks <= (others => '0');
						else
							data_cks <= data_cks xor data;
						end if;
						byte_cnt  <= std_logic_vector(unsigned(byte_cnt)+1);
					else
						nibble <= '1';
						-- Save the Disk ID when reading track 18 sector 0
--						if track = "010010" and sector = "00000" then	-- BAM sector, track 18 sector 0
--							if byte_cnt = x"A3" then		-- Disk ID High (normally at A2 but add the $07 start signal
--								disk_ID_HI <= track_data;
--							elsif byte_cnt = x"A4" then	--	Disk ID Low
--								disk_ID_LO <= track_data;
--							end if;
--						end if;
					end if;
				end if;

				bit_cnt <= std_logic_vector(unsigned(bit_cnt)+1);
				byte_in_n  <= '1';
				if bit_cnt = X"7" then
				 byte_in_n <= '0';
				end if;

				if state = '0' then
					if byte_cnt = "000010000" then sync_in_n <= '0'; state <= '1'; end if;	--When byte_cnt=16 read Data Block
				else
					if byte_cnt = "100010001" then 	--When byte_cnt=273 go to next sector
						sync_in_n <= '0';
						state <= '0';
						if sector = sector_max then 
							sector <= (others => '0');
						else
							sector <= std_logic_vector(unsigned(sector)+1);
						end if;
					end if;
				end if;
				-- Read data
				gcr_byte <= gcr_byte(6 downto 0) & gcr_bit;
				
				if bit_cnt = X"7" then
				 do <= gcr_byte(6 downto 0) & gcr_bit;
				end if;

			end if;
		end if;
end process;

-- Write process
process (clk32, bit_clk_en)
variable sync_w, track_wr_temp, track_wr_temp2, data_block, end_block : std_logic;
variable data_w : std_logic_vector(7 downto 0);
	begin
		if rising_edge(clk32) and bit_clk_en = '1' then
		    
		    --Delay to track_wr signal
		    track_wr <= track_wr_temp2;
		    track_wr_temp2 := track_wr_temp;
			track_wr_temp := '0';
			
					
			if sync_in_n = '0'  or mode = '1' then   --Sync is received
				nibble_w      <= '0';
				bit_cnt_w     <= "111";				
				gcr_byte_w <= di;
				gcr_bit_w <= di(7);
 				gcr_bit_cnt_w <= x"3";
				sync_w := '0';
				byte_cnt_wr <= (others => '0');
				data_block := '0';
				end_block := '0';
				
			elsif sync_w ='0' and di=x"FF" then --Wait for sending data to write
				nibble_w      <= '0';
				bit_cnt_w     <= "111";				
				gcr_byte_w <= di;
				gcr_bit_w <= di(7);              
 				gcr_bit_cnt_w <= x"3";
 				byte_cnt_wr <= (others => '0');
 				data_block := '0';
 				end_block := '0';
 		     
 		    else     --di <> x"FF", the first data is sent
    	        sync_w :='1';

    	        gcr_nibble_w(to_integer(unsigned(gcr_bit_cnt_w))) <= gcr_bit_w;
	            
				if gcr_bit_cnt_w = X"0" then
					if nibble_w = '0' then 
						nibble_w    <= '1';
						data_w(3 downto 0) := gcr_lut_w(to_integer(unsigned(gcr_nibble_w)));
                        if data_block = '1' and end_block = '0' then    --Start writing once data block is found ($07)
                            track_wr_temp := '1';
						    track_data_w <= data_w;
						    track_adr_w <= sector & byte_cnt_wr(7 downto 0);
						    if byte_cnt_wr = x"FF" then       --End of sector, stop writng to not rewrite the beginning
						      end_block :='1';
						    end if;
                            byte_cnt_wr <= byte_cnt_wr + 1;
                        end if;
                        if data_w = x"07" then      --Detect a data block (first byte $07)
                            data_block := '1';
                        end if;
					else
						nibble_w <= '0';
						data_w(7 downto 4) := gcr_lut_w(to_integer(unsigned(gcr_nibble_w)));
					end if;
				end if;

				gcr_bit_cnt_w <= std_logic_vector(unsigned(gcr_bit_cnt_w)+1);
				if gcr_bit_cnt_w = X"4" then
					gcr_bit_cnt_w <= (others => '0');
				end if;
				bit_cnt_w <= std_logic_vector(unsigned(bit_cnt_w)+1);
				
				-- Write data							
				if bit_cnt_w = X"0" then
					gcr_byte_w <= di;
					gcr_bit_w <= di(7);--7	
				else
					gcr_bit_w <= gcr_byte_w(6);--6
					gcr_byte_w <= gcr_byte_w(6 downto 0) & '-';			
				end if;
			end if;
		end if;
end process;

disk_ID_HI <= disk_id(15 downto 8);
disk_ID_LO <= disk_id(7 downto 0);

end struct;
