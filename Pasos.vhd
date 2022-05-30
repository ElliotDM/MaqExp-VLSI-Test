library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Pasos is
	port ( 
		clk  : in  std_logic;
		rst  : in  std_logic;
		MOT  : out std_logic_vector(3 downto 0)
	);
end Pasos;

architecture Behavioral of Pasos is
	component Divisor is 
		generic (N : integer := 24);
		port ( 
			clk : in std_logic;
			div_clk : out std_logic
		);
	end component;
	
	component MotPasos is
		port ( 
			clk : in  std_logic;
			rst : in  std_logic;
			UD  : in  std_logic;
			FH  : in  std_logic_vector(1 downto 0);
			MOT : out std_logic_vector(3 downto 0)
		);
	end component;
	
	signal avanza : std_logic := '1';
	signal rstM   : std_logic := '1';
	signal reloj  : std_logic;
	
begin
	D : Divisor generic map(17) port map (clk, reloj);
	P : MotPasos port map(avanza, rstM, '0', "01", MOT);
	
	process (reloj)
		variable ctrl  : integer := 0;
		variable sigue : std_logic := '1';
	begin
		if reloj'event and reloj = '1' then
			
			if ctrl < 2000 then
				rstM <= rst;
				sigue := not sigue;
				ctrl := ctrl + 1;
			else
				rstM <= '1';
			end if;
		end if;
		avanza <= sigue;
	end process;
end Behavioral;