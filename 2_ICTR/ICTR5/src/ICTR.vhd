use CNetwork.all;
library ieee;
use ieee.numeric_bit.all;  

entity ICTR is
port(CLK : in BIT; --синхросигнал 
 R : in BIT; --скидання
 WR: in BIT; --запис
 D : in BIT_VECTOR(11 downto 0); --адреса переходу (зміщення) 
 F : in BIT_VECTOR(2 downto 0);  --управляюче слово
 A : out BIT_VECTOR(15 downto 0)); --адреса-результат
end ICTR; 

architecture BEH of ICTR is
signal RG: BIT_VECTOR(11 downto 0);
signal SM: BIT_VECTOR(12 downto 0);
signal CTR:BIT_VECTOR(15 downto 12);
signal CTRi:SIGNED(16 downto 0);
begin
	
---------СУМАТОР-----------
SUM: SM <= INT_TO_BIT((BIT_TO_INT(RG)+ BIT_TO_INT(F)),13) when F="001" or F="010" or F="011" or F="100" else
	       INT_TO_BIT((BIT_TO_INT(RG)+ BIT_TO_INT(D)),13);

---------РЕГІСТР СУМАТОРА-----------
 R_12:process(R,CLK)
begin
 if R='1' then --асинхронне скидання
 	RG<="000101000000"; --початковий стан (10*32=320=0001 0100 0000)
 elsif CLK='1' and CLK'event then --збудження по фронту синхросерії
 case F is 
	when "001"|"010"|"011"|"100"|"111"=>RG<=SM(11 downto 0); --запис молодших розрядів з суми
 	when "101" => RG<="000101000000"; --синхронне скидання на початковий стан (10*32=320=0001 0100 0000)
 	when "110" => RG<=D(11 downto 0); --запис адреси переходу (зміщення)
 	when others=> null;
 end case;
 end if;
end process;

--------РЕГІСТР-ЛІЧИЛЬНИК--------
 CT:process(CLK,R)
begin
 if R='1' then --асинхронне скидання
 	CTRi<="00000000101000000";--початковий стан (10*32=320=0001 0100 0000)
 elsif CLK='1' and CLK'event then --збудження по фронту синхросерії
 	if F="101" then	--синхронне скидання
 		CTRi<="00000000101000000"; --початковий стан
	elsif F="110" then --запис адреси переходу (молодші біти візьмуться з регістру)
 		CTRi(15 downto 12)<= X"0"; 			  
	elsif (F(2) = '0' or F="100" or F="111") and SM(3) ='1' then --інкремент в результаті переповнення на суматорі
 		CTRi<= CTRi+1;
	end if;
 end if; 
end process;

 CTR<= BIT_VECTOR(CTRi(15 downto 12));
 A<=CTR&RG; --склейка результатів з лічильника і регістру
end BEH;