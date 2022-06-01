-- Precio de los productos
--		Coca-Cola $15
--		Takis     $12
--		Leche     $13
--		Sauris    $10


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Botones is
	port (
		clk      : in  std_logic;
		-- Botones
		btn1     : in  std_logic;
		btn5     : in  std_logic;
		-- Teclado
		col      : in 	std_logic_vector(3 downto 0);
		ren      : out std_logic_vector(3 downto 0);
		-- Motores
		MOT1     : out std_logic_vector(3 downto 0);
		MOT2     : out std_logic_vector(3 downto 0);
		MOT3     : out std_logic_vector(3 downto 0);
		MOT4     : out std_logic_vector(3 downto 0);
		-- Displays
		display1 : out std_logic_vector(6 downto 0);
		display2 : out std_logic_vector(6 downto 0);
		display3 : out std_logic_vector(6 downto 0)
	);
end Botones;

architecture rtl of Botones is

	constant delayms : integer := (50_000_000/10000)-1;

	component TecMatrix is
		generic (freq_clk: integer := 50_000_00);
		port (
			clk      : in  std_logic;
			cols     : in  std_logic_vector(3 downto 0);
			filas    : out std_logic_vector(3 downto 0);
			btn_pres : out std_logic_vector (3 downto 0);
			indica   : out std_logic
		);
	end component;
	
	signal btn_pres : std_logic_vector(3 downto 0) := (others => '0');
	signal ind  : std_logic := '0';
	signal code : std_logic_vector(2 downto 0) := "000";
	signal init : std_logic := '0';
	
	component debounce is
		generic(
    		clk_freq    : integer := 50_000_000;  --system clock frequency in Hz
    		stable_time : integer := 10);         --time button must remain stable in ms
		port(
			clk     : in  std_logic;  --input clock
			reset_n : in  std_logic;  --asynchronous active low reset
			button  : in  std_logic;  --input signal to be debounced
			result  : out std_logic   --debounced signal
		);
	end component;
	
	signal res1, res5 : std_logic := '0';
	signal cuenta1, cuenta5 : integer := 0;
	signal moneda1 : std_logic;
	signal moneda5 : std_logic;
	
	component Pasos is
		port ( 
			clk  : in  std_logic;
			rst  : in  std_logic;
			dir  : in  std_logic;
			MOT  : out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal rstM1, rstM2, rstM3, rstM4 : std_logic := '1';
	
	signal precio, unidades, decenas : integer range 0 to 99 := 99;
	signal cambio : integer range 0 to 10 := 0;
	signal sele : std_logic := '0';

begin

	T0 : TecMatrix generic map(50_000_000) 
		port map(clk, col, ren, btn_pres, ind);
	
	B1 : debounce generic map(50_000_000, 10) port map(clk, '1', btn1, res1);
	B5 : debounce generic map(50_000_000, 10) port map(clk, '1', btn5, res5);
	
	M1 : Pasos port map(clk, rstM1, '1', MOT1);
	M2 : Pasos port map(clk, rstM2, '0', MOT2);
	M3 : Pasos port map(clk, rstM3, '1', MOT3);
	M4 : Pasos port map(clk, rstM4, '1', MOT4);
	
	-- Seleccion del producto y asignacion del precio --
	process(clk)
		variable conta : integer := 0;
	begin
		if rising_edge(clk) then
			if ind = '1' and btn_pres = x"1" then 
				code   <= "001";
				precio <= 15;
				init   <= '1';
			elsif ind = '1' and btn_pres = x"2" then 
				code   <= "010";
				precio <= 12;
				init   <= '1';
			elsif ind = '1' and btn_pres = x"3" then 
				code   <= "011";
				precio <= 13;
				init   <= '1';
			elsif ind = '1' and btn_pres = x"4" then 
				code   <= "100";
				precio <= 10;
				init   <= '1';
			else
				code <= code;
				if conta = delayms then
					init <= '0';
					conta := 0;
				else
					conta := conta + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- Sumador de $1 --
	process(init, res1)	
	begin
		if init = '1' then
			cuenta1 <= 0;
		elsif rising_edge(res1) then
			if cuenta1 = precio then
				cuenta1 <= 0;
			else
				cuenta1 <= cuenta1 + 1;
			end if;
		end if;
	end process;
	
	-- Sumador de $5 --
	process(init, res5)
	begin
		if init = '1' then
			cuenta5 <= 0;
		elsif rising_edge(res5) then
			if cuenta5 >= precio then
				cuenta5 <= 0;
			else
				cuenta5 <= cuenta5 + 5;
			end if;
		end if;
	end process;
	
	-- Asignacion de dinero y cambio --
	unidades <= cuenta1 + cuenta5;
	decenas  <= cuenta1 + cuenta5;
	cambio   <= unidades - precio;
	
	-- Activacion de motores --
	process(clk)	
	begin
		if clk'event and clk = '1' then
			if    code = "001" and unidades >= precio then 
				rstM1 <= '0';
				sele  <= '1';
			elsif code = "010" and unidades >= precio then 
				rstM2 <= '0';
				sele  <= '1';
			elsif code = "011" and unidades >= precio then 
				rstM3 <= '0';
				sele  <= '1';
			elsif code = "100" and unidades >= precio then 
				rstM4 <= '0';
				sele  <= '1';
			end if;
		end if;
	end process;
	
	-- Displays dinero colocado --
	with unidades select display1 <=	
		"1111001" when 1,
		"0100100" when 2,
		"0110000" when 3,
		"0011001" when 4,
		"0010010" when 5,
		"0000010" when 6,
		"1111000" when 7,
		"0000000" when 8,
		"0010000" when 9,
		"1000000" when 10,
		"1111001" when 11,
		"0100100" when 12,
		"0110000" when 13,
		"0011001" when 14,
		"0010010" when 15,
		"1111111" when others;
	
	with decenas select display2 <= 
		"1111001" when 10,
		"1111001" when 11,
		"1111001" when 12,
		"1111001" when 13,
		"1111001" when 14,
		"1111001" when 15,
		"1111111" when others;
	
	-- Display cambio --
	process(sele)
	begin
		if sele = '1' then
			case cambio is
				when 1 => display3 <= "1111001";
				when 2 => display3 <= "0100100";
				when 3 => display3 <= "0110000";
				when 4 => display3 <= "0011001";
				when others => display3 <= "1111111";
			end case;
		else
			case cambio is
				when others => display3 <= "1111111";
			end case;
		end if;
	end process;

end rtl;