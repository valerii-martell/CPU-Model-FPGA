library ieee;
use ieee.numeric_bit.all;
use CNetwork.all; 

entity FM is
port(
 C:in BIT; -- синхросигнал
 WR:in BIT; -- запис  		 
 CP:in BIT; -- дозвіл на видачу з рег-лічильника
 INC:in BIT; -- інкремент в останньому рег
 AB:in BIT_VECTOR(4 downto 0);-- адреса каналу B 
 AD:in BIT_VECTOR(4 downto 0);-- адреса каналу D
 AQ:in BIT_VECTOR(4 downto 0);-- адреса каналу Q 
 IQ: in BIT_VECTOR (15 downto 0);-- шина даных каналу Q
 OC: out BIT_VECTOR(15 downto 0);-- шина регістру-лічильника
 OB: out BIT_VECTOR(15 downto 0);-- шина даных каналу B
 OD: out BIT_VECTOR(15 downto 0)-- шина даных каналу D	
 );
end FM;	  

architecture BEH of FM is
type FM24X16 is array(0 to 23) of BIT_VECTOR(15 downto 0);
constant FM_init: FM24X16:= -- початковий стан пам'яті
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
begin					
-- Регістрова пам'ять
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
 				FM(addrq):= bit_vector(unsigned(IQ)+1); --інкремнт і запис із каналу Q
 			  elsif (addrq /= 23) and (INC='1') then
				FM(23):= bit_vector(unsigned(FM(23))+1);
				FM(addrq):= IQ; -- записати дані з каналу Q в FM
			  else
				FM(addrq):= IQ;
			  end if;
	    end if;
 	end if;	   
	OB<= FM(addrb); --зчитати з FM на канал B
 	OD<= FM(addrd); --зчитати з FM на канал D
	if CP='1' then 
		OC<=FM(23); 
	end if;
end process;
end BEH;