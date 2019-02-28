use CNetwork.all;
library ieee;
use ieee.numeric_bit.all;  

entity ICTR is
port(CLK : in BIT; --синхросигнал 
 R : in BIT; --скидання
 WR: in BIT; --запис
 D : in BIT_VECTOR(7 downto 0); --адреса переходу (зміщення) 
 F : in BIT_VECTOR(2 downto 0);  --управляюче слово
 A : out BIT_VECTOR(15 downto 0)); --адреса-результат
end ICTR; 

architecture BEH of ICTR is
signal RG: BIT_VECTOR(2 downto 0);
signal SM: BIT_VECTOR(3 downto 0);
signal CTR:BIT_VECTOR(15 downto 3);
signal CTRi:SIGNED(16 downto 0);
begin
	
---------СУМАТОР-----------
SUM:SM<= INT_TO_BIT( (BIT_TO_INT(RG)+ BIT_TO_INT(F)),4);

---------РЕГІСТР ДЛЯ МОЛОДШОЇ ЧАСТИНИ АДРЕСИ-----------
 R_3:process(R,CLK)
begin
 if R='1' then --асинхронне скидання
 	RG<="000";
 elsif CLK='1' and CLK'event then --збудження по фронту синхросерії
 case F is 
	when "001"|"010"|"011"|"100"=>RG<=SM(2 downto 0); --запис трьох молодших розрядів з суми
 	when "101" => RG<="000"; --синхронне скидання
 	when "110" => RG<=D(2 downto 0); --запис трьох молодших розрядів адреси переходу (зміщення)
 	when others=> null;
 end case;
 end if;
end process;

--------РЕГІСТР-ЛІЧИЛЬНИК ДЛЯ СТАРШОЇ ЧАСТИНИ АДРЕСИ--------
 CT:process(CLK,R)
begin
 if R='1' then --асинхронне скидання
 	CTRi<="00000000111100000";--початковий стан (15*32=480=0001 1110 0000)
 elsif CLK='1' and CLK'event then --збудження по фронту синхросерії
 	if F="101" then	--синхронне скидання
 		CTRi<="00000000111100000"; --початковий стан
	elsif F="110" then --запис адреси переходу
 		CTRi(15 downto 3)<= X"00"&SIGNED(D(7 downto 3)); 
	elsif F="111" then	--додавання зміщення
 		CTRi <= CTRi + SIGNED(D(7 downto 0));
	elsif (F(2) = '0' or F="100") and SM(3) ='1' then --інкремент
 		CTRi<= CTRi+1;
	end if;
 end if; 
end process;

 CTR<= BIT_VECTOR(CTRi(15 downto 3));
 A<=CTR&RG; --склейка результатів з лічильника і регістру
end BEH;