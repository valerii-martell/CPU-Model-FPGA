Library IEEE;
use IEEE.NUMERIC_BIT.all;

entity FM is port(C: in BIT; -- synchro
 WR: in BIT; -- write
 INCQ: in BIT;-- inc Q address
 CALL: in BIT;-- write return address and CNZ
 AB: in BIT_VECTOR(5 downto 0);-- address B
 AD: in BIT_VECTOR(5 downto 0);-- address D
 AQ: in BIT_VECTOR(5 downto 0);-- address Q
 ARETC: in BIT_VECTOR (15 downto 0);--in address CNZ 
 Q: in BIT_VECTOR (15 downto 0);-- data Q
 B: out BIT_VECTOR(15 downto 0);-- data B
 D: out BIT_VECTOR(15 downto 0);-- data D
 ARETCO: out BIT_VECTOR (15 downto 0));--out address CNZ
end FM;	

architecture BEH of FM is
type MEM64X16 is array(0 to 63) of BIT_VECTOR(15 downto 0);
constant FM_init: MEM64X16:= -- initial memory status
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal RAM: MEM64x16:=FM_init;
begin
 FM16:process(C,AD,AB)
 variable addrq,addrd,addrb:natural;
begin
 addrq:=TO_INTEGER(UNSIGNED(AQ));
 if INCQ='1' then
 	addrq:=addrq+1;
 end if;
 
 addrd:=TO_INTEGER(UNSIGNED(AD));
 addrb:=TO_INTEGER(UNSIGNED(AB));
 
 if C='1' and C'event then
 	if WR = '1' and (addrq /= 0) then
 		RAM(addrq)<= Q; 
 	end if;
 	if CALL = '1' then
 		RAM(63)<= ARETC; 
 	end if;
 end if; 
 
 B<= RAM(addrb);
 D<= RAM(addrd);
 ARETCO<= RAM(63);
 
end process;
end BEH; 