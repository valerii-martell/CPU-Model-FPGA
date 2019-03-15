library ieee;
use ieee.numeric_bit.all;
use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- synchro
 WR:in BIT; -- write 
 INC:in BIT; --last reg inc
 GETCTR:in BIT; --get value in ctr bus
 AB:in BIT_VECTOR(3 downto 0);-- channel B address
 AD:in BIT_VECTOR(3 downto 0);-- channel D address
 AQ:in BIT_VECTOR(3 downto 0);-- channel Q address
 Q: in BIT_VECTOR (15 downto 0);-- channel Q data
 B: out BIT_VECTOR(15 downto 0);-- channel B data
 D: out BIT_VECTOR(15 downto 0);-- channel D data
 CTR: out BIT_VECTOR(15 downto 0)); --special out bus for last register (counter)
end FM;	  

architecture BEH of FM is
type MEM16X16 is array(0 to 15) of BIT_VECTOR(15 downto 0);	
constant FM_init: MEM16X16:= -- initial memory status
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
begin					
---- Block of register memory ---------------
FM16:process(CLK,AD,AB)		   
variable RAM: MEM16x16:=FM_init;
variable addrq,addrd,addrb:NATURAL;
begin
	addrq:= BIT_TO_INT(AQ);
 	addrb:= BIT_TO_INT(AB);
 	addrd:= BIT_TO_INT(AD); 
 	if CLK='1' and CLK'event then
 		if (WR = '1') and (addrq /= 0) then
			 if (addrq = 15) and (INC='1') then 
			 	RAM(addrq):= bit_vector(unsigned(Q)+1); -- inc and write data from Q channel to FM 
			 elsif (addrq /= 15) and (INC='1') then
				RAM(15):= bit_vector(unsigned(RAM(15))+1);
				RAM(addrq):= Q; -- read data from Q channel	to FM
			 else
				RAM(addrq):= Q; -- read data from Q channel	to FM
			 end if;
		elsif (WR = '1') and (addrq = 0) and (INC='1') then
			 RAM(15):= bit_vector(unsigned(RAM(15))+1);
 		end if;
 	end if;
 	B<= RAM(addrb); -- write data from FM to channel B 
	D<= RAM(addrd); -- write data from FM to channel D
	if GETCTR='1' then 
		CTR<=RAM(15); 
	end if;
end process;
end BEH;