library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Divisor is
	generic (N : integer := 24);
	port ( 
		clk : in std_logic;
		div_clk : out std_logic
	);
end Divisor;

architecture Behavioral of divisor is
begin	
	process (clk)
		variable cuenta: std_logic_vector (27 downto 0) := X"0000000";
	begin
		if rising_edge (clk) then
			cuenta := cuenta + 1;
		end if;
		div_clk <= cuenta (N);
	end process;
end Behavioral;