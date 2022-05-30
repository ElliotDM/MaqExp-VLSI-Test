library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Botones is
	port (
		clk      : in  std_logic;
		rst      : in  std_logic;
		btn1     : in  std_logic;
		btn5     : in  std_logic;
		display1 : out std_logic_vector(6 downto 0)
	);
end Botones;

architecture rtl of Botones is
	
	component debounce is
		GENERIC(
			clk_freq    : INTEGER := 50_000_000;  --system clock frequency in Hz
			stable_time : INTEGER := 10);         --time button must remain stable in ms
		PORT(
			clk     : IN  STD_LOGIC;  --input clock
			reset_n : IN  STD_LOGIC;  --asynchronous active low reset
			button  : IN  STD_LOGIC;  --input signal to be debounced
			result  : OUT STD_LOGIC); --debounced signal
	end component;
	
	signal res1, res5 : std_logic := '0';
	signal cuenta1, cuenta5 : integer range 0 to 15 := 15;
	signal total : integer range 0 to 15 := 0;

begin

	B1 : debounce generic map(50_000_000, 10)
		port map(clk, rst, btn1, res1);
	
	B5 : debounce generic map(50_000_000, 10)
		port map(clk, rst, btn5, res5);
	
	process(res1) is -- Boton moneda de $1
	begin
		if rising_edge(res1) then
			if cuenta1 = 15 then
				cuenta1 <= 0;
			else
				cuenta1 <= cuenta1 + 1;
			end if;
		end if;
	end process;
	
	process(res5) is -- Boton moneda de $5
	begin
		if rising_edge(res5) then
			if cuenta5 = 15 then
				cuenta5 <= 0;
			else
				cuenta5 <= cuenta5 + 5;
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