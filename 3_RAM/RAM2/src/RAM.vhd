library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 C : in BIT; -- синхросигнал
 R : in BIT; -- скидання
 WR: in BIT; -- запис
 AE: in BIT; -- запис адреси в регістр адреси
 OE: in BIT; -- видача слова на тристабільному буфері
 AD : inout STD_LOGIC_VECTOR(15 downto 0));-- адреса/дані
end RAM; 		

architecture BEH of RAM is
type MEM1KX16 is array(0 to 1023) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM1KX16:= -- початковий стан пам'яті
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr,do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin		
	
--------РЕГІСТР АДРЕСИ--------
RG_ADDR:process(C,R) begin
 if R='1' then --асинхронне скидання
 	addr<=X"0000";
 elsif C='1' and C'event and AE='1' then 
 	addr<= To_bitvector(AD); --запис адреси до регістру
 end if;
end process; 

---------БЛОК ПАМ'ЯТІ---------
RAM1K:process(C,addr)
variable RAM: MEM1KX16:= RAM_init; 
--variable addri: INTEGER;
begin 
	
 addri <= BIT_TO_INT(addr(9 downto 0)); --приведення адреси до int  
 if C='1' and C'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(AD); --запис в пам'ять
	 end if;
	 if R='1' then
	 	do<= X"0000"; --синхронне скидання
	 else
	 	do<= RAM(addri); --зчитування з пам'яті
	 end if;
 end if;
end process; 									

--------ТРИСТАБІЛЬНИЙ ВИХІДНИЙ БУФЕР---------- 
 TRI:AD<= To_StdLogicVector(do) when OE='1'
 else "ZZZZZZZZZZZZZZZZ";
end BEH; 