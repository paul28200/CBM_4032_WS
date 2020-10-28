----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:23:49 11/19/2018 
-- Design Name: 
-- Module Name:    Generation_Video - Behavioral 
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

entity Generation_Video is
			port(	clk_50Mhz : in std_logic;
					VGA_VSYNC, VGA_HSYNC : out std_logic;
					VGA_GREEN : out std_logic;
					Adresse_RAM_Video : in std_logic_vector(10 downto 0);
					Donnee_RAM_Video_in : in std_logic_vector(7 downto 0);
					Donnee_RAM_Video_out : out std_logic_vector(7 downto 0);
					Donnee_reg_CRTC_out : out std_logic_vector(7 downto 0);
					we : in std_logic;		--	we = 1 pour écrire dans la RAM vidéo
					ena : in std_logic;		-- ena = 1 pour activer l'accès à la RAM vidéo
					ena_crtc : in std_logic; -- ena=1 pour accéder au registre du CRTC
					graphic : in std_logic);	-- graphic = 0 pour jeu de caractères graphiques
					
end Generation_Video;

architecture Behavioral of Generation_Video is
					signal clk_25MHz : std_logic;
					signal VGA_OUT_enable : std_logic;
					signal displayed_character : std_logic_vector(7 downto 0);
					signal address_displayed_character, address_displayed_character_tmp : STD_LOGIC_VECTOR (10 downto 0);
					signal we_tmp : std_logic;
					signal pixel_col : std_logic_vector(3 downto 0);
					signal pixel_col_tmp : std_logic_vector(2 downto 0);
					signal pixel_line : std_logic_vector(4 downto 0);
					signal interligne, select_mode : std_logic;
					signal address_displayed_character_col : integer range 0 to 80:=0;
					signal address_displayed_character_line : integer range 0 to 2000:=0;
		
					--test
					signal displayed_character_tmp : std_logic_vector(7 downto 0);
				
	component VGA_Sync_gen port (clk_25MHz : in std_logic;
								pixel_col_out : out std_logic_vector(3 downto 0);
								pixel_line_out : out std_logic_vector(4 downto 0);
								VGA_VSYNC, VGA_HSYNC, VGA_OUT_enable : out std_logic;
								address_displayed_character_col : buffer integer range 0 to 80:=0;
								address_displayed_character_line : buffer integer range 0 to 2000:=0;
								interligne : in std_logic);
								end component;
								
	component Chargen port (clk_25MHz : in  STD_LOGIC;
								pixel_col : in  STD_LOGIC_VECTOR (2 downto 0);
								pixel_line : in  STD_LOGIC_VECTOR (4 downto 0);
								graphic : in  STD_LOGIC;
								displayed_character : in  STD_LOGIC_VECTOR (7 downto 0);
								VGA_OUT_enable : in STD_LOGIC;
								VGA_OUT : out  STD_LOGIC);
								end component;
								
	component RAM_video_2k port (
							   clka : IN STD_LOGIC;
							   ena : IN STD_LOGIC;
							   wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
							   addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
							   dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
							   douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
							   clkb : IN STD_LOGIC;
							   web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
							   addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
							   dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
							   doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
								end component;

	component CRTC_registres port (
							  clk : in  STD_LOGIC;
							  ena : in  STD_LOGIC;
							  data_in : in  STD_LOGIC_VECTOR (7 downto 0);
							  data_out : out  STD_LOGIC_VECTOR (7 downto 0);
							  rs : in  STD_LOGIC;
							  we : in  STD_LOGIC;
							  interligne : out  STD_LOGIC;
							  select_mode : out	STD_LOGIC);
								end component;
							 
begin
	--Clock 25MHz
	process(clk_50MHz)
	begin
		if clk_50MHz='1' and clk_50MHz'event then
			clk_25MHz <= not clk_25MHz;
		end if;
	end process;


	Inst_VGA_Sync_gen : VGA_Sync_gen port map (
								clk_25MHz => clk_25MHz,
								pixel_col_out => pixel_col,
								pixel_line_out => pixel_line,
								VGA_VSYNC => VGA_VSYNC,
								VGA_HSYNC => VGA_HSYNC,
								VGA_OUT_enable => VGA_OUT_enable,
								address_displayed_character_col => address_displayed_character_col,
								address_displayed_character_line => address_displayed_character_line,
								interligne => interligne);
	
	Inst_Chargen : Chargen port map( 
								clk_25MHz => clk_25MHz,
								pixel_col => pixel_col_tmp,
								pixel_line => pixel_line,
								graphic => graphic,
								displayed_character => displayed_character,
								VGA_OUT_enable => VGA_OUT_enable,
								VGA_OUT => VGA_GREEN);
	
	we_tmp <= we and ena;
	-- Select screen mode : 40 char display when select_mode = 0, else 80 char
	pixel_col_tmp <= pixel_col(3 downto 1) when select_mode = '0'
							else pixel_col(2 downto 0);
	address_displayed_character_tmp <= '0' & address_displayed_character (10 downto 1) when select_mode = '0'
							else address_displayed_character (10 downto 0);
	
	address_displayed_character (10 downto 0) <= std_logic_vector(to_unsigned((address_displayed_character_col + address_displayed_character_line),11));

	
	Inst_RAM_video : RAM_video_2k port map (
								clka => clk_25MHz,
								ena => ena,
								wea(0) => we,
								addra => Adresse_RAM_Video(10 downto 0),
								dina => Donnee_RAM_Video_in,
								douta => Donnee_RAM_Video_out,
								clkb => clk_25MHz,
								web(0) => '0',
								addrb => address_displayed_character_tmp,
								dinb => "--------",
								doutb => displayed_character);

	Inst_CRTC_reg : CRTC_registres port map(
							  clk => clk_25MHz,
							  ena => ena_crtc,
							  data_in => Donnee_RAM_Video_in,
							  data_out => Donnee_reg_CRTC_out,
							  rs => Adresse_RAM_Video(0),
							  we => we,
							  interligne => interligne,
							  select_mode => select_mode);
							  


end Behavioral;

