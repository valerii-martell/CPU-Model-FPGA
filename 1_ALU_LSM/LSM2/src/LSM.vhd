library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_BIT.all; 	

----------КОМПОНЕНТ----------
entity LSM is
port(F : in BIT; --код операції
     A : in BIT_VECTOR(11 downto 0); --перший операнд
	 B : in BIT_VECTOR(11 downto 0); --другий операнд
	 C0 : in BIT; --біт переносу
	 N : out BIT; --ознака від'ємного результату
	 CY : out BIT;--ознака переносу	результату
	 Z : out BIT; --ознака нульового результату
	 Y : out BIT_VECTOR(11 downto 0)); --результат
end LSM;

----------ПОВЕДІНКОВА МОДЕЛЬ----------
architecture BEH of LSM is
	signal Ai,Bi,Ci : SIGNED(12 downto 0); 
	signal Ybi : BIT_VECTOR(12 downto 0);
begin
	--представлення операндів в знаковому форматі
	Ai <= RESIZE(SIGNED(A),13);
	Bi <= RESIZE(SIGNED(B),13);
	--врахуємо біт переносу в другий операнд 
    Ci <= Bi when C0='0' else Bi+1;
	--операція
	Ybi <= BIT_VECTOR(Ai+Ci) when F='0' else '0'&((not A) or B);
	--біти ознак
	CY <= Ybi(12);
	N <= Ybi(11);
	Z <= '1' when Ybi(11 downto 0) = X"000" else '0';
	--запис результату
	Y <= Ybi(11 downto 0);
end BEH;

----------СТРУКТУРНА МОДЕЛЬ----------
architecture LUT of LSM is
signal C, X, Zi, Yi: BIT_VECTOR(12 downto 0);
component LUT4 is
	generic(mask:BIT_VECTOR(15 downto 0):=X"FFFF"; td:TIME:=1 ns);
	port(a, b, c, d: in BIT; Y : out BIT);
end component;
begin
--врахуємо перенос з молодших розрядів в вектор переносів
C(0) <= C0;
--перший біт вектора-ознаки нульового результату
Zi(0) <= '0';

LSM_LUT:for i in 0 to 11 generate
	LNI:LUT4 generic map (mask=>X"DD96") --якщо F=0 то побітово вииконуємо додавання (96),  
		port map(a => A(i), b => B(i), c => C(i), d => F, Y => Yi(i)); --інакше, якщо F=1, виконуємо побітово логічну операцію
	LNC:LUT4 generic map (mask=>X"00E8") --побітово вираховуємо чи відбувалося на попередньому кроці переповнення результату
		port map(a => A(i), b => B(i), c => C(i), d => F, Y => C(i + 1)); --і формуємо вектор переносів
	UZ:lut4 generic map (mask => X"8000")--побітово порівнюємо поточний біт результату з вектором-ознакою нульового результату
		port map(a => Yi(i), b => Zi(i), c => '0', d => '0', Y => Zi(i + 1)); --і формуємо наступний біт цього вектору  (8000 - AND)
	end generate;
	Y <= Yi(11 downto 0); --переписуємо результат на вихід схеми
	N <= Yi(11);  --знак
	CY <= C(12);  --переповнення результату
	Z <= Zi(12);  --ознака нульового результату
end LUT;
