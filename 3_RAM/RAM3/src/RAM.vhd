library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 CLK : in BIT; -- ������������
 R : in BIT; -- �����
 WR: in BIT; -- ������		   
 OE: in BIT; -- ��� ������ ����� �� ������������� ������
 AB : in STD_LOGIC_VECTOR(11 downto 0); --���� ������
 IB : in STD_LOGIC_VECTOR(15 downto 0); --������� ���� ������
 OB : out STD_LOGIC_VECTOR(15 downto 0));--�������� ���� ������
end RAM; 		

architecture BEH of RAM is
type MEM3KX16 is array(0 to 3071) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM3KX16:= -- ��������� ��������� ������
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr: BIT_VECTOR(11 downto 0); 
signal do: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin
-----��������� ������------
CONVERT:addr<= To_bitvector(AB);
-----���� ������------
RAM3K:process(CLK,addr,addri)
variable RAM: MEM3KX16:= RAM_init;
 begin
 addri <= BIT_TO_INT(addr(11 downto 0));  
 if CLK='1' and CLK'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(IB); --������ � ������
	 end if;
	 if R='1' then
	 	do<= X"0000"; --�����
	 else
	 	do<= RAM(addri); --���������� �� ������
	 end if;
 end if;
end process; 

------������������� �������� �����-------
 TRI:OB<= To_stdlogicvector(do) when OE='1'
 else "ZZZZZZZZZZZZZZZZ";
end BEH; 