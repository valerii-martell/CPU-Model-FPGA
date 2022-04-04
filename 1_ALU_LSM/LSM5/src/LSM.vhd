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
	
function MAX(a,b:signed)return signed is
begin			  
	if a > b then
		return a;
	else
		return b;
	end if;  
end function ;

begin
	--представлення операндів в знаковому форматі
	Ai <= RESIZE(SIGNED(A),13);
	Bi <= RESIZE(SIGNED(B),13);
	--врахуємо біт переносу в другий операнд 
    Ci <= Bi when C0='0' else Bi+1;
	--операція
	Ybi <= BIT_VECTOR(Ai+Ci) when F='0' else BIT_VECTOR(MAX(Ai,Bi));
	--біти ознак
	CY <= Ybi(12);
	N <= Ybi(11);
	Z <= '1' when Ybi(11 downto 0) = X"000" else '0';
	--запис результату
	Y <= Ybi(11 downto 0);
end BEH;

----------СТРУКТУРНА МОДЕЛЬ----------
architecture STR of LSM is
signal C, X, Yi: BIT_VECTOR(12 downto 0);
signal M: BIT_VECTOR(11 downto 0);
signal Zi: BIT_VECTOR(2 downto 0);
component LUT4 is
	generic(mask:BIT_VECTOR(15 downto 0):=X"FFFF"; td:TIME:=1 ns);
	port(a, b, c, d: in BIT; Y : out BIT);
end component;
begin
--врахуємо перенос з молодших розрядів в вектор переносів
C(0) <= C0;

LSM_LUT:for i in 0 to 11 generate
	LNI:LUT4 generic map (mask=>X"0096") --незалежно від F побітово вииконуємо додавання/віднімання (співпадає) (96),  
		port map(a => A(i), b => B(i), c => C(i), d => '0', Y => Yi(i)); 
	LNC:LUT4 generic map (mask=>X"D4E8") --побітово вираховуємо чи відбувалося на попередньому кроці переповнення результату
		port map(a => A(i), b => B(i), c => C(i), d => F, Y => C(i + 1)); --і формуємо вектор переносів
end generate; 

--формуємо вектор перевірки четвірок бітів на 0
UZ1:LUT4 generic map(mask=>X"0001")
 port map(a=>Yi(3),b=>Yi(2),c=>Yi(1),d =>Yi(0), Y =>Zi(0));
UZ2:LUT4 generic map(mask=>X"0001")
 port map(a=>Yi(7),b=>Yi(6),c=>Yi(5),d =>Yi(4), Y =>Zi(1));
UZ3:LUT4 generic map(mask=>X"0001")
 port map(a=>Yi(11),b=>Yi(10),c=>Yi(9),d=>Yi(8), Y =>Zi(2));
--на основі отриманого вектору видаємо ознаку нульового результату
UZ4:LUT4 generic map(mask=>X"0080")
 port map(a=>Zi(0),b=>Zi(1),c=>Zi(2),d =>'0', Y =>Z); 

	M <= A(11 downto 0) when Yi(11)='0' else B(11 downto 0); --оцінка максимуму за знаком різниці
	Y <= Yi(11 downto 0) when F='0' else M(11 downto 0); --переписуємо результат на вихід схеми
	N <= Yi(11) when F='0' else M(11);  --знак
	CY <= C(12) when F='0' else '0';  --переповнення результату
end STR;
