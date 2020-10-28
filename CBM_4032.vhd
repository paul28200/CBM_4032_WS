----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:22:04 06/03/2013 
-- Design Name: 
-- Module Name:    CBM_4032 - Behavioral 
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

entity CBM_4032 is
	port(	clk_50MHz, clk_32MHz : in std_logic;
			
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
			DAV_IN, NRFD_IN, NDAC_IN, ATN_IN, SRQ_IN, EOI_IN : in STD_LOGIC;
			DAV_OUT, NRFD_OUT, NDAC_OUT, ATN_OUT, EOI_OUT : out STD_LOGIC;
			  
            --User port
         Data_in_user : in STD_LOGIC_VECTOR (7 downto 0);
			Data_out_user : out STD_LOGIC_VECTOR (7 downto 0);

			--Cassette #1 (J2)
--		  CASS_WRITE : out STD_LOGIC;		--IO  5
		  CASS_MOTOR_1 : out STD_LOGIC;	--IO 6
		  CASS_SWITCH_1 : in STD_LOGIC;	--IO 7
		  CASS_READ_1 : in STD_LOGIC;		--IO 8

			--Logic Test Probe
			probe : out std_logic_vector(7 downto 0);
			
			--Monitoring info
			Init_RAM, rst : out std_logic;
			
			--SD Card port (J4)
			sd_dat  : in std_logic;		--IO 9
			sd_dat3 : out std_logic;	--IO 10
			sd_cmd  : out std_logic;	--IO 11
			sd_clk  : out std_logic	--IO 12
			);
			
end CBM_4032;

architecture Behavioral of CBM_4032 is

	signal clk_1MHz, clk_1Hz, clk_2MHz, clk_4MHz, clk_8MHz, clk_16MHz, we_sync : std_logic;
	signal phi2, irq, vert_drive : std_logic;
	signal address_bus_6502 : STD_LOGIC_VECTOR (15 downto 0);
	signal data_bus_in_6502 : std_logic_vector(7 downto 0);
	signal data_bus_out_6502 : std_logic_vector(7 downto 0);
	signal we_control_6502, we_n_control_6502 : std_logic;
	--Decodage adresse signals
	signal ena_user_RAM, read_only_RAM, ena_RAM_video : std_logic;
	signal ena_IO_clavier, ena_IEEE_488, ena_VIA, ena_ROM_4K_n1 : std_logic;
	signal data_user_RAM : std_logic_vector(7 downto 0);
	signal data_RAM_video : std_logic_vector(7 downto 0);
	signal data_CRTC : std_logic_vector(7 downto 0);
	signal data_IO_clavier, data_IEEE_488, data_VIA : std_logic_vector(7 downto 0);
	signal select_basic_ROM : std_logic_vector(13 downto 0);
	signal data_ROM_Basic, data_IO_routines, data_Kernel : std_logic_vector(7 downto 0);	

	signal data_RAM_9000 : std_logic_vector(7 downto 0);
	signal ena_RAM_9000 : std_logic;
	signal ena_CRTC, graphic : std_logic;
	
	signal Sec_adresse : std_logic_vector(5 downto 0);

	signal reset, reset_n : std_logic;

	--test
	signal audio : std_logic;
	signal data_ROM_4K_n1, Data_out_user_tmp : std_logic_vector(7 downto 0);
	signal test : std_logic_vector(23 downto 0);
	
	--RAM Init
	signal address_RAM_Init : std_logic_vector(15 downto 0);
	signal reset_0, Init_RAM_done, ena_RAM_Init, wr_RAM_Init : std_logic;
	signal data_RAM_Init : std_logic_vector(7 downto 0);

	component Clock_div_32MHz Port ( 
								clk_32MHz : in  STD_LOGIC;
								clk_16MHz : out  STD_LOGIC;
								clk_8MHz : out  STD_LOGIC;
								clk_4MHz : out  STD_LOGIC;
								clk_2MHz : out  STD_LOGIC;
								clk_1MHz : out  STD_LOGIC;
								phi2 : out STD_LOGIC);
	end component;

	component Reset_cmp port (clk, bouton_rst, done : in  STD_LOGIC;
								reset_0, reset, reset_n : out  STD_LOGIC);
								end component;

	component Generation_Video port(	clk_50Mhz : in std_logic;
								VGA_VSYNC, VGA_HSYNC : out std_logic;
								VGA_GREEN : out std_logic;
								Adresse_RAM_Video : in std_logic_vector(10 downto 0);
								Donnee_RAM_Video_in : in std_logic_vector(7 downto 0);
								Donnee_RAM_Video_out : out std_logic_vector(7 downto 0);
								Donnee_reg_CRTC_out : out std_logic_vector(7 downto 0);
								we : in std_logic;
								ena : in std_logic;
								ena_crtc : in std_logic;
								graphic : in std_logic);
								end component;

	component r6502_tc port( 
								clk_clk_i   : in     std_logic;
								d_i         : in     std_logic_vector (7 downto 0);
								irq_n_i     : in     std_logic;
								nmi_n_i     : in     std_logic;
								rdy_i       : in     std_logic;
								rst_rst_n_i : in     std_logic;
								so_n_i      : in     std_logic;
								a_o         : out    std_logic_vector (15 downto 0);
								d_o         : out    std_logic_vector (7 downto 0);
								rd_o        : out    std_logic;
								sync_o      : out    std_logic;
								wr_n_o      : out    std_logic;
								wr_o        : out    std_logic
							);
							end component;

	component basic4_B000 port (
								 clka : in std_logic;	--input clka
								 addra : in std_logic_vector(13 downto 0); --input [13 : 0] addra
								 douta : out std_logic_vector(7 downto 0)); --output [7 : 0] douta
								 end component;
	
	component edit4g40_E000 port (
								 clka : in std_logic;	--input clka
								 addra : in std_logic_vector(10 downto 0); --input [10 : 0] addra
								 douta : out std_logic_vector(7 downto 0)); --output [7 : 0] douta
								 end component;
								 
	component kernal4_F000 port (
								 clka : in std_logic;	--input clka
								 addra : in std_logic_vector(11 downto 0); --input [11 : 0] addra
								 douta : out std_logic_vector(7 downto 0)); --output [7 : 0] douta
								 end component;
								 
	component Decodage_adresse port (clk : in std_logic;
								adresse : in std_logic_vector(15 downto 0);
								data : out std_logic_vector(7 downto 0);
								ena_user_RAM : out std_logic;
								read_only_RAM : out std_logic;
								data_user_RAM : in std_logic_vector(7 downto 0);
								ena_RAM_video : out std_logic;		--8000-87FF
								data_RAM_video : in std_logic_vector(7 downto 0);
								ena_RAM_9000 : out std_logic;		--9000-9FFF
								data_RAM_9000 : in std_logic_vector(7 downto 0);								
								ena_IO_clavier : out std_logic;		--E810-E813
								data_IO_clavier : in std_logic_vector(7 downto 0);
								ena_IEEE_488 : out std_logic;			--E820-E823
								data_IEEE_488 : in std_logic_vector(7 downto 0);
								ena_VIA : out std_logic;				--E840-E84F
								data_VIA : in std_logic_vector(7 downto 0);
								ena_CRTC : out std_logic;				--E880-E881
								data_CRTC : in std_logic_vector(7 downto 0));
								end component;
								 
	component Entrees_sorties Port ( clk_50MHz, clk_32MHz, clk_4MHz, clk_8MHz, clk_2MHz, clk_1MHz, phi2 : in  STD_LOGIC;
								  reset : in  STD_LOGIC;
								  reset_n : in  STD_LOGIC;
								  data_in : in  STD_LOGIC_VECTOR (7 downto 0);
								  data_IO_clavier : out  STD_LOGIC_VECTOR (7 downto 0);
								  data_IEEE_488 : out  STD_LOGIC_VECTOR (7 downto 0);
								  data_VIA : out  STD_LOGIC_VECTOR (7 downto 0);
								  adresse : in  STD_LOGIC_VECTOR (15 downto 0);
								  ena_IO_clavier, ena_IEEE_488, ena_VIA : in  STD_LOGIC;
								  we : in  STD_LOGIC;
								  irq : out  STD_LOGIC;
								  vert_drive : in STD_LOGIC;
								  PS2_CLK : in STD_LOGIC;
								  PS2_DATA : in STD_LOGIC;
								  --graphic_kb : in STD_LOGIC;
								  graphic : out STD_LOGIC;
								  audio : out STD_LOGIC;
								  Data_out_IEEE_488 : out  STD_LOGIC_VECTOR (7 downto 0);
								  Data_in_IEEE_488 : in  STD_LOGIC_VECTOR (7 downto 0);
								  DAV_IN, NRFD_IN, NDAC_IN, ATN_IN, SRQ_IN, EOI_IN : in STD_LOGIC;
								  DAV_OUT, NRFD_OUT, NDAC_OUT, ATN_OUT, EOI_OUT : out STD_LOGIC;
								  Data_out_user : out STD_LOGIC_VECTOR (7 downto 0);
								  Data_in_user : in STD_LOGIC_VECTOR (7 downto 0);
								  CASS_WRITE : out STD_LOGIC;
								  CASS_MOTOR_1 : out STD_LOGIC;
								  CASS_SWITCH_1 : in STD_LOGIC;
								  CASS_READ_1 : in STD_LOGIC;
								  DIAG : in STD_LOGIC;
								  sd_dat  : in std_logic;
								  sd_dat3 : out std_logic;
								  sd_cmd  : out std_logic;
								  sd_clk  : out std_logic;
			                 test : out  STD_LOGIC_VECTOR (23 downto 0)			                      							  
								  );
								  end component;


	COMPONENT prg_rom_smb
	PORT (
		clka : IN STD_LOGIC;
		addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT chr_rom_smb
	PORT (
		clka : IN STD_LOGIC;
		addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END COMPONENT;

	component RAM_Init Port ( 
			  clk : in  STD_LOGIC;
			  select_mode : in STD_LOGIC;
           reset : in  STD_LOGIC;
           done : buffer  STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (15 downto 0);
           data : out  STD_LOGIC_VECTOR (7 downto 0);
           ena : out  STD_LOGIC;
           wr : out  STD_LOGIC;
			  spi_clk  : buffer STD_LOGIC;
			  spi_cs   : out STD_LOGIC;
			  spi_din  : in STD_LOGIC;
			  spi_dout : out STD_LOGIC);
			  end component;
                         
begin

	Inst_clock_div : Clock_div_32MHz port map (
								clk_32MHz => clk_32MHz,
								clk_16MHz => clk_16MHz,
								clk_8MHz => clk_8MHz,
								clk_4MHz => clk_4MHz,
								clk_2MHz => clk_2MHz,
								clk_1MHz => clk_1MHz,
								phi2 => phi2);
										
	Inst_Reset_cmp : Reset_cmp port map(clk => clk_32MHz,
								bouton_rst => BOUTON_rst,
								done => Init_RAM_done,
								reset_0 => reset_0,
								reset => reset,
								reset_n => reset_n);

	Inst_Generation_Video : Generation_Video port map (
								clk_50Mhz => clk_50MHz,
								VGA_VSYNC => vert_drive,
								VGA_HSYNC => VGA_HSYNC,
								VGA_GREEN => VGA_GREEN,
								Adresse_RAM_Video => address_bus_6502 (10 downto 0),
								Donnee_RAM_Video_in => data_bus_out_6502,
								Donnee_RAM_Video_out => data_RAM_video,
								Donnee_reg_CRTC_out => data_CRTC,
								we => we_sync,
								ena => ena_RAM_video,
								ena_crtc => ena_CRTC,
								graphic => graphic);								
    VGA_VSYNC <= vert_drive;

	 Inst_R6502 : r6502_tc port map( 
								clk_clk_i => clk_1MHz,
								d_i => data_bus_in_6502,
								irq_n_i => irq,
								nmi_n_i => '1',
								rdy_i => '1',
								rst_rst_n_i => reset_n,
								so_n_i => '1',
								a_o => address_bus_6502,
								d_o => data_bus_out_6502,
								rd_o => open,
								sync_o => open,
								wr_n_o => we_n_control_6502,
								wr_o => we_control_6502
							);
							
	we_sync <= we_control_6502 and (not clk_1MHz) and (not clk_2MHz);	-- Le signal WE du 6502 doit tre masqu par l'horloge pour arrter l'ecriture en RAM ds la fin de l'instruction

	--External RAM connection (64K x 8)
			SRAM_add(15 downto 0) <= address_bus_6502 when Init_RAM_done='1'
												else address_RAM_init;
			SRAM_nCS1 <= (not ena_user_RAM) when Init_RAM_done='1'
												else (not ena_RAM_Init);
			SRAM_CS2 <= ena_user_RAM when Init_RAM_done='1'
												else ena_RAM_Init;
			SRAM_nWE <= (not (we_sync and read_only_RAM)) when Init_RAM_done='1'
												else (not wr_RAM_Init);
			SRAM_data <= data_bus_out_6502 when (we_control_6502='1' and ena_user_RAM='1' and Init_RAM_done='1' and read_only_RAM='1') 
												else data_RAM_Init when (ena_RAM_Init='1' and Init_RAM_done='0')
												else (others => 'Z');
			data_user_RAM <= SRAM_data when (we_sync='0' and ena_user_RAM='1' and Init_RAM_done='1')
												else (others => '-');
			SRAM_nOE <= '0' when (we_sync='0' and ena_user_RAM='1' and Init_RAM_done='1')
												else '1';

	Inst_RAM_Init : RAM_Init port map(
			clk => clk_1MHz,
			select_mode => PET_select,
			reset => reset_0,
			done => Init_RAM_done,
			address => address_RAM_Init,
			data => data_RAM_Init,
			ena => ena_RAM_Init,
			wr => wr_RAM_Init,
			spi_clk  => SPI_SCK,
			spi_cs   => SPI_SS_B,
			spi_din  => SPI_MISO,
			spi_dout => SPI_MOSI
		);

Init_RAM <= Init_RAM_done;
								
	Inst_Decodage_adresse : Decodage_adresse port map (
								clk => clk_32MHz,
								adresse => address_bus_6502,
								data => data_bus_in_6502,
								ena_user_RAM => ena_user_RAM,
								read_only_RAM => read_only_RAM,
								data_user_RAM => data_user_RAM,
								ena_RAM_video => ena_RAM_video,
								data_RAM_video => data_RAM_video,
								ena_RAM_9000 => ena_RAM_9000,
								data_RAM_9000 => data_RAM_9000,
								ena_IO_clavier => ena_IO_clavier,
								data_IO_clavier => data_IO_clavier,
								ena_IEEE_488 => ena_IEEE_488,
								data_IEEE_488 => data_IEEE_488,
								ena_VIA => ena_VIA,
								data_VIA => data_VIA,
								ena_CRTC => ena_CRTC,
								data_CRTC => data_CRTC
								);
								
	Inst_ES : Entrees_sorties Port map( clk_50MHz => clk_50MHz,
									clk_32MHz => clk_32MHz,
									clk_8MHz => clk_8MHz,
									clk_4MHz => clk_4MHz,
									clk_2MHz => clk_2MHz,
									clk_1MHz => clk_1MHz,
								  reset => reset,
								  reset_n => reset_n,
								  data_in => data_bus_out_6502,
								  data_IO_clavier => data_IO_clavier,
								  data_IEEE_488 => data_IEEE_488,
								  data_VIA => data_VIA,
								  adresse => address_bus_6502(15 downto 0),
								  ena_IO_clavier => ena_IO_clavier,
								  ena_IEEE_488 => ena_IEEE_488,
								  ena_VIA => ena_VIA,
								  phi2 => phi2,
								  we => we_control_6502,
								  irq => irq,
								  vert_drive => vert_drive,
								  PS2_DATA => PS2_DATA,
								  PS2_CLK => PS2_CLK,
								  graphic => graphic,
								  audio => audio, --LED_4,
								  Data_out_user => Data_out_user_tmp,   --Data_out_user
								  Data_in_user => Data_in_user,
								  Data_out_IEEE_488 => Data_out_IEEE_488,
								  data_in_IEEE_488 => data_in_IEEE_488,
								  EOI_OUT => EOI_OUT,
								  ATN_OUT => ATN_OUT,
								  NDAC_OUT => NDAC_OUT,
								  NRFD_OUT => NRFD_OUT,
								  DAV_OUT => DAV_OUT,
								  EOI_IN => EOI_IN,
								  ATN_IN => ATN_IN,
								  NDAC_IN => NDAC_IN,
								  NRFD_IN => NRFD_IN,
								  DAV_IN => DAV_IN,
								  SRQ_IN => '1',
--								  CASS_WRITE => CASS_WRITE,
								  CASS_READ_1 => CASS_READ_1,
								  CASS_SWITCH_1 => CASS_SWITCH_1,
								  CASS_MOTOR_1 => CASS_MOTOR_1,
								  DIAG => '1',
							      sd_dat => sd_dat,
							      sd_dat3 => sd_dat3,
							      sd_cmd => sd_cmd,
							      sd_clk => sd_clk,
							      test => test
                                  );

probe <= test(23 downto 16);



end;

