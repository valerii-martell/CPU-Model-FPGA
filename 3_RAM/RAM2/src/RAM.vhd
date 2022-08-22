library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 C : in BIT; -- ������������
 R : in BIT; -- ��������
 WR: in BIT; -- �����
 AE: in BIT; -- ����� ������ � ������ ������
 OE: in BIT; -- ������ ����� �� ������������� �����
 AD : inout STD_LOGIC_VECTOR(15 downto 0));-- ������/���
end RAM; 		

architecture BEH of RAM is
type MEM1KX16 is array(0 to 1023) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM1KX16:= -- ���������� ���� ���'��
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr,do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin		
	
--------��ò��� ������--------
RG_ADDR:process(C,R) begin
 if R='1' then --���������� ��������
 	addr<=X"0000";
 elsif C='1' and C'event and AE='1' then 
 	addr<= To_bitvector(AD); --����� ������ �� �������
 end if;
end process; 

---------���� ���'�Ҳ---------
RAM1K:process(C,addr)
variable RAM: MEM1KX16:= RAM_init; 
--variable addri: INTEGER;
begin 
	
 addri <= BIT_TO_INT(addr(9 downto 0)); --���������� ������ �� int  
 if C='1' and C'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(AD); --����� � ���'���
	 end if;
	 if R='1' then
	 	do<= X"0000"; --��������� ��������
	 else
	 	do<= RAM(addri); --���������� � ���'��
	 end if;
 end if;
end process; 									

--------������������� ��ղ���� �����---------- 
 TRI:AD<= To_StdLogicVector(do) when OE='1'
 else "ZZZZZZZZZZZZZZZZ";
end BEH; 