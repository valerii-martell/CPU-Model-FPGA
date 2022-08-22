use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- ������������
 WR:in BIT; -- �����  
 --����� B ��� ���������� � FM
 --����� D ��� ���������� � FM
 --����� Q ��� ������ � FM
 AQ:in BIT_VECTOR(5 downto 0);-- ����� ��� ������ Q
 AD:in BIT_VECTOR(5 downto 0);-- ����� ��� ������ D
 AB:in BIT_VECTOR(5 downto 0);-- ����� ��� ������ B
 Q: in BIT_VECTOR (15 downto 0);-- ���� ����� ������ Q
 D: out BIT_VECTOR(15 downto 0);-- ���� ����� ������ D	
 B: out BIT_VECTOR(15 downto 0));-- ���� ����� ������ B
end FM;	  

architecture BEH of FM is
type FM48X16 is array(0 to 47) of BIT_VECTOR(15 downto 0);
constant FM_init: FM48X16:= -- ���������� ���� ���'��
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
begin					
---- ���� ��ò�����ί ���'�Ҳ ----
FM48:process(CLK,AQ,AD,AB)  
variable FM: FM48X16:=FM_init;
variable addrd,addrq,addrb:NATURAL;
begin
 	addrq:= BIT_TO_INT(AQ);
 	addrd:= BIT_TO_INT(AD);
	addrb:= BIT_TO_INT(AB);
 	if CLK='1' and CLK'event then
 		if (WR = '1') and (addrq /= 0) then
 			FM(addrq):= Q; --����� � ���'��� �� ������ Q
 		end if;
 	end if;
 	D<= FM(addrd); --���������� � ���'�� �� ����� D
	B<= FM(addrb); --���������� � ���'�� �� ����� B
end process;
end BEH;