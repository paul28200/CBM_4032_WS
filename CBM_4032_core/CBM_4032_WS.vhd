
-- Company: 
-- Engineer: Paul Prudhomme
-- 
-- Create Date:    09:02:24 03/09/2020 
-- Design Name: 
-- Module Name:    CBM_4032_WS - Behavioral 
-- Project Name: 
-- Target Devices: Spartan 3E 3S500E on WaveShare board Core3S500E
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


entity CBM_4032_WS is port(	
			clk : in std_logic;
			--VGA output
			VGA_VSYNC, VGA_HSYNC : out std_logic;
			VGA_GREEN : out std_logic;
			--PS2 Keyboard
			PS2_CLK : in std_logic;
			PS2_DATA : in std_logic;
			--Cassette #1
--		  CASS_WRITE : out STD_LOGIC;		--IO  5
--		  CASS_MOTOR_1 : out STD_LOGIC;	--IO 6
--		  CASS_SWITCH_1 : in STD_LOGIC;	--IO 7
		  CASS_READ_1 : in STD_LOGIC;		--IO 8
			--SD Card port
			sd_dat  : in std_logic;		--IO 9
			sd_dat3 : buffer std_logic;	--IO 10
			sd_cmd  : buffer std_logic;	--IO 11
			sd_clk  : buffer std_logic;	--IO 12
	
			LED : out std_logic_vector(3 downto 0);
			BOUTON_RST : in std_logic;
			
			Switch : in std_logic_vector(3 downto 0);
			
			--External_SRAM (KM681000BLG, 128K x 8)
			SRAM_add : out std_logic_vector(16 downto 0);
			SRAM_data : inout std_logic_vector(7 downto 0);
			SRAM_nCS1 : out std_logic;
			SRAM_CS2 : out std_logic;
			SRAM_nOE : out std_logic;
			SRAM_nWE : out std_logic;

			--Flash SPI PROM (25LV512)
			SPI_MISO : in std_logic;
			SPI_MOSI : out std_logic;
			SPI_SCK : out std_logic;
			SPI_SS_B : out std_logic;
			
			--IEEE 488 Port
			Data_out_IEEE_488 : out std_logic_vector(7 downto 0);
			Data_in_IEEE_488 : in std_logic_vector(7 downto 0);
			DAV_IN, NRFD_IN, NDAC_IN, ATN_IN, SRQ_IN, EOI_IN : in STD_LOGIC;
			DAV_OUT, NRFD_OUT, NDAC_OUT, ATN_OUT, SRQ_OUT, EOI_OUT : out STD_LOGIC

			--Test SPI
--			Test_SPI_in  : out std_logic;
--			Test_SPI_out : out std_logic;
--			Test_SPI_clk : out std_logic;
--			Test_SPI_sel : out std_logic;
			
			--Test_probe (J2)
--			Test_probe : out std_logic_vector(3 downto 0)
			);
end CBM_4032_WS;

architecture Behavioral of CBM_4032_WS is

component CBM_4032 port(	
			clk_50MHz, clk_32MHz : in std_logic;
			
			--VGA output
			VGA_VSYNC, VGA_HSYNC : out std_logic;
			VGA_GREEN : out std_logic;
			
			--PS2 Keyboard
			PS2_CLK : in std_logic;
			PS2_DATA : in std_logic;

			--Buttons
			BOUTON_rst : in std_logic;
			PET_select : in std_logic;		-- 1 for CBM 8032, 0 for 4032
			
			--External_SRAM
			SRAM_add : out std_logic_vector(15 downto 0);
			SRAM_data : inout std_logic_vector(7 downto 0);
			SRAM_nCS1 : out std_logic;
			SRAM_CS2 : out std_logic;
			SRAM_nOE : out std_logic;
			SRAM_nWE : out std_logic;

			--Flash SPI PROM (25LV512)
			SPI_MISO : in std_logic;
			SPI_MOSI : out std_logic;
			SPI_SCK : out std_logic;
			SPI_SS_B : out std_logic;
			
            --IEEE 488 port
			Data_out_IEEE_488 : out  STD_LOGIC_VECTOR (7 downto 0);
			Data_in_IEEE_488 : in  STD_LOGIC_VECTOR (7 downto 0);
    		DAV_IN : in STD_LOGIC;
			DAV_OUT : out STD_LOGIC;
			NRFD_IN : in STD_LOGIC;
			NRFD_OUT : out STD_LOGIC;
			NDAC_IN : in STD_LOGIC;
			NDAC_OUT : out STD_LOGIC;
			ATN_IN : in STD_LOGIC;
			ATN_OUT : out STD_LOGIC;
			SRQ_IN : in STD_LOGIC;
			EOI_IN : in STD_LOGIC;
			EOI_OUT : out STD_LOGIC;
			  
            --User port
         Data_in_user : in STD_LOGIC_VECTOR (7 downto 0);
			Data_out_user : out STD_LOGIC_VECTOR (7 downto 0);

			--Cassette #1 (J2)
--		  CASS_WRITE : out STD_LOGIC;		--IO  5
		  CASS_MOTOR_1 : out STD_LOGIC;	--IO 6
		  CASS_SWITCH_1 : in STD_LOGIC;	--IO 7
		  CASS_READ_1 : in STD_LOGIC;		--IO 8

			--Logic Test Probe
--			probe : out std_logic_vector(7 downto 0);
			
			--Monitoring info
			Init_RAM : out std_logic;
			
			--SD Card port (J4)
			sd_dat  : in std_logic;		--IO 9
			sd_dat3 : out std_logic;	--IO 10
			sd_cmd  : out std_logic;	--IO 11
			sd_clk  : out std_logic	--IO 12
			);
end component;

	COMPONENT Clock_32MHz
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;


	component RAM_8k port (
								clka : in std_logic; 	--input clka
								ena : in std_logic;		--input ena
								wea : in std_logic_vector (0 downto 0);		--input [0 : 0] wea
								addra : in std_logic_vector(12 downto 0);	--input [12 : 0] addra
								dina : in std_logic_vector(7 downto 0);	--input [7 : 0] dina
								douta : out std_logic_vector(7 downto 0)); --output [7 : 0] douta
								end component;



	signal clk_32MHz, clk_50MHz : std_logic;
	signal led_tmp : std_logic_vector(3 downto 0);

	signal CASS_MOTOR_1 : std_logic;
	signal Data_out_IEEE_488_tmp : std_logic_vector(7 downto 0);
	signal DAV_OUT_tmp, NRFD_OUT_tmp, NDAC_OUT_tmp, ATN_OUT_tmp, EOI_OUT_tmp : std_logic;

begin

	Inst_Clock_32MHz: Clock_32MHz PORT MAP(
		CLKIN_IN => clk,
		RST_IN => '0',
		CLKFX_OUT => clk_32MHz,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => clk_50MHz,
		LOCKED_OUT => open
	);

Inst_CBM_4032 : CBM_4032 port map(
			clk_50MHz => clk_50MHz,
			clk_32MHz => clk_32MHz,
			VGA_VSYNC => VGA_VSYNC,
			VGA_HSYNC => VGA_HSYNC,
			VGA_GREEN => VGA_GREEN,
			PS2_CLK => PS2_CLK,
			PS2_DATA => PS2_DATA,
--		  CASS_WRITE => CASS_WRITE,
		  CASS_MOTOR_1 => CASS_MOTOR_1,
		  CASS_SWITCH_1 => Switch(0), --CASS_SWITCH_1,
		  CASS_READ_1 => CASS_READ_1,
			sd_dat  => sd_dat,
			sd_dat3 => sd_dat3,
			sd_cmd  => sd_cmd,
			sd_clk  => sd_clk,			
			BOUTON_rst => not BOUTON_RST,
			PET_select => Switch(3),
			SRAM_add => SRAM_add(15 downto 0),
			SRAM_data => SRAM_data,
			SRAM_nCS1 => SRAM_nCS1,
			SRAM_CS2 => SRAM_CS2,
			SRAM_nOE => SRAM_nOE,
			SRAM_nWE => SRAM_nWE,
			SPI_MISO => SPI_MISO,
			SPI_MOSI => SPI_MOSI,
			SPI_SCK => SPI_SCK,
			SPI_SS_B => SPI_SS_B,
			Data_out_IEEE_488 => Data_out_IEEE_488_tmp,
			Data_in_IEEE_488 => Data_in_IEEE_488,
    		DAV_IN => DAV_IN,
			DAV_OUT => DAV_OUT_tmp,
			NRFD_IN => NRFD_IN,
			NRFD_OUT => NRFD_OUT_tmp,
			NDAC_IN => NDAC_IN,
			NDAC_OUT => NDAC_OUT_tmp,
			ATN_IN => ATN_IN,
			ATN_OUT => ATN_OUT_tmp,
			SRQ_IN => SRQ_IN,
			EOI_IN => EOI_IN,
			EOI_OUT => EOI_OUT_tmp,
         Data_in_user => "11111111",
			Data_out_user => open,
			Init_RAM => open
			);

SRAM_add(16) <= '1';
LED (1 downto 0) <= led_tmp(1 downto 0);
LED(2) <= CASS_MOTOR_1;
LED(3) <= CASS_READ_1;
SRQ_OUT <= '0';
DAV_OUT <= not DAV_OUT_tmp;
NRFD_OUT <= not NRFD_OUT_tmp;
NDAC_OUT <= not NDAC_OUT_tmp;
ATN_OUT <= not ATN_OUT_tmp;
EOI_OUT <= not EOI_OUT_tmp;
Data_out_IEEE_488 <= not Data_out_IEEE_488_tmp;

process(clk_32MHz)
variable count : integer range 0 to 16000000 :=0;
begin
if clk_32MHz'event and clk_32MHz='1' then
	if count = 16000000 then
		count := 0;
		led_tmp(0) <= not led_tmp(0);
	else
		count := count +1;
	end if;
end if;
end process;

process(clk_50MHz)
variable count : integer range 0 to 16000000 :=0;
begin
if clk_50MHz'event and clk_50MHz='1' then
	if count = 16000000 then
		count := 0;
		led_tmp(1) <= not led_tmp(1);
	else
		count := count +1;
	end if;
end if;
end process;


end Behavioral;

