use CNetwork.all;
entity FM is
port(
 CLK:in BIT; -- synchro
 WR:in BIT; -- write   
 --B for read from FM
 --D for write to FM
 AB:in BIT_VECTOR(5 downto 0);-- channel B address
 AD:in BIT_VECTOR(5 downto 0);-- channel D address
 B: out BIT_VECTOR (15 downto 0);-- channel B data
 D: in BIT_VECTOR(15 downto 0));-- channel D data
end FM;	  

architecture BEH of FM is
type MEM64X16 is array(0 to 63) of BIT_VECTOR(15 downto 0);
signal addr,do: BIT_VECTOR(15 downto 0);
begin					
---- Block of register memory ---------------
FM64:process(CLK,AD,AB)  
variable RAM: MEM64x16;
variable addrd,addrb:NATURAL;
begin
 	addrb:= BIT_TO_INT(AB);
 	addrd:= BIT_TO_INT(AD); 
 	if CLK='1' and CLK'event then
 		if (WR = '1') and (addrd /= 0) then
 			RAM(addrd):= D; -- read data from D channel
 		end if;
 	end if;
 	B<= RAM(addrb); -- write data to channel B
end process;
end BEH;