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
 OE: in BIT; -- видача слова на тристабільному буфері
 AD: in STD_LOGIC_VECTOR(11 downto 0);-- адреса
 ID: in STD_LOGIC_VECTOR(15 downto 0);-- вхідна шина даних
 OD: out STD_LOGIC_VECTOR(15 downto 0));-- вихідна шина даних
end RAM; 		

architecture BEH of RAM is
type MEM4KX16 is array(0 to 4095) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM4KX16:= -- початковий стан пам'яті
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin		 
ADDR:addri <= BIT_TO_INT(To_bitvector(AD(11 downto 0))); --приведення адреси до int 

---------БЛОК ПАМ'ЯТІ---------
RAM4K:process(C,addri)
variable RAM: MEM4KX16:= RAM_init; 
begin 	
 if C='1' and C'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(ID(15 downto 0)); --запис в пам'ять
	 end if;
	 if R='1' then
	 	do<= X"0000"; --синхронне скидання
	 else
	 	do<= RAM(addri); --зчитування з пам'яті
	 end if;
 end if;
end process; 									

--------ТРИСТАБІЛЬНИЙ ВИХІДНИЙ БУФЕР---------- 
 TRI:OD<= To_StdLogicVector(do) when OE='1'
 else "ZZZZZZZZZZZZZZZZ";
end BEH; 