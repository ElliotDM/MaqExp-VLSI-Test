library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TecMatrix is
	generic (
		freq_clk: integer := 50_000_00
	);
	port (
		clk      : in  std_logic;
		cols     : in  std_logic_vector(3 downto 0);
		filas    : out std_logic_vector(3 downto 0);
		btn_pres : out std_logic_vector (3 downto 0);
		indica   : out std_logic
	);
end TecMatrix;

architecture rtl of TecMatrix is
	constant delay1ms  : integer := (freq_clk/1000)-1;
	constant delay10ms : integer := (freq_clk/100)-1;

	signal contador1ms  : integer range 0 to delay1ms := 0;
	signal contador10ms : integer range 0 to delay10ms := 0;
	signal bandera1 : std_logic := '0';
	signal bandera2 : std_logic := '0';

	signal btn1  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn2  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn3  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn4  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn5  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn6  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn7  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn8  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn9  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btnA  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btnB  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btnC  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btnD  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btn0  : std_logic_vector(7 downto 0)	:= (others=>'0');
	signal btnAS : std_logic_vector(7 downto 0) := (others=>'0');
	signal btnGA : std_logic_vector(7 downto 0) := (others=>'0');

	signal fila_reg_s : std_logic_vector(3 downto 0) := (others=>'0');
	signal fila : integer range 0 to 3 := 0;
	signal IND_S : std_logic := '0';
	signal estado : integer range 0 to 1 := 0;

	begin
		filas <= fila_reg_S;
		-- Bloque para el retardo de 1ms
		process(clk)
			begin
				if (rising_edge(clk)) then
					contador1ms <= contador1ms + 1;
					bandera1 <= '0';
					if (contador1ms = delay1ms) then
						contador1ms <= 0;
						bandera1 <= '1';
					end if;
				end if;
			end process;

		-- Bloque para el retardo de 10ms
		process(clk)
			begin
				if (rising_edge(clk)) then
					contador10ms <= contador10ms + 1;
					bandera2 <= '0';
					if (contador10ms = delay10ms) then
						contador10ms <= 0;
						bandera2 <= '1';
					end if;
				end if;
			end process;

		-- Bloque para avanzar entre filas
		process(clk, bandera2)
			begin
				if (rising_edge(clk) and bandera2 = '1') then
					fila <= fila + 1;
					if (fila = 3) then
						fila <= 0;
					end if;
				end if;
			end process;

		-- registro de fila
		with fila select
			fila_reg_s <= 	"1000" when 0,
							"0100" when 1,
							"0010" when 2,
							"0001" when others;

		-- Bloque para seleccionar un valor del teclado
		process(clk, bandera1)
			begin
				if (rising_edge(clk) and bandera1 = '1') then
					if (fila_reg_s = "1000") then -- primera fila
						btn1 <= btn1(6 downto 0)&cols(3);
						btn2 <= btn2(6 downto 0)&cols(2);
						btn3 <= btn3(6 downto 0)&cols(1);
						btnA <= btnA(6 downto 0)&cols(0);
					elsif (fila_reg_s = "0100") then -- segunda fila
						btn4 <= btn4(6 downto 0)&cols(3);
						btn5 <= btn5(6 downto 0)&cols(2);
						btn6 <= btn6(6 downto 0)&cols(1);
						btnB <= btnB(6 downto 0)&cols(0);
					elsif (fila_reg_s = "0010") then -- tercera fila
						btn7 <= btn7(6 downto 0)&cols(3);
						btn8 <= btn8(6 downto 0)&cols(2);
						btn9 <= btn9(6 downto 0)&cols(1);
						btnC <= btnC(6 downto 0)&cols(0);
					elsif (fila_reg_s = "0001") then -- cuarta fila
						btnAS <= btnAS(6 downto 0)&cols(3);
						btn0  <= btn0(6 downto 0)&cols(2);
						btnGA <= btnGA(6 downto 0)&cols(1);
						btnD  <= btnD(6 downto 0)&cols(0);
					end if;
				end if;
			end process;

		-- Bloque que asigna valor al botón apretado
		process(clk)
			begin
				if (rising_edge(clk)) then
					if    (btn0 = "11111111")  then btn_pres <= X"0"; IND_S <= '1';
					elsif (btn1 = "11111111")  then btn_pres <= X"1"; IND_S <= '1';
					elsif (btn2 = "11111111")  then btn_pres <= X"2"; IND_S <= '1';
					elsif (btn3 = "11111111")  then btn_pres <= X"3"; IND_S <= '1';
					elsif (btn4 = "11111111")  then btn_pres <= X"4"; IND_S <= '1';
					elsif (btn5 = "11111111")  then btn_pres <= X"5"; IND_S <= '1';
					elsif (btn6 = "11111111")  then btn_pres <= X"6"; IND_S <= '1';
					elsif (btn7 = "11111111")  then btn_pres <= X"7"; IND_S <= '1';
					elsif (btn8 = "11111111")  then btn_pres <= X"8"; IND_S <= '1';
					elsif (btn9 = "11111111")  then btn_pres <= X"9"; IND_S <= '1';
					elsif (btnA = "11111111")  then btn_pres <= X"A"; IND_S <= '1';
					elsif (btnB = "11111111")  then btn_pres <= X"B"; IND_S <= '1';
					elsif (btnC = "11111111")  then btn_pres <= X"C"; IND_S <= '1';
					elsif (btnD = "11111111")  then btn_pres <= X"D"; IND_S <= '1';
					elsif (btnAS = "11111111") then btn_pres <= X"E"; IND_S <= '1';
					elsif (btnGA = "11111111") then btn_pres <= X"F"; IND_S <= '1';
					else IND_S <= '0';
					end if;
				end if;
			end process;

		-- Bloque para activar la bandera
		process(clk)
			begin
				if (rising_edge(clk)) then
					if (estado = 0) then
						if (IND_S = '1') then	-- si se presionó un botón en el estado 0
							indica <= '1';
							estado <= 1;
						else							-- si no se presionó un botón en el estado 0
							estado <= 0;
							indica <= '0';
						end if;
					else
						if (IND_S = '1') then	-- si se presionó un botón en el estado 1
							estado <= 1;
							indica <= '1';
						else							-- si no se presionó un botón en el estado 1
							estado <= 0;
							indica <= '0';
						end if;
					end if;
				end if;
			end process;
	end rtl;