use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- синхросигнал
 WR:in BIT; -- запис  
 --канал B для зчитування з FM
 --канал D для зчитування з FM
 --канал Q для запису в FM
 AQ:in BIT_VECTOR(5 downto 0);-- адрес для канала Q
 AD:in BIT_VECTOR(5 downto 0);-- адрес для канала D
 AB:in BIT_VECTOR(5 downto 0);-- адрес для канала B
 Q: in BIT_VECTOR (15 downto 0);-- шина даных канала Q
 D: out BIT_VECTOR(15 downto 0);-- шина даных канала D	
 B: out BIT_VECTOR(15 downto 0));-- шина даных канала B
end FM;	  

architecture BEH of FM is
type FM48X16 is array(0 to 47) of BIT_VECTOR(15 downto 0);
constant FM_init: FM48X16:= -- початковий стан пам'яті
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
begin					
---- БЛОК РЕГІСТРОВОЇ ПАМ'ЯТІ ----
FM48:process(CLK,AQ,AD,AB)  
variable FM: FM48X16:=FM_init;
variable addrd,addrq,addrb:NATURAL;
begin
 	addrq:= BIT_TO_INT(AQ);
 	addrd:= BIT_TO_INT(AD);
	addrb:= BIT_TO_INT(AB);
 	if CLK='1' and CLK'event then
 		if (WR = '1') and (addrq /= 0) then
 			FM(addrq):= Q; --запис в пам'ять із каналу Q
 		end if;
 	end if;
 	D<= FM(addrd); --зчитування з пам'яті на канал D
	B<= FM(addrb); --зчитування з пам'яті на канал B
end process;
end BEH;