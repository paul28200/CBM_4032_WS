----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:58:52 01/26/2019 
-- Design Name: 
-- Module Name:    Entrees_sorties - Behavioral 
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

entity Entrees_sorties is
    Port ( clk_50MHz, clk_32MHz, clk_8MHz, clk_4MHz, clk_2MHz, clk_1MHz, phi2 : in  STD_LOGIC;
			  reset, reset_n : in  STD_LOGIC;
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
			  CASS_MOTOR_2 : out STD_LOGIC;
			  CASS_SWITCH_2 : in STD_LOGIC;
			  CASS_READ_2 : in STD_LOGIC;
			  DIAG : in STD_LOGIC;
			  sd_dat  : in std_logic;
			  sd_dat3 : out std_logic;
			  sd_cmd  : out std_logic;
			  sd_clk  : out std_logic;
			  txt_address : in std_logic_vector(4 downto 0);
			  image : in std_logic_vector(9 downto 0);
			  RS232_DCE_TXD : out  STD_LOGIC;
			  led : out std_logic_vector(7 downto 0);
			  test, test_2 : out  STD_LOGIC_VECTOR (23 downto 0);
			  Sec_adresse : out  STD_LOGIC_VECTOR (5 downto 0)
			  );
end Entrees_sorties;

architecture Behavioral of Entrees_sorties is

	component pia6821 port( 
							clk       : in    std_logic;
							 rst       : in    std_logic;
							 cs        : in    std_logic;
							 rw        : in    std_logic;
							 addr      : in    std_logic_vector(1 downto 0);
							 data_in   : in    std_logic_vector(7 downto 0);
							data_out  : out   std_logic_vector(7 downto 0);
							irqa      : out   std_logic;
							irqb      : out   std_logic;
							pa_i      : in std_logic_vector(7 downto 0);
							pa_o      : out std_logic_vector(7 downto 0);
							pa_oe     : out std_logic_vector(7 downto 0);
							ca1       : in    std_logic;
							ca2_i     : in std_logic;
							ca2_o     : out std_logic;
							ca2_oe    : out std_logic;
							pb_i      : in std_logic_vector(7 downto 0);
							pb_o      : out std_logic_vector(7 downto 0);
							pb_oe     : out std_logic_vector(7 downto 0);
							cb1       : in    std_logic;
							cb2_i     : in std_logic;
							cb2_o     : out std_logic;
							cb2_oe    : out std_logic
						 );						   
	end component;
								
	component M6522 port (
							 I_RS              : in    std_logic_vector(3 downto 0);
							 I_DATA            : in    std_logic_vector(7 downto 0);
							 O_DATA            : out   std_logic_vector(7 downto 0);
							 O_DATA_OE_L       : out   std_logic;

							 I_RW_L            : in    std_logic;
							 I_CS1             : in    std_logic;
							 I_CS2_L           : in    std_logic;

							 O_IRQ_L           : out   std_logic; -- note, not open drain
							 -- port a
							 I_CA1             : in    std_logic;
							 I_CA2             : in    std_logic;
							 O_CA2             : out   std_logic;
							 O_CA2_OE_L        : out   std_logic;

							 I_PA              : in    std_logic_vector(7 downto 0);
							 O_PA              : out   std_logic_vector(7 downto 0);
							 O_PA_OE_L         : out   std_logic_vector(7 downto 0);

							 -- port b
							 I_CB1             : in    std_logic;
							 O_CB1             : out   std_logic;
							 O_CB1_OE_L        : out   std_logic;

							 I_CB2             : in    std_logic;
							 O_CB2             : out   std_logic;
							 O_CB2_OE_L        : out   std_logic;

							 I_PB              : in    std_logic_vector(7 downto 0);
							 O_PB              : out   std_logic_vector(7 downto 0);
							 O_PB_OE_L         : out   std_logic_vector(7 downto 0);

							 I_P2_H            : in    std_logic; -- high for phase 2 clock  ____----__
							 RESET_L           : in    std_logic;
							 ENA_4             : in    std_logic; -- clk enable
							 CLK               : in    std_logic
							 );
	end component;
								 
	component keyboard port (
								CLK			:	in	std_logic;
								nRESET		:	in	std_logic;
								--graphic_kb		:	in	std_logic;

								-- PS/2 interface
								PS2_CLK		:	in	std_logic;
								PS2_DATA	:	in	std_logic;
								
								-- Keyboard row scan
								A			:	in	std_logic_vector(3 downto 0);
								-- Keyboard return
								KEYB		:	out	std_logic_vector(7 downto 0));
								end component;

	component Conv_GPIB_RS232
					 Port ( clk_50MHz, rst : in  STD_LOGIC;
							  RS232_DCE_RXD : in  STD_LOGIC;
							  RS232_DCE_TXD : out  STD_LOGIC;
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
							  Sec_adresse : out  STD_LOGIC_VECTOR (5 downto 0)
							  );
	end component;
	
	component Gest_GPIB_Flash
					 Port ( clk_1MHz, rst : in  STD_LOGIC;
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
							  test : out  STD_LOGIC_VECTOR (7 downto 0)
							  );
	end component;

	component CBM_2031_SD is
					 Port ( clk_32MHz, reset : in  STD_LOGIC;
							  disk_num : in std_logic_vector(9 downto 0);
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
							  sd_dat  : in std_logic;
							  sd_dat3 : out std_logic;
							  sd_cmd  : out std_logic;
							  sd_clk  : out std_logic;
							  txt_address : in std_logic_vector(4 downto 0);
							  led : out std_logic_vector(7 downto 0);
							  test : out  STD_LOGIC_VECTOR (23 downto 0);
							  	  
								  --test track buffer
							  adresse : in  STD_LOGIC_VECTOR (15 downto 0)
			  
							  );
	end component;


	signal CASS_MOTOR_1_tmp : std_logic;
	
	--GPIB bus signals
	signal data_out_IEEE_488_pet, data_out_IEEE_488_p6, data_out_IEEE_488_p8, data_IEEE_488_bus : std_logic_vector(7 downto 0);
	signal DAV_OUT_pet, NRFD_OUT_pet, NDAC_OUT_pet, ATN_OUT_pet, EOI_OUT_pet : std_logic;
	signal DAV_OUT_p6, NRFD_OUT_p6, NDAC_OUT_p6, ATN_OUT_p6, EOI_OUT_p6 : std_logic;
	signal DAV_OUT_p8, NRFD_OUT_p8, NDAC_OUT_p8, ATN_OUT_p8, EOI_OUT_p8 : std_logic;
	signal DAV_bus, NRFD_bus, NDAC_bus, ATN_bus, EOI_bus : std_logic;
	
	--VIA signals
	signal irq_via, graphic_tmp : std_logic;
	signal pb_i_via, pb_o_via, pa_oe_via, pb_oe_via, pa_i_via, pa_o_via : std_logic_vector(7 downto 0);
	signal CB2_VIA_tmp, CB2_VIA_OE : std_logic;

	--PIA IEEE_488 signals
	signal irqa_ieee, irqb_ieee : std_logic;
	signal pb_oe_IEEE_488 : std_logic_vector(7 downto 0);
	
	--PIA keyboard signals
	signal irqa_kb, irqb_kb : std_logic;
	signal pa_i_kb, pa_o_kb, pb_clavier : std_logic_vector(7 downto 0);
	
begin

			Inst_pia_IEEE : pia6821 port map( 
								 clk => phi2, 
								 rst => reset, 
								 cs => ena_IEEE_488, 
								 rw => not we,
								 addr => adresse (1 downto 0), 
								 data_in => data_in, 
								 data_out => data_IEEE_488, 
								 irqa => irqa_ieee,
								 irqb => irqb_ieee,
								 pa_i => data_IEEE_488_bus,	--data_in_IEEE_488, 
								 pa_o => open,
								 pa_oe => open,
								 ca1 => ATN_bus, 
								 ca2_i => NDAC_OUT_pet,
								 ca2_o => NDAC_OUT_pet,		--NDAC_OUT
								 ca2_oe => open,
								 pb_i => data_out_IEEE_488_pet,	
								 pb_o => data_out_IEEE_488_pet,
								 pb_oe => open,
								 cb1 => '1', --SRQ_IN,  
								 cb2_i => DAV_OUT_pet,
								 cb2_o => DAV_OUT_pet,
								 cb2_oe => open); 

			Inst_pia_clavier : pia6821 port map( 
								 clk => phi2, 
								 rst => reset, 
								 cs => ena_IO_clavier, 
								 rw => not we,
								 addr => adresse (1 downto 0), 
								 data_in => data_in, 
								 data_out => data_IO_clavier, 
								 irqa => irqa_kb,
								 irqb => irqb_kb,
								 pa_i => pa_i_kb, 
								 pa_o => pa_o_kb,
								 pa_oe => open,
								 ca1 => CASS_READ_1, 
								 ca2_i => EOI_OUT_pet,
								 ca2_o => EOI_OUT_pet,
								 ca2_oe => open,
								 pb_i => pb_clavier,	
								 pb_o => open,
								 pb_oe => open,
								 cb1 => vert_drive,  
								 cb2_i => CASS_MOTOR_1_tmp,
								 cb2_o => CASS_MOTOR_1_tmp,
								 cb2_oe => open); 
		irq <= not (irqa_kb or irqb_kb or (not irq_via) or irqa_ieee or irqb_ieee); --(not irq_via) or
		
			Inst_VIA : M6522 port map(
								 I_RS => adresse (3 downto 0),	 	 
								 I_DATA => data_in,
								 O_DATA => data_VIA,
								 O_DATA_OE_L => open, --la slection est faite par le dcodeur d'adresses

								 I_RW_L => not we,
								 I_CS1 => ena_VIA,
								 I_CS2_L => '0',	--la slection du VIA se fait uniquement avec Ena_VIA

								 O_IRQ_L => irq_via,
								 -- port a
								 I_CA1 => '1', 
								 I_CA2 => graphic_tmp,
								 O_CA2 => graphic_tmp,
								 O_CA2_OE_L => open,

								 I_PA => pa_i_via,
								 O_PA => pa_o_via,
								 O_PA_OE_L => pa_oe_via,

								 -- port b
								 I_CB1 => CASS_READ_2,
								 O_CB1 => open,
								 O_CB1_OE_L => open,

								 I_CB2 => CB2_VIA_tmp,
								 O_CB2 => CB2_VIA_tmp,
								 O_CB2_OE_L => CB2_VIA_OE,

								 I_PB => pb_i_via,
								 O_PB => pb_o_via,
								 O_PB_OE_L => pb_oe_via,

								 I_P2_H => phi2, -- high for phase 2 clock  ____----__
								 RESET_L => reset_n,
								 ENA_4 => clk_4MHz,  --clk enable
								 CLK => clk_8MHz);
	
	pa_i_via <= (pa_o_via or pa_oe_via) and Data_in_user;
	pb_i_via <= (pb_o_via or pb_oe_via) and (DAV_bus & NRFD_bus & vert_drive & "1111" & NDAC_bus);
	
	audio <= not (CB2_VIA_tmp or CB2_VIA_OE); -- and pa_o_kb(7));

	NRFD_OUT_pet <= pb_o_via(1) or pb_oe_via(1);	--NRFD_OUT
	ATN_OUT_pet <= pb_o_via(2) or pb_oe_via(2);
	CASS_WRITE <= pb_o_via(3) or pb_oe_via(3);
	CASS_MOTOR_2 <= pb_o_via(4) or pb_oe_via(4);

	pa_i_kb <= pa_o_kb and (DIAG & EOI_bus & CASS_SWITCH_2 & CASS_SWITCH_1 & "1111");
	
	CASS_MOTOR_1 <= CASS_MOTOR_1_tmp;
	graphic <= graphic_tmp;
	Data_out_user <= pa_o_via or pa_oe_via;

		Inst_Clavier_PS2 : keyboard port map(
								CLK => clk_50MHz,
								nRESET => reset_n,
								--graphic_kb => graphic_kb,
								PS2_CLK => PS2_CLK,
								PS2_DATA => PS2_DATA,
								A => pa_o_kb(3 downto 0),
								KEYB => pb_clavier);
								
--		Inst_Conv_GPIB_RS232 : Conv_GPIB_RS232 Port map(
--							  clk_50MHz => clk_50MHz,
--							  rst => reset,
--							  RS232_DCE_RXD => '1',
--							  RS232_DCE_TXD => RS232_DCE_TXD,
--							  DATA_IN => data_IEEE_488_bus,
--							  DATA_OUT => data_out_IEEE_488_p6,
--							  DAV_IN => DAV_bus,
--							  DAV_OUT => DAV_OUT_p6,
--							  NRFD_IN => NRFD_bus,
--							  NRFD_OUT => NRFD_OUT_p6,
--							  NDAC_IN => NDAC_bus,
--							  NDAC_OUT => NDAC_OUT_p6,
--							  ATN_IN => ATN_bus,
--							  ATN_OUT => ATN_OUT_p6,
--							  SRQ_IN => '1',
--							  EOI_IN => EOI_bus,
--							  EOI_OUT => EOI_OUT_p6,
--							  Sec_adresse => open --Sec_adresse
--							  );

--		Inst_Gest_GPIB_Flash : Gest_GPIB_Flash Port map(
--							  clk_1MHz => clk_1MHz,
--							  rst => reset,
--							  DATA_IN => data_IEEE_488_bus,
--							  DATA_OUT => data_out_IEEE_488_p8,
--							  DAV_IN => DAV_bus,
--							  DAV_OUT => DAV_OUT_p8,
--							  NRFD_IN => NRFD_bus,
--							  NRFD_OUT => NRFD_OUT_p8,
--							  NDAC_IN => NDAC_bus,
--							  NDAC_OUT => NDAC_OUT_p8,
--							  ATN_IN => ATN_bus,
--							  ATN_OUT => ATN_OUT_p8,
--							  SRQ_IN => '1',
--							  EOI_IN => EOI_bus,
--							  EOI_OUT => EOI_OUT_p8,
--							  test(5 downto 0) => Sec_adresse,
--							  test(7 downto 6) => open
--							  );

		Inst_CBM_2031_SD : CBM_2031_SD Port map(
							  clk_32MHz => clk_32MHz,
							  reset => reset,
							  disk_num => image,
							  DATA_IN => data_IEEE_488_bus,
							  DATA_OUT => data_out_IEEE_488_p8,
							  DAV_IN => DAV_bus,
							  DAV_OUT => DAV_OUT_p8,
							  NRFD_IN => NRFD_bus,
							  NRFD_OUT => NRFD_OUT_p8,
							  NDAC_IN => NDAC_bus,
							  NDAC_OUT => NDAC_OUT_p8,
							  ATN_IN => ATN_bus,
							  ATN_OUT => ATN_OUT_p8,
							  SRQ_IN => '1',
							  EOI_IN => EOI_bus,
							  EOI_OUT => EOI_OUT_p8,
							  sd_dat => sd_dat,
							  sd_dat3 => sd_dat3,
							  sd_cmd => sd_cmd,
							  sd_clk => sd_clk,
							  txt_address => txt_address,
							  led => led,
							  test => test,
								
								adresse => adresse
							  );

--Bus interne IEEE 488 GPIB
DAV_bus <= DAV_OUT_pet and DAV_IN and DAV_OUT_p8;
NRFD_bus <= NRFD_OUT_pet and NRFD_IN and NRFD_OUT_p8;
NDAC_bus <= NDAC_OUT_pet and NDAC_IN and NDAC_OUT_p8;
ATN_bus <= ATN_OUT_pet and ATN_IN and ATN_OUT_p8;
EOI_bus <= EOI_OUT_pet and EOI_IN and EOI_OUT_p8;
data_IEEE_488_bus <= data_out_IEEE_488_pet and Data_in_IEEE_488 and data_out_IEEE_488_p8;

--Bus externe IEEE 488 GPIB
DAV_OUT <= DAV_OUT_pet;
NRFD_OUT <= NRFD_OUT_pet;
NDAC_OUT <= NDAC_OUT_pet;
ATN_OUT <= ATN_OUT_pet;
EOI_OUT <= EOI_OUT_pet;
Data_out_IEEE_488 <= data_out_IEEE_488_pet;
--
--DAV_bus <= DAV_IN;
--NRFD_bus <= NRFD_IN;
--NDAC_bus <= NDAC_IN;
--ATN_bus <= ATN_IN;
--EOI_bus <= EOI_IN;
--data_IEEE_488_bus <= data_in_IEEE_488;


	test_2 <= x"FF" & data_IEEE_488_bus & "000" & EOI_bus & NDAC_bus & NRFD_bus & DAV_bus & ATN_bus;
--test(6 downto 0) <= "00" & EOI_bus & NDAC_bus & NRFD_bus & DAV_bus & ATN_bus;

end Behavioral;

