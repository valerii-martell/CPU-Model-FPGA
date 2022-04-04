use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- синхросигнал
 WR:in BIT; -- запис  
 --канал D для зчитування з FM
 --канал Q для запису в FM
 AQ:in BIT_VECTOR(3 downto 0);-- адрес для канала Q
 AD:in BIT_VECTOR(3 downto 0);-- адрес для канала D
 Q: in BIT_VECTOR (15 downto 0);-- шина даных канала Q
 D: out BIT_VECTOR(15 downto 0));-- шина даных канала D
end FM;	  

architecture BEH of FM is
type MEM16X16 is array(0 to 15) of BIT_VECTOR(15 downto 0);
signal do: BIT_VECTOR(15 downto 0);	
signal addr: BIT_VECTOR(3 downto 0);
begin					
---- БЛОК РЕГІСТРОВОЇ ПАМ'ЯТІ ----
FM16:process(CLK,AQ,AD)  
variable RAM: MEM16X16;
variable addrd,addrq:NATURAL;
begin
 	addrq:= BIT_TO_INT(AQ);
 	addrd:= BIT_TO_INT(AD); 
 	if CLK='1' and CLK'event then
 		if (WR = '1') then
 			RAM(addrq):= Q; --запис в пам'ять із каналу Q
 		end if;
 	end if;
 	D<= RAM(addrd); --зчитування з пам'яті на канал D
end process;
end BEH;