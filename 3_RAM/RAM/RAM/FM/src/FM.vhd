library ieee;
use ieee.numeric_bit.all;
use CNetwork.all; 

entity FM is
port(
 C:in BIT; -- ������������
 WR:in BIT; -- �����  		 
 CP:in BIT; -- ����� �� ������ � ���-���������
 INC:in BIT; -- ��������� � ���������� ���
 AB:in BIT_VECTOR(4 downto 0);-- ������ ������ B 
 AD:in BIT_VECTOR(4 downto 0);-- ������ ������ D
 AQ:in BIT_VECTOR(4 downto 0);-- ������ ������ Q 
 IQ: in BIT_VECTOR (15 downto 0);-- ���� ����� ������ Q
 OC: out BIT_VECTOR(15 downto 0);-- ���� �������-���������
 OB: out BIT_VECTOR(15 downto 0);-- ���� ����� ������ B
 OD: out BIT_VECTOR(15 downto 0)-- ���� ����� ������ D	
 );
end FM;	  

architecture BEH of FM is
type FM24X16 is array(0 to 23) of BIT_VECTOR(15 downto 0);
constant FM_init: FM24X16:= -- ���������� ���� ���'��
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
begin					
-- ��������� ���'���
FM24:process(C,AB,AD,AQ)  
variable FM: FM24X16:=FM_init;
variable addrb,addrd,addrq:NATURAL;
begin	   
	addrb:= BIT_TO_INT(AB);
	addrd:= BIT_TO_INT(AD);
 	addrq:= BIT_TO_INT(AQ);
 	if C='1' and C'event then
 		if (WR = '1') then
			  if (addrq = 23) and (INC='1') then 
 				FM(addrq):= bit_vector(unsigned(IQ)+1); --�������� � ����� �� ������ Q
 			  elsif (addrq /= 23) and (INC='1') then
				FM(23):= bit_vector(unsigned(FM(23))+1);
				FM(addrq):= IQ; -- �������� ��� � ������ Q � FM
			  else
				FM(addrq):= IQ;
			  end if;
	    end if;
 	end if;	   
	OB<= FM(addrb); --������� � FM �� ����� B
 	OD<= FM(addrd); --������� � FM �� ����� D
	if CP='1' then 
		OC<=FM(23); 
	end if;
end process;
end BEH;