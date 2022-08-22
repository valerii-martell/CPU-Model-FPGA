use CNetwork.all;
library ieee;
use ieee.numeric_bit.all;  

entity ICTR is
port(
 CLK : in BIT; --������������ 
 R : in BIT; --�����
 WR: in BIT; --������
 D : in BIT_VECTOR(10 downto 0); --����� �������� (��������) 
 F : in BIT_VECTOR(2 downto 0);  --����������� �����
 A : out BIT_VECTOR(15 downto 0)); --����� ����� (���������)
end ICTR; 

architecture BEH of ICTR is
signal RG: BIT_VECTOR(2 downto 0);
signal SM: BIT_VECTOR(3 downto 0);
signal CTR:BIT_VECTOR(15 downto 3);
signal CTRi:SIGNED(16 downto 0);
begin
	
---------��������-----------
SUM:SM <= INT_TO_BIT((BIT_TO_INT(RG) + 4),4) when F="011" else --+4
		  INT_TO_BIT((BIT_TO_INT(RG) + 8),4) when F="100" else --+8
		  INT_TO_BIT((BIT_TO_INT(RG) + BIT_TO_INT(F)),4);

---------������� ��. ����� ������-----------
 R_3:process(R,CLK)
begin
 --����������� �����
 if R='1' then 
 	RG<="000";
 --����������� �� ������ �����������
 elsif CLK='1' and CLK'event then 
 case F is 
	--������ 3 ��. ����� �� ��������� 
	when "001"|"010"|"011"|"100"=>RG<=SM(2 downto 0);
	--���������� �����
 	when "101" => RG<="000";
	--������ ����� ������� �������� ������ �������� (��������)
 	when "110" | "111" => RG<=D(2 downto 0); 
 	when others=> null;
 end case;
 end if;
end process;

--------�������-������� ��. ����� ������--------
 CT:process(CLK,R)
begin 
 --����������� �����
 if R='1' then
	--��������� ��������� ��������(28*32=896=0011 1000 0000)
 	CTRi<="00000001110000000";
 --����������� �� ������ �����������	 
 elsif CLK='1' and CLK'event then 
 	--���������� �����
	if F="101" then	
		--��������� ���������
 		CTRi<="00000001110000000"; 
	elsif F="110" then 
		--������ ������ ��������
 		CTRi(15 downto 3)<= "00000"&SIGNED(D(10 downto 3)); 
	elsif F="111" then
		--"�������" � ������� ��������� �������� ���������� �� ����� ������������ ����������,
		--������ �� ������� ����� ��� ��������� �����
 		CTRi(15 downto 3)<= CTRi(12 downto 0);
	elsif (F(2) = '0' or F="100") and SM(3) ='1' then 
		--���������
 		CTRi<= CTRi+1;
	end if;
 end if; 
end process;

 CTR<= BIT_VECTOR(CTRi(15 downto 3));
 A<=CTR&RG; --"�������" ����������� ��������-�������� � �������� ���������
end BEH;