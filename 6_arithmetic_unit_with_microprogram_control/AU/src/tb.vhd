Library IEEE;
use IEEE.NUMERIC_BIT.all;

entity au_tb is
end au_tb;								 

architecture TB_ARCHITECTURE of au_tb is

component AU is port(
 C : in BIT; --sycnhro
 RST : in BIT; --reset
 START : in BIT; --start operation in AU
 RD: in BIT; -- read from FM to DO bus
 WRD : in BIT; -- write from DI bus
 RET : in BIT; -- return from subprogram
 CALL: in BIT; -- start subprogram
 DI : in BIT_VECTOR(15 downto 0); --in data bus
 AB : in BIT_VECTOR(5 downto 0); -- register B address
 AD : in BIT_VECTOR(5 downto 0); -- register D address
 AQ : in BIT_VECTOR(5 downto 0); -- register Q address
 ARET : in BIT_VECTOR(12 downto 0); --in return address
 ACOP : in BIT_VECTOR(2 downto 0); -- AU operation code
 RDY : out BIT; --result ready
 ARETO : out BIT_VECTOR(12 downto 0);--out return address
 DO : out BIT_VECTOR(15 downto 0); --out data bus
 BO : out BIT_VECTOR(15 downto 0); --out data bus D
 CNZ: out BIT_VECTOR(2 downto 0)); --out state reg
end component ;

signal c,rst,rdy,start,wrd,rd,ret,call:BIT; 
signal acop,cnz:BIT_VECTOR(2 downto 0);
signal aq,ad,ab:BIT_VECTOR(5 downto 0);
signal di,do,bo:BIT_VECTOR(15 downto 0);
signal aret,areto:BIT_VECTOR(12 downto 0); 


signal maddr:natural;
type MICROINST is record -- ?????? ????????????
 ACOP:bit_vector(2 downto 0); -- ??? ???????? AU
 AQ,AD,AB:bit_vector(5 downto 0); -- ?????? FM
 DI:BIT_VECTOR(15 downto 0); -- ??????? ??????
 START,WRD,RD:bit; -- ???? ??????????
end record;
constant n: positive:=13; --????? ???????????
type MICROPROGR is array(0 to n-1) of MICROINST;
----------microprogram----------
constant mp:MICROPROGR:=( 
 
 ("100","000001","000000","000000",X"0000",'0','1','0'), --NOT 0000h, result = FFFFh in 000001
 ("101","000010","000001","000000",X"0000",'0','1','0'), --ABS FFFFh, result = 7FFFh in 000010
 ("110","000011","000010","000000",X"0000",'0','1','0'), --LSR 7FFFh, result = 3FFFh in 000011
 ("110","000011","000011","000000",X"0000",'0','1','0'), --LSR 3FFFh, result = 1FFFh in 000011	 
 ("001","000100","000011","000001",X"0000",'1','0','0'), --AND 1FFFh, 7FFFh, result = 1FFFh in 000100  
 ("011","000101","000010","000100",X"0000",'1','0','0'), --SUB 7FFFh, 1FFFh, result = 6000h in 000101
 ("110","000110","000101","000000",X"0000",'0','1','0'), --LSR 6000h, result = 3000h in 000110
 ("111","001000","000001","000110",X"0000",'1','0','0'), --MUL FFFFh, 3000h, result = 97FFh in 001000 and D000h in 001001
 ("000","000111","000110","000101",X"0000",'1','0','0'), --ADD 3000h, 6000h, result = 9000h in 000111
 ("111","001010","000010","000110",X"0000",'1','0','0'), --MUL 7FFFh, 3000h, result = 17FFh in 001010 and D000h in 001011
 ("000","001110","001000","001010",X"0000",'1','0','0'), --ADD 97FFh, 17FFh, result = 0000h in 001110
 ("011","001111","001011","001001",X"0000",'1','0','0'), --SUB D000h, D000h, result = 0000h in 001111
 ("001","000000","001111","001110",X"0000",'1','0','0')  --AND 0000h, 0000h, result = 0000h in out bus
 );
	
 begin 
	
 SYNCRO_GEN: C<=not C after 5 ns; -- ????????? ?????????????
 RESET_GEN: RST<='1' ,'0' after 25 ns; -- ????????? c?????? ??????
 
CTM:process(C,RST) 
begin -- ??????? ???????????
 if RST='1' then
 maddr<=0;
 elsif C='1' and C'event then
 if (RDY='1' and START='1') or WRD='1'or RD='1' then
 maddr<=(maddr+1) mod n; -- +1 ? ????????
 end if;
 end if;
end process;

ROM_U:(ACOP,AQ,AD,AB,DI,START,WRD,RD)<=mp(maddr);
AU_U : AU port map (C,RST, --??????????? ?U
 START => START,
 RD => RD, WRD => WRD,
 RET => RET, CALL => CALL,
 DI => DI,
 AB => AB, AD => AD, AQ => AQ,
 ARET => ARET, ACOP => ACOP,
 RDY => RDY, ARETO => ARETO,
 DO => DO, BO=>BO, CNZ => CNZ);
end TB_ARCHITECTURE;