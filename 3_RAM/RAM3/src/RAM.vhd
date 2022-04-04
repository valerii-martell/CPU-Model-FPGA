library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 CLK : in BIT; -- синхросигнал
 R : in BIT; -- сброс
 WR: in BIT; -- запись		   
 OE: in BIT; -- бит выдачи слова на тристабильном буфере
 AB : in STD_LOGIC_VECTOR(11 downto 0); --шина адреса
 IB : in STD_LOGIC_VECTOR(15 downto 0); --входная шина данных
 OB : out STD_LOGIC_VECTOR(15 downto 0));--выходная шина данных
end RAM; 		

architecture BEH of RAM is
type MEM3KX16 is array(0 to 3071) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM3KX16:= -- начальное состояние памяти
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr: BIT_VECTOR(11 downto 0); 
signal do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin
-----КОНВЕРТЕР АДРЕСА------
CONVERT:addr<= To_bitvector(AB);
-----БЛОК ПАМЯТИ------
RAM3K:process(CLK,addr,addri)
variable RAM: MEM3KX16:= RAM_init;
 begin
 addri <= BIT_TO_INT(addr(11 downto 0));  
 if CLK='1' and CLK'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(IB); --запись в память
	 end if;
	 if R='1' then
	 	do<= X"0000"; --сброс
	 else
	 	do<= RAM(addri); --считывание из памяти
	 end if;
 end if;
end process; 

------ТРИСТАБИЛЬНЫЙ ВЫХОДНОЙ БУФЕР-------
 TRI:OB<= To_stdlogicvector(do) when OE='1'
 else "ZZZZZZZZZZZZZZZZ";
end BEH; 