library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Botones is
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		btn     : in  std_logic;
		display : out std_logic_vector(6 downto 0)
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
	
	signal res : std_logic := '0';
	signal cuenta : integer := 0;

begin

	B1 : debounce generic map(50_000_000, 10)
		port map(clk, rst, btn, res);
	
	process(res) is
	begin
		if rising_edge(res) then
			if cuenta <= 9 then
				cuenta <= cuenta + 1;
			else
				cuenta <= 0;
			end if;
		end if;
	end process;
	
	with cuenta select
		display <= "1000000" when 0,
			"1111001" when 1,
			"0100100" when 2,
			"0110000" when 3,
			"0011001" when 4,
			"0010010" when 5,
			"0000010" when 6,
			"1111000" when 7,
			"0000000" when 8,
			"0010000" when 9,
			"1000000" when others;
	
end rtl;