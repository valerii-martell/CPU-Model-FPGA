use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- синхросигнал
 WR:in BIT; -- запись   
 --канал D дл€ считывани€ из FM
 --канал Q дл€ записи в FM
 AQ:in BIT_VECTOR(2 downto 0);-- адрес дл€ канала Q
 AD:in BIT_VECTOR(2 downto 0);-- адрес дл€ канала D
 Q: in BIT_VECTOR (15 downto 0);-- шина даных канала Q
 D: out BIT_VECTOR(15 downto 0));-- шина даных канала D
end FM;	  

architecture BEH of FM is
type MEM8X16 is array(0 to 7) of BIT_VECTOR(15 downto 0);
signal do: BIT_VECTOR(15 downto 0);	
signal addr: BIT_VECTOR(2 downto 0);
begin					
---- ЅЋќ  –≈√»—“–ќ¬ќ… ѕјћя“» ----
FM8:process(CLK,AQ,AD)  
variable RAM: MEM8X16;
variable addrd,addrq:NATURAL;
begin
 	addrq:= BIT_TO_INT(AQ);
 	addrd:= BIT_TO_INT(AD); 
 	if CLK='1' and CLK'event then
 		if (WR = '1') then
 			RAM(addrq):= Q; --запись в пам€ть из канала Q
 		end if;
 	end if;
 	D<= RAM(addrd); --считывание из пам€ти на канал D
end process;
end BEH;