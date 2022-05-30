library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Motores is
	port (
		clk  : in  std_logic;
		col  : in  std_logic_vector(3 downto 0);
		ren  : out std_logic_vector(3 downto 0);
		MOT1 : out std_logic_vector(3 downto 0);
		MOT2 : out std_logic_vector(3 downto 0);
		MOT3 : out std_logic_vector(3 downto 0);
		MOT4 : out std_logic_vector(3 downto 0);
		leds : out std_logic_vector(2 downto 0)
	);
end entity;

architecture rtl of Motores is
	component TecMatrix is
		generic (
			freq_clk: integer := 50_000_00
		);
		port (
			clk      : in  std_logic;
			cols     : in  std_logic_vector(3 downto 0);
			filas    : out std_logic_vector(3 downto 0);
			btn_pres : out std_logic_vector(3 downto 0);
			indica   : out std_logic
		);
	end component;
	
	signal btn_pres : std_logic_vector(3 downto 0) := (others => '0');
	signal ind  : std_logic := '0';
	signal code : std_logic_vector(2 downto 0) := "000";
	
	component Pasos is
		port ( 
			clk  : in std_logic;
			rst  : in std_logic;
			MOT  : out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal rstM1 : std_logic := '1';
	signal rstM2 : std_logic := '1';
	signal rstM3 : std_logic := '1';
	signal rstM4 : std_logic := '1';
	
begin
	M1 : Pasos port map(clk, rstM1, MOT1);
	M2 : Pasos port map(clk, rstM2, MOT2);
	M3 : Pasos port map(clk, rstM3, MOT3);
	M4 : Pasos port map(clk, rstM4, MOT4);

	T0 : tecMatrix generic map(freq_clk => 50_000_000) 
						port map(clk, col, ren, btn_pres, ind);
	
	Teclado : process(clk)
	begin
		if rising_edge(clk) then
			if    ind = '1' and btn_pres = x"1" then code <= "001";
			elsif ind = '1' and btn_pres = x"2" then code <= "010";
			elsif ind = '1' and btn_pres = x"3" then code <= "011";
			elsif ind = '1' and btn_pres = x"4" then code <= "100";
			else
				code <= code;
			end if;
		end if;
	end process;
	
	process (clk)
		variable ctrl : integer := 0;
	begin
		if clk'event and clk = '1' then
			if    code = "001" then rstM1 <= '0';
			elsif code = "010" then rstM2 <= '0';
			elsif code = "011" then rstM3 <= '0';
			elsif code = "100" then rstM4 <= '0';
			end if;
		end if;
	end process;
	
	leds <= code;
end rtl;