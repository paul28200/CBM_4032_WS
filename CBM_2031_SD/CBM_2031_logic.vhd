----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:44:07 06/17/2019 
-- Design Name: 
-- Module Name:    CBM_2031_logic - Behavioral 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CBM_2031_logic is
    Port ( clk_32MHz, clk_8MHz, clk_4MHz, clk_2MHz, clk_1MHz, phi2, rst : in  STD_LOGIC;
	 
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
			 act             : out std_logic                       -- activity LED
			  );
end CBM_2031_logic;

architecture Behavioral of CBM_2031_logic is

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

	COMPONENT RAM_2031_2k
	  PORT (
		 clka : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;

	COMPONENT ROM_2031_C000
	  PORT (
		 clka : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;

	COMPONENT ROM_2031_E000
	  PORT (
		 clka : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;

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

--Bus du 6502
	signal address_bus_6502 : std_logic_vector(15 downto 0);
	signal data_bus_in_6502, data_bus_out_6502 : std_logic_vector(7 downto 0);
	signal irq, rst_n, we_n_control_6502, we_control_6502, we_sync : std_logic;

--Signaux VIA
	signal irq_UAB1, irq_UCD4, ena_UAB1, ena_UCD4, ena_UAB1_tmp, ena_UCD4_tmp : std_logic;
	signal data_UAB1, data_UCD4 : std_logic_vector(7 downto 0);
	signal pa_i_UAB1, pa_o_UAB1, pa_oe_UAB1, pb_i_UAB1, pb_o_UAB1, pb_oe_UAB1 : std_logic_vector(7 downto 0);
	signal pa_i_UCD4, pa_o_UCD4, pa_oe_UCD4, pb_i_UCD4, pb_o_UCD4, pb_oe_UCD4 : std_logic_vector(7 downto 0);
	signal VB_I, VB_O, VB_OE : std_logic_vector(7 downto 0);
	signal UCD4_CA1_I, UCD4_CA2_I, UCD4_CA2_O, UCD4_CA2_OE, UCD4_CB2_I, UCD4_CB2_O, UCD4_CB2_OE : std_logic;
	
--Signaux Mémoires
	signal ena_RAM, ena_ROM_C, ena_ROM_E, ena_RAM_tmp, ena_ROM_C_tmp, ena_ROM_E_tmp : std_logic;
	signal data_RAM, data_ROM_C, data_ROM_E : std_logic_vector(7 downto 0);
	
--Signaux IEEE 488
	signal ATN_N_IN, T_R, CB2_VIA_tmp, NRFD_OUT_tmp, NDAC_OUT_tmp, NRFD_IN_tmp, NDAC_IN_tmp, EOI_OUT_tmp, DAV_OUT_tmp, DAV_IN_tmp, EOI_IN_tmp : std_logic;
	signal HD_SEL, CA2_UAB1, CA2_OE_UAB1, ATNA_OUT, ATNA_IN, PLL_SYN, UAB1_PB_7 : std_logic;
	signal DATA_IN_tmp, DATA_OUT_tmp, DATA_OUT_OE : std_logic_vector(7 downto 0);
	signal DC, TE : std_logic;
	
--Signaux drive
	signal cpu_so_n, soe : std_logic;

--Selection du n° device
	--constant ds : std_logic_vector(1 downto 0) := "00";	-- 00 = #8, 01 = #9, 10 = #10, 11 = #11

--Test clk
	signal test_clk : std_logic;

begin

	Inst_R6502 : r6502_tc port map( 
			clk_clk_i => clk_1MHz,
			d_i => data_bus_in_6502,
			irq_n_i => irq,
			nmi_n_i => '1',
			rdy_i => '1',
			rst_rst_n_i =>rst_n,
			so_n_i => cpu_so_n, --'1',
			a_o => address_bus_6502,
			d_o => data_bus_out_6502,
			rd_o => open,
			sync_o => open,
			wr_n_o => we_n_control_6502,
			wr_o => we_control_6502
		);
    rst_n <= not rst;
	
	we_sync <= we_control_6502 and phi2; --(not clk_1MHz) and (not clk_2MHz);	-- Le signal WE du 6502 doit être masqué par l'horloge pour arrêter l'ecriture en RAM dès la fin de l'instruction
	irq <= irq_UAB1 and irq_UCD4;
	
--Decodage d'adresses
process(clk_32MHz)
begin
	if clk_32MHz = '1' and clk_32MHz'event then
		if address_bus_6502(15 downto 11) = "00000" then ena_RAM_tmp <= '1'; else ena_RAM_tmp <= '0'; end if;
		if address_bus_6502(15 downto 13) = "110" then ena_ROM_C_tmp <= '1'; else ena_ROM_C_tmp <= '0'; end if;
		if address_bus_6502(15 downto 13) = "111" then ena_ROM_E_tmp <= '1'; else ena_ROM_E_tmp <= '0'; end if;
		if address_bus_6502(15 downto 10) = "000110" then ena_UAB1_tmp <= '1'; else ena_UAB1_tmp <= '0'; end if;		--$1800
		if address_bus_6502(15 downto 10) = "000111" then ena_UCD4_tmp <= '1'; else ena_UCD4_tmp <= '0'; end if;		--$1C00
	end if;
	ena_RAM <= ena_RAM_tmp;
	ena_ROM_C <= ena_ROM_C_tmp;
	ena_ROM_E <= ena_ROM_E_tmp;
	ena_UAB1 <= ena_UAB1_tmp;
	ena_UCD4 <= ena_UCD4_tmp;
end process;

--Bus de données 6502
	data_bus_in_6502 <= data_RAM when address_bus_6502(15 downto 11) = "00000" else
						data_ROM_C when address_bus_6502(15 downto 13) = "110" else
						data_ROM_E when address_bus_6502(15 downto 13) = "111" else
						data_UAB1 when address_bus_6502(15 downto 10) = "000110" else
						data_UCD4 when address_bus_6502(15 downto 10) = "000111" else
						address_bus_6502(15 downto 8);
						
	--RAM 2k $0000-$07FF
	 Inst_RAM_2k : RAM_2031_2k
	  PORT MAP (
		 clka => clk_4MHz,
		 ena => ena_RAM,
		 wea(0) => we_sync,
		 addra => address_bus_6502(10 downto 0),
		 dina => data_bus_out_6502,
		 douta => data_RAM
	  );
	 
	 --ROM 8k $C000-$DFFF
	 Inst_ROM_C000 : ROM_2031_C000
	  PORT MAP (
		 clka => clk_4MHz,
		 ena => ena_ROM_C,
		 addra => address_bus_6502(12 downto 0),
		 douta => data_ROM_C
	  );
	 
	 --ROM 8k $E000-$FFFF
	 Inst_ROM_E000 : ROM_2031_E000
	  PORT MAP (
		 clka => clk_4MHz,
		 ena => ena_ROM_E,
		 addra => address_bus_6502(12 downto 0),
		 douta => data_ROM_E
	  );
 
	--VIA IEEE 488 control
	Inst_VIA_UAB1 : M6522 port map(
		 I_RS => address_bus_6502(3 downto 0),	 	 
		 I_DATA => data_bus_out_6502,
		 O_DATA => data_UAB1,
		 O_DATA_OE_L => open, --la sélection est faite par le décodeur d'adresses

		 I_RW_L => we_n_control_6502,
		 I_CS1 => ena_UAB1,
		 I_CS2_L => '0',	--la sélection du VIA se fait uniquement avec Ena_VIA

		 O_IRQ_L => irq_UAB1,
		 -- port a
		 I_CA1 => ATN_N_IN, 
		 I_CA2 => CA2_UAB1,
		 O_CA2 => CA2_UAB1,
		 O_CA2_OE_L => CA2_OE_UAB1,

		 I_PA => DATA_IN_tmp,
		 O_PA => DATA_OUT_tmp,
		 O_PA_OE_L => DATA_OUT_OE,

		 -- port b
		 I_CB1 => '1',
		 O_CB1 => open,
		 O_CB1_OE_L => open,

		 I_CB2 => PLL_SYN,
		 O_CB2 => PLL_SYN,
		 O_CB2_OE_L => open,

		 I_PB => pb_i_UAB1,
		 O_PB => pb_o_UAB1,
		 O_PB_OE_L => pb_oe_UAB1,

		 I_P2_H => phi2, -- high for phase 2 clock  ____----__
		 RESET_L => rst_n,
		 ENA_4 => clk_4MHz, -- clk enable
		 CLK => clk_8MHz);

--Logique câblée des sorties IEEE 488
pb_i_UAB1 <= (pb_o_UAB1 or pb_oe_UAB1) and (ATN_N_IN & DAV_IN_tmp & "11" &
					EOI_IN_tmp & NDAC_IN_tmp & NRFD_IN_tmp & ATNA_IN);
		 ATNA_OUT 		<= pb_o_UAB1(0) or pb_oe_UAB1(0);
		 NRFD_OUT_tmp	<= pb_o_UAB1(1) or pb_oe_UAB1(1);
		 NDAC_OUT_tmp	<= pb_o_UAB1(2) or pb_oe_UAB1(2);
		 EOI_OUT_tmp	<= pb_o_UAB1(3) or pb_oe_UAB1(3);
		 T_R				<= pb_o_UAB1(4) or pb_oe_UAB1(4);
		 HD_SEL			<= pb_o_UAB1(5) or pb_oe_UAB1(5);
		 DAV_OUT_tmp	<= pb_o_UAB1(6) or pb_oe_UAB1(6);


	DC <= '1';
	TE <= T_R;

	ATN_N_IN <= (not ATN_IN) when DC = '1' else '0';
	ATN_OUT <= '1';
	ATNA_IN <= ATNA_OUT and (ds(0) or CA2_UAB1 or CA2_OE_UAB1);

	NRFD_OUT <= (NRFD_OUT_tmp or TE) and (not (ATNA_OUT xor ATN_N_IN));		--NRFD est transmis uniquement si TE = '0';
	NRFD_IN_tmp <= NRFD_IN when TE ='1' else (ds(1) or CA2_UAB1 or CA2_OE_UAB1) and NRFD_OUT_tmp;

	NDAC_OUT <= (NDAC_OUT_tmp or TE) and (not (ATNA_OUT xor ATN_N_IN));	--NDAC est transmis uniquement si TE = '0';
	NDAC_IN_tmp <= NDAC_IN when TE ='1' else NDAC_OUT_tmp;

	DAV_OUT <= DAV_OUT_tmp when TE ='1' else '1';			--DAV_OUT est transmis uniquement si TE = '1';
	DAV_IN_tmp <= DAV_IN when TE ='0' else DAV_OUT_tmp;	--DAV_IN est reçu uniquement si TE = '0';

	EOI_OUT <= EOI_OUT_tmp; -- when (T_R xor ATN_IN)='0' else '1';
	EOI_IN_tmp <= EOI_IN when ((DC xor ATN_IN)='1' or (DC xor TE)='1') else EOI_OUT_tmp;

	DATA_OUT <= (DATA_OUT_tmp or DATA_OUT_OE) when T_R ='1' else x"FF";		--DATA_OUT est transmis uniquement si T_R = '1';
	DATA_IN_tmp <= DATA_IN when T_R ='0' else DATA_OUT_tmp; --DATA_IN est reçu uniquement si T_R = '0';


	--VIA disk control
 	Inst_VIA_UCD4 : M6522 port map(
		 I_RS => address_bus_6502(3 downto 0),	 	 
		 I_DATA => data_bus_out_6502,
		 O_DATA => data_UCD4,
		 O_DATA_OE_L => open, --la sélection est faite par le décodeur d'adresses

		 I_RW_L => we_n_control_6502,
		 I_CS1 => ena_UCD4,
		 I_CS2_L => '0',	--la sélection du VIA se fait uniquement avec Ena_VIA

		 O_IRQ_L => irq_UCD4,
		 -- port a
		 I_CA1 => UCD4_CA1_I,
		 I_CA2 => UCD4_CA2_I,
		 O_CA2 => UCD4_CA2_O,
		 O_CA2_OE_L => UCD4_CA2_OE,

		 I_PA => VB_I,
		 O_PA => VB_O,
		 O_PA_OE_L => VB_OE,

		 -- port b
		 I_CB1 => '1',
		 O_CB1 => open,
		 O_CB1_OE_L => open,

		 I_CB2 => UCD4_CB2_I,
		 O_CB2 => UCD4_CB2_O,
		 O_CB2_OE_L => UCD4_CB2_OE,

		 I_PB => pb_i_UCD4,
		 O_PB => pb_o_UCD4,
		 O_PB_OE_L => pb_oe_UCD4,

		 I_P2_H => phi2, -- high for phase 2 clock  ____----__
		 RESET_L => rst_n,
		 ENA_4 => clk_4MHz, -- clk enable
		 CLK => clk_8MHz);



  --
  -- hook up UCD4 ports

  -- CA1
  UCD4_CA1_I <= cpu_so_n; -- byte ready gated with soe
  -- CA2
  soe <= UCD4_CA2_O or UCD4_CA2_OE;
  -- PA
  VB_I <= di;
  do <= VB_O or VB_OE;
  -- CB2
  mode <= UCD4_CB2_O or UCD4_CB2_OE;
  -- PB
  stp(1) <= pb_o_UCD4(0) or pb_oe_UCD4(0);
  stp(0) <= pb_o_UCD4(1) or pb_oe_UCD4(1);
  mtr <= pb_o_UCD4(2) or pb_oe_UCD4(2);
  act <= pb_o_UCD4(3) or pb_oe_UCD4(3);
  freq <= pb_o_UCD4(6 downto 5) or pb_oe_UCD4(6 downto 5);
  pb_i_UCD4 <= sync_n & "11" & wps_n & "1111";

  cpu_so_n <= byte_n or not soe; 


end Behavioral;


