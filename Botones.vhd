library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Botones is
	port (
		clk      : in  std_logic;
		btn1     : in  std_logic;
		btn5     : in  std_logic;
		col      : in 	std_logic_vector(3 downto 0);
		ren      : out std_logic_vector(3 downto 0);
		display1 : out std_logic_vector(6 downto 0)
	);
end Botones;

architecture rtl of Botones is

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
		PORT(
			clk     : in  std_logic;  --input clock
			reset_n : in  std_logic;  --asynchronous active low reset
			button  : in  std_logic;  --input signal to be debounced
			result  : out std_logic   --debounced signal
		);
	end component;
	
	signal res1, res5 : std_logic := '0';
	signal cuenta1, cuenta5 : integer range 0 to 15 := 15;
	signal moneda1 : std_logic;
	signal moneda5 : std_logic;
	
	signal precio : integer range 0 to 15 := 0;
	signal total  : integer range 0 to 15 := 0;
	
	constant delayms : integer := (50_000_00/10000)-1;

begin

	T0 : TecMatrix generic map(50_000_000) 
		port map(clk, col, ren, btn_pres, ind);
	B1 : debounce port map(clk, '1', btn1, res1);
	B5 : debounce port map(clk, '1', btn5, res5);
	
	process(clk)
		variable conta : integer := 0;
	begin
		if rising_edge(clk) then
			if ind = '1' and btn_pres = x"1" then 
				code   <= "001";
				precio <= 15;	--f
				init   <= '1';
			elsif ind = '1' and btn_pres = x"2" then 
				code   <= "010";
				precio <= 12;	--c
				init   <= '1';
			elsif ind = '1' and btn_pres = x"3" then 
				code   <= "011";
				precio <= 13;	--d
				init   <= '1';
			elsif ind = '1' and btn_pres = x"4" then 
				code   <= "100";
				precio <= 10;	--a
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
	
	process(init, res1) is -- Boton moneda de $1
	begin
		if init = '1' then
			cuenta1 <= 0;
		elsif rising_edge(res1) then
			if cuenta1 = precio then
				cuenta1 <= cuenta1 + 1;
			else
				cuenta1 <= 0;
			end if;
		end if;
	end process;
	
	process(res5) is -- Boton moneda de $5
	begin
		if init = '1' then
			cuenta5 <= 0;
		elsif rising_edge(res5) then
			if cuenta5 = precio then
				cuenta5 <= cuenta5 + 5;
			else
				cuenta5 <= 0;
			end if;
		end if;
	end process;
	
	total <= cuenta1 + cuenta5;
	
	with total select
		display1 <= "1000000" when 0,
			"1111001" when 1,
			"0100100" when 2,
			"0110000" when 3,
			"0011001" when 4,
			"0010010" when 5,
			"0000010" when 6,
			"1111000" when 7,
			"0000000" when 8,
			"0010000" when 9,
			"0001000" when 10,--a
			"0000011" when 11,--b 
			"1000110" when 12,--c
			"0100001" when 13,--d
			"0000110" when 14,--e
			"0001110" when 15;--f

end rtl;