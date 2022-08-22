use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- ������������
 WR:in BIT; -- �����  
 --����� D ��� ���������� � FM
 --����� Q ��� ������ � FM
 AQ:in BIT_VECTOR(3 downto 0);-- ����� ��� ������ Q
 AD:in BIT_VECTOR(3 downto 0);-- ����� ��� ������ D
 Q: in BIT_VECTOR (15 downto 0);-- ���� ����� ������ Q
 D: out BIT_VECTOR(15 downto 0));-- ���� ����� ������ D
end FM;	  

architecture BEH of FM is
type MEM16X16 is array(0 to 15) of BIT_VECTOR(15 downto 0);
signal do: BIT_VECTOR(15 downto 0);	
signal addr: BIT_VECTOR(3 downto 0);
begin					
---- ���� ��ò�����ί ���'�Ҳ ----
FM16:process(CLK,AQ,AD)  
variable RAM: MEM16X16;
variable addrd,addrq:NATURAL;
begin
 	addrq:= BIT_TO_INT(AQ);
 	addrd:= BIT_TO_INT(AD); 
 	if CLK='1' and CLK'event then
 		if (WR = '1') then
 			RAM(addrq):= Q; --����� � ���'��� �� ������ Q
 		end if;
 	end if;
 	D<= RAM(addrd); --���������� � ���'�� �� ����� D
end process;
end BEH;