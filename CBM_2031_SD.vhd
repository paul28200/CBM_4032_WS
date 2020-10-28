----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:31:09 05/15/2019 
-- Design Name: 
-- Module Name:    CBM_2031_LP - Behavioral 
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

entity CBM_2031_SD is
    Port ( clk_32MHz, reset : in  STD_LOGIC;
	 
			  disk_num : in std_logic_vector(9 downto 0);
	 
				--IEEE 488 Port
              DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
              DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
              DAV_IN : in  STD_LOGIC;
              DAV_OUT : out  STD_LOGIC;
              NRFD_IN : in  STD_LOGIC;
              NRFD_OUT : out  STD_LOGIC;
              NDAC_IN : in  STD_LOGIC;
              NDAC_OUT : out  STD_LOGIC;
              ATN_IN : in  STD_LOGIC;
              ATN_OUT : out  STD_LOGIC;
              SRQ_IN : in  STD_LOGIC;
              EOI_IN : in  STD_LOGIC;
              EOI_OUT : out  STD_LOGIC;
			  
			  --SD Card port
			  sd_dat  : in std_logic;
			  sd_dat3 : out std_logic;
			  sd_cmd  : out std_logic;
			  sd_clk  : out std_logic;
			  
			  --Read track buffer
			  txt_address : in std_logic_vector(4 downto 0);
				
			  led : out std_logic_vector(7 downto 0);
			  test : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  --test track buffer
			  adresse : in  STD_LOGIC_VECTOR (15 downto 0)
			  
			  );
end CBM_2031_SD;

architecture Behavioral of CBM_2031_SD is

		component Clock_div_32MHz Port ( 
									clk_32MHz : in  STD_LOGIC;
									clk_16MHz : out  STD_LOGIC;
									clk_8MHz : out  STD_LOGIC;
									clk_4MHz : out  STD_LOGIC;
									clk_2MHz : out  STD_LOGIC;
									clk_1MHz : out  STD_LOGIC;
									phi2 : out STD_LOGIC);
		end component;
		
		component CBM_2031_logic Port (
				clk_32MHz, clk_8MHz, clk_4MHz, clk_2MHz, clk_1MHz, phi2, rst : in  STD_LOGIC;
				--IEEE 488 Port
               DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
               DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
               DAV_IN : in  STD_LOGIC;
               DAV_OUT : out  STD_LOGIC;
               NRFD_IN : in  STD_LOGIC;
               NRFD_OUT : out  STD_LOGIC;
               NDAC_IN : in  STD_LOGIC;
               NDAC_OUT : out  STD_LOGIC;
               ATN_IN : in  STD_LOGIC;
               ATN_OUT : out  STD_LOGIC;
               SRQ_IN : in  STD_LOGIC;
               EOI_IN : in  STD_LOGIC;
               EOI_OUT : out  STD_LOGIC;
			  
			 -- drive-side interface
			 ds              : in std_logic_vector(1 downto 0);    -- device select
			 di              : in std_logic_vector(7 downto 0);    -- disk read data
			 do              : out std_logic_vector(7 downto 0);   -- disk write data
			 mode            : out std_logic;                      -- read/write
			 stp             : out std_logic_vector(1 downto 0);   -- stepper motor control
			 mtr             : out std_logic;                      -- stepper motor on/off
			 freq            : out std_logic_vector(1 downto 0);   -- motor frequency
			 sync_n          : in std_logic;                       -- reading SYNC bytes
			 byte_n          : in std_logic;                       -- byte ready
			 wps_n           : in std_logic;                       -- write-protect sense
			 tr00_sense_n    : in std_logic;                       -- track 0 sense (unused?)
			 act             : out std_logic                      -- activity LED
			  
			  );
				end component;

		component gcr_floppy port(
            clk32  : in  std_logic;
            do     : out std_logic_vector(7 downto 0);   -- disk read data
            di     : in std_logic_vector(7 downto 0);   -- disk write data
            mode   : in  std_logic;                      -- read/write
            stp    : in  std_logic_vector(1 downto 0);   -- stepper motor control
            mtr    : in  std_logic;                      -- stepper motor on/off
            freq   : in  std_logic_vector(1 downto 0);   -- motor (gcr_bit) frequency
            sync_n : out std_logic;                      -- reading SYNC bytes
            byte_n : out std_logic;                      -- byte ready
				disk_id : in std_logic_vector(15 downto 0);
            
            track       : in  std_logic_vector(5 downto 0);
            track_adr   : out std_logic_vector(12 downto 0);
            track_adr_w : out std_logic_vector(12 downto 0);
            track_data  : in  std_logic_vector(7 downto 0);
            track_data_w : out std_logic_vector(7 downto 0);
            track_wr		: out std_logic;
            track_ready : in  std_logic
		);
		end component;
		
		component spi_controller port (
			 -- Card Interface ---------------------------------------------------------
			 CS_N           : out std_logic;     -- MMC chip select
			 MOSI           : out std_logic;     -- Data to card (master out slave in)
			 MISO           : in  std_logic;     -- Data from card (master in slave out)
			 SCLK           : out std_logic;     -- Card clock
			 -- Track buffer Interface -------------------------------------------------
			 ram_write_addr : out std_logic_vector(12 downto 0);
			 ram_di         : out std_logic_vector(7 downto 0);
			 ram_do         : in  std_logic_vector(7 downto 0);
			 ram_we         : out std_logic;
			 track          : in  unsigned(5 downto 0);  -- Track number (0-34)
			 image          : in  unsigned(9 downto 0);  -- Which disk image to read
			 busy           : out std_logic;
	         ask_writing, mtr    : in std_logic;             -- '1' to write the block when track changes

			 -- System Interface -------------------------------------------------------
			 CLK_14M        : in  std_logic;     -- System clock
			 reset          : in  std_logic
		  );
		 end component;

		--test RAM
		COMPONENT RAM_dp_track_buffer_8k
		  PORT (
			 clka : IN STD_LOGIC;
			 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			 addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 clkb : IN STD_LOGIC;
			 web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			 addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			 dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			 doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		  );
		END COMPONENT;

	--Reset signals
	signal rst_2, reset_n : std_logic;
	signal rst_count : integer range 0 to 1000000;
	
	--Clock signals
	signal clk_16MHz, clk_8MHz, clk_n_8MHz, clk_4MHz, clk_2MHz, clk_1MHz, phi2 : std_logic;

	signal ram_write_addr : std_logic_vector(12 downto 0);
	signal ram_addr       : std_logic_vector(12 downto 0);
	signal ram_addr_tmp	 : std_logic_vector(12 downto 0);
	signal ram_di         : std_logic_vector( 7 downto 0);
	signal ram_din_tmp	 : std_logic_vector(7 downto 0);
	signal ram_do         : std_logic_vector(7 downto 0);
	signal ram_we         : std_logic;

	signal do, di : std_logic_vector(7 downto 0); -- disk read data
	signal mode   : std_logic;                    -- read/write
	signal stp    : std_logic_vector(1 downto 0); -- stepper motor control
	signal stp_r  : std_logic_vector(1 downto 0); -- stepper motor control
	signal mtr    : std_logic ;                   -- stepper motor on/off
	signal freq   : std_logic_vector(1 downto 0); -- motor (gcr_bit) frequency
	signal sync_n : std_logic;                    -- reading SYNC bytes
	signal byte_n : std_logic;                    -- byte ready
	signal act    : std_logic;                    -- activity LED

	signal track_dbl  : std_logic_vector(6 downto 0);
	signal sd_busy, sd_busy_n, ask_writing : std_logic;
	
	signal image : std_logic_vector(9 downto 0);

	signal track_read_adr, track_write_adr  : std_logic_vector(12 downto 0);

	signal track_data_w  : std_logic_vector(7 downto 0);
	signal track_wr  : std_logic;

begin

--Delai supplmentaire pour le reset du 2031
process(clk_1MHz, reset)
begin
if clk_1MHz='1' and clk_1MHz'event then
	if reset='1' then
		rst_count <= 0;
		rst_2 <= '1';
	elsif rst_count < 1000 then		--Tempo de 1ms
		rst_count <= rst_count + 1;
		rst_2 <= '1';
	else
		rst_2 <= '0';
	end if;
end if;
end process;

	Inst_clock_div : Clock_div_32MHz port map (
								clk_32MHz => clk_32MHz,
								clk_16MHz => clk_16MHz,
								clk_8MHz => clk_8MHz,
								clk_4MHz => clk_4MHz,
								clk_2MHz => clk_2MHz,
								clk_1MHz => clk_1MHz,
								phi2 => phi2);

	Inst_CBM_2031_logic : CBM_2031_logic port map(
				clk_32MHz => clk_32MHz,
				clk_8MHz => clk_8MHz,
				clk_4MHz => clk_4MHz,
				clk_2MHz => clk_2MHz,
				clk_1MHz => clk_1MHz,
				phi2 => phi2,
				rst => rst_2,
				--IEEE 488 Port
           DATA_IN => DATA_IN,
           DATA_OUT => DATA_OUT,
           DAV_IN => DAV_IN,
           DAV_OUT => DAV_OUT,
           NRFD_IN => NRFD_IN,
           NRFD_OUT => NRFD_OUT,
           NDAC_IN => NDAC_IN,
           NDAC_OUT => NDAC_OUT,
           ATN_IN => ATN_IN,
           ATN_OUT => ATN_OUT,
           SRQ_IN => SRQ_IN,
           EOI_IN => EOI_IN,
           EOI_OUT => EOI_OUT,
			  
			 -- drive-side interface
			 ds              => "01",                  -- device select
			 di              => do,                    -- disk read data
			 do              => di,                  	 -- disk write data
			 mode            => mode,                  -- read/write
			 stp             => stp,                   -- stepper motor control
			 mtr             => mtr,                   -- motor on/off
			 freq            => freq,                  -- motor frequency
			 sync_n          => sync_n,                -- reading SYNC bytes
			 byte_n          => byte_n,                -- byte ready
			 wps_n           => reset_n,             -- write-protect sense, 0 = protected, not reset = writable
			 tr00_sense_n    => '1',                   -- track 0 sense (unused?)
			 act             => act                    -- activity LED
			  );
	reset_n <= not reset;
		
	floppy : gcr_floppy
		  port map
		  (
			 clk32  => clk_32MHz,

			 di     => di,     -- disk write data			
			 do     => do,     -- disk read data
			 mode   => mode,   -- read/write
			 stp    => stp,    -- stepper motor control
			 mtr    => mtr,    -- stepper motor on/off
			 freq   => freq,   -- motor (gcr_bit) frequency
			 sync_n => sync_n, -- reading SYNC bytes
			 byte_n => byte_n, -- byte ready
			 disk_id(4 downto 0) => image(4 downto 0),
			 disk_id(7 downto 5) => "010",
			 disk_id(12 downto 8) => image(9 downto 5),
			 disk_id(15 downto 13) => "010",
				
				track       => track_dbl(6 downto 1),
				track_adr   => track_read_adr,
				track_adr_w => track_write_adr,
				track_data  => ram_do, 	
				track_ready => sd_busy_n,
				
				track_data_w => track_data_w,
				track_wr => track_wr
		  );
    sd_busy_n <= not sd_busy;
	
	process (clk_32MHz)
	begin
		if rising_edge(clk_32MHz) then
			stp_r <= stp;
			if reset = '1' then
				track_dbl <= "0100100";		--Track 18
			elsif sd_busy = '0' and not(image = disk_num) then
				--The selected disk_image has changed
				image <= disk_num;
				track_dbl <= "0100100";		--Track 18 for read disk name reading
			else
				if mtr = '1' then
					if(  (stp_r = "00" and stp = "10")
						or (stp_r = "10" and stp = "01")
						or (stp_r = "01" and stp = "11")
						or (stp_r = "11" and stp = "00")) then
							if track_dbl < "1010000" then
								track_dbl <= std_logic_vector(to_unsigned(to_integer(unsigned(track_dbl)) + 1,7));
							end if;
					end if;
				
					if(  (stp_r = "00" and stp = "11")
						or (stp_r = "10" and stp = "00")
						or (stp_r = "01" and stp = "10")
						or (stp_r = "11" and stp = "01")) then 
							if track_dbl > "0000001" then
								track_dbl <= std_logic_vector(to_unsigned(to_integer(unsigned(track_dbl)) - 1,7));
							end if;
					end if;
				end if;
			end if;
		end if;
	end process;


	sd_spi : spi_controller
	port map
	(
		CS_N => sd_dat3, --: out std_logic;     -- MMC chip select
		MOSI => sd_cmd,  --: out std_logic;     -- Data to card (master out slave in)
		MISO => sd_dat,  --: in  std_logic;     -- Data from card (master in slave out)
		SCLK => sd_clk,  --: out std_logic;     -- Card clock
  
		ram_write_addr => ram_write_addr, --: out unsigned(12 downto 0);
		ram_di         => ram_di,         --: out unsigned(7 downto 0);
		ram_do         => ram_do,
		ram_we         => ram_we,         
  
		track => unsigned(track_dbl(6 downto 1)),
		image => unsigned(image),
  
		CLK_14M => clk_8MHz,
		reset   => reset, 
		busy => sd_busy,
		ask_writing => ask_writing,
		mtr => mtr
	);
	clk_n_8MHz <= not clk_8MHz;
	--ram_addr_tmp <= std_logic_vector(ram_addr);
	--ram_din_tmp <= std_logic_vector(ram_di);
	
	track_buffer : RAM_dp_track_buffer_8k
	  PORT MAP (
		 clka => clk_n_8MHz, 
		 wea(0) => ram_we,
		 addra => ram_addr,
		 dina => ram_di,
		 douta => ram_do,
		 clkb => clk_n_8MHz,
		 web(0) => track_wr,
		 addrb =>  track_write_adr,
		 dinb => track_data_w,
		 doutb => open
	  );
	
	with sd_busy select 
--		ram_addr <= ram_write_addr when '1', unsigned('0'&track_read_adr) when others; 
		ram_addr <= ram_write_addr when '1', track_read_adr when others; 

--Process for ask wrinting a track to SD Card
--  Ask for writing if an write as occured on track buffer RAM
process(clk_32MHz)
begin
if clk_32MHz='1' and clk_32MHz'event then
    if mode = '0' then
        ask_writing <= '1';
    end if;
    if sd_busy = '1' then
        ask_writing <= '0';
    end if;
end if;
end process;


	led(0)          <= mode; -- read/write
	led(2 downto 1) <= stp;  -- stepper motor control
	led(3)          <= mtr;  -- stepper motor on/off
	led(5 downto 4) <= freq; -- motor frequency
	led(6)          <= act;  -- activity LED
	led(7)          <= sd_busy;  -- SD read	
--	test(7 downto 0) <= track_data_w;

end Behavioral;
