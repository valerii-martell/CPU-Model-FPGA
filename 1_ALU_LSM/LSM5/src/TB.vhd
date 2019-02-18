library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_BIT.all;
use CNetwork.all;
entity TB is
end TB;

architecture TB_ARCH of TB is
-------LSM-------
component LSM is
	port(	F : in BIT; --êîä îïåðàö³¿
     		A : in BIT_VECTOR(11 downto 0); --ïåðøèé îïåðàíä
			B : in BIT_VECTOR(11 downto 0); --äðóãèé îïåðàíä
			C0 : in BIT; --á³ò ïåðåíîñó
			N : out BIT; --îçíàêà â³ä'ºìíîãî ðåçóëüòàòó
			CY : out BIT;--îçíàêà ïåðåíîñó	ðåçóëüòàòó
			Z : out BIT; --îçíàêà íóëüîâîãî ðåçóëüòàòó
			Y : out BIT_VECTOR(11 downto 0)); --ðåçóëüòàò
end component;												  

------ÃÅÍÅÐÀÒÎÐ ÂÈÏÀÄÊÎÂÈÕ ×ÈÑÅË Ç ÍÎÐÌÀËÜÍÈÌ ÐÎÇÏÎÄ²ËÎÌ------
component RANDOM_GEN is
	generic(n:positive:=16; tp:time:=100 ns; SEED:positive:=12345);
	port(CLK:out BIT; Y : out BIT_VECTOR(n-1 downto 0));
end component;

-----ÑÈÃÍÀËÈ ÑÒÅÍÄÓ------
signal F : BIT:= '0';
signal C0 : BIT:='1';
signal A,B : BIT_VECTOR(11 downto 0);
signal Y1,Y2,Y : BIT_VECTOR(11 downto 0);
signal N1, N2, N, CY1, CY2, CY, CY3, Z1, Z2, Z, R: bit;

begin
	G1: RANDOM_GEN
		generic map(n => 12, SEED => 1234)
		port map(CLK => open, Y => A);
	G2: RANDOM_GEN
		generic map(n => 12, SEED => 8765)
		port map(CLK => open, Y => B);
	UUT1: entity LSM(STR)
		port map(C0 => C0, F => F, A => A, B => B, N => N1, CY => CY3, Z => Z1, Y => Y1);
	UUT2: entity LSM(BEH)
		port map(C0 => C0, F => F, A => A, B => B, N => N2, CY => CY2, Z => Z2, Y => Y2);
		CY1<=CY2;
end TB_ARCH;
