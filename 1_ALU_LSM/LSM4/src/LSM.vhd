library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_BIT.all; 	

entity LSM is --объявление компонента
port(F : in BIT; --код операции
     A : in BIT_VECTOR(11 downto 0); --вектор бит - операнд А
	 B : in BIT_VECTOR(11 downto 0); --вектор бит - операнд В
	 C0 : in BIT; --бит переноса
	 Y : out BIT_VECTOR(11 downto 0); --вектор бит - результат
	 CY : out BIT;--бит-признак	переноса результата
	 N : out BIT; --бит-признак отрицательного результата
	 Z : out BIT); --бит-признак нулевого результата
end LSM;

architecture BEH of LSM is --поведенческая архитектура
	signal Ai,Bi,Ci : SIGNED(12 downto 0); 
	signal Ybi : BIT_VECTOR(12 downto 0);
begin
	--расширение операндов к знаковому типу
	Ai <= RESIZE(SIGNED(A),13);
	Bi <= RESIZE(SIGNED(B),13);
	--сложение бита переноса со вторым операндом 
    Ci <= Bi when C0='0' else Bi+1;
	--вычитание/логическая операция в зависимости от управляющего бита
	Ybi <= BIT_VECTOR(Ai-Ci) when F='0' else '0'&(A xnor B);
	--биты-признаки
	CY <= Ybi(12);
	N <= Ybi(11);
	Z <= '1' when Ybi(11 downto 0) = X"000" else '0';
	--представление результата в виде вектора бит
	Y <= Ybi(11 downto 0);
end BEH;

architecture LUT of LSM is --архитектура на LUT-элементах
signal C, X, Zi, Yi: BIT_VECTOR(12 downto 0);
component LUT4 is --LUT-компонент на 4 входа
	generic(mask:BIT_VECTOR(15 downto 0):=X"FFFF"; td:TIME:=1 ns);
	port(a, b, c, d: in BIT; Y : out BIT);
end component;
begin
C(0) <= C0;	--перенос из младших разрядов считаем первым переносом вычитания 
Zi(0) <= '0'; --предположим что результат будет положительный

LSM_LUT:for i in 0 to 11 generate
	LNI:LUT4 generic map (mask=>X"9996")
		port map(a => A(i), b => B(i), c => C(i), d => F, Y => Yi(i));
	LNC:LUT4 generic map (mask=>X"00D4")
		port map(a => A(i), b => B(i), c => C(i), d => F, Y => C(i + 1));
	UZ:lut4 generic map (mask => X"8000")
		port map(a => Yi(i), b => Zi(i), c => '0', d => '0', Y => Zi(i + 1));
	end generate;
	Y <= Yi(11 downto 0);--результат
	N <= Yi(11); --знак результата
	CY <= C(12); --перенос результата
	Z <= Zi(12); --признак нулевого результата
end LUT;
