library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 Ñ : in BIT; -- synchro
 R : in BIT; -- reset
 WR: in BIT; -- write		   
 OE: in BIT; -- get read word
 AD : in BIT_VECTOR(15 downto 0); -- address
 IO : inout BIT_VECTOR(15 downto 0));-- data
end RAM; 		

architecture BEH of RAM is
type MEM5KX16 is array(0 to 5119) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM5KX16:= -- initial memory status
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr,do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin
CONVERT:addr<= To_bitvector(AD);
 ------ Memory block ------------------
RAM5K:process(Ñ,addr,addri)
variable RAM: MEM5KX16:= RAM_init; 
--variable addri: INTEGER;
 begin
 addri <= BIT_TO_INT(addr(15 downto 0));  
 if Ñ='1' and Ñ'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(IO); --write 
	 end if;
	 if R='1' then
	 	do<= X"0000"; --reset
	 else
	 	do<= RAM(addri); --read
	 end if;
 end if;
end process; 

 -- Tristate output buffer --------------------- 
 TRI:IO<= "ZZZZZZZZZZZZZZZZ" when To_StdLogicVector(do)=1 else '0';
end BEH; 