library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_BIT.all;
use CNetwork.all;
entity TB is
end TB;

architecture TB_ARCH of TB is 

--компонент LSM
component LSM is
	port(F : in BIT; --код операции
     A : in BIT_VECTOR(11 downto 0); --вектор бит - операнд А
	 B : in BIT_VECTOR(11 downto 0); --вектор бит - операнд В
	 C0 : in BIT; --бит переноса
	 Y : out BIT_VECTOR(11 downto 0); --вектор бит - результат
	 CY : out BIT;--бит-признак	переноса результата
	 N : out BIT; --бит-признак отрицательного результата
	 Z : out BIT); --бит-признак нулевого результата
end component;												  

--компонент генератор случайных чисел
component RANDOM_GEN is	
	generic(n:positive:=16; tp:time:=100 ns; SEED:positive:=12345);
	port(CLK:out BIT; Y : out BIT_VECTOR(n-1 downto 0));
end component;

--сигналы стенда
signal F : BIT:= '0';
signal C0 : BIT:='1';
signal A,B : BIT_VECTOR(11 downto 0);
signal Y1,Y2,Y : BIT_VECTOR(11 downto 0);
signal N1, N2, N, CY1, CY2, CY, Z1, Z2, Z, R: bit;

begin
	G1: RANDOM_GEN	--генератор операнда А
		generic map(n => 12, SEED => 1234)
		port map(CLK => open, Y => A);
	G2: RANDOM_GEN	--генератор операнда В
		generic map(n => 12, SEED => 8765)
		port map(CLK => open, Y => B);
	UUT1: entity LSM(LUT) --LSM структурный
		port map(C0 => C0, F => F, A => A, B => B, N => N1, CY => CY1, Z => Z1, Y => Y1);
	UUT2: entity LSM(BEH) --LSM поведенческий
		port map(C0 => C0, F => F, A => A, B => B, N => N2, CY => CY2, Z => Z2, Y => Y2);
end TB_ARCH;
