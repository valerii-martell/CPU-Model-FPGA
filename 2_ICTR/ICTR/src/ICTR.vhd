use CNetwork.all;
library ieee;
use ieee.numeric_bit.all;  

entity ICTR is
port(CLK : in BIT; 
 R : in BIT; 
 WR: in BIT;
 D : in BIT_VECTOR(12 downto 0); 
 F : in BIT_VECTOR(2 downto 0); 
 A : out BIT_VECTOR(15 downto 0) 
 );
end ICTR; 

architecture BEH of ICTR is
signal RG: BIT_VECTOR(2 downto 0);
signal SM: BIT_VECTOR(3 downto 0);
signal CTR:BIT_VECTOR(15 downto 3);
signal CTRi:SIGNED(16 downto 0);
begin
-- SUM ------------------------------------------ 
SUM:SM<= INT_TO_BIT( (BIT_TO_INT(RG)+ BIT_TO_INT(F)),4);
-- RG -------------------------------------------
 R_3:process(R,CLK)
begin
 if R='1' then
 RG<="000";
 elsif CLK='1' and CLK'event then
 case F is 
	when "001"|"010"|"011"|"100"=>RG<=SM(2 downto 0);
 	when "101" => RG<="000";
 	when "110" => RG<=D(2 downto 0); 
 	when others=> null;
 end case;
 end if;
end process; 
-- CT -------------------------------------------
 CT:process(CLK,R)
begin
 if R='1' then
 CTRi<="00000001011100000";--23*32=736=0010 1110 0000
 elsif CLK='1' and CLK'event then
 if F="101" then
 CTRi<="00000001011100000";
elsif F="110" then
 CTRi(15 downto 3)<= "000"&SIGNED(D(12 downto 3)); 
elsif F="111" then
 CTRi <= CTRi + SIGNED(D(12 downto 0));
elsif (F(2) = '0' or F="100") and SM(3) ='1' then
 CTRi<= CTRi+1;
end if;
 end if; 

end process;
 CTR<= BIT_VECTOR(CTRi(15 downto 3));
 A<=CTR&RG; 
end BEH;