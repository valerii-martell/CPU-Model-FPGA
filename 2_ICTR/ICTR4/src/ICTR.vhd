use CNetwork.all;
library ieee;
use ieee.numeric_bit.all;  

entity ICTR is
port(
 CLK : in BIT; --синхросигнал 
 R : in BIT; --сброс
 WR: in BIT; --запись
 D : in BIT_VECTOR(10 downto 0); --адрес перехода (смещение) 
 F : in BIT_VECTOR(2 downto 0);  --управляющее слово
 A : out BIT_VECTOR(15 downto 0)); --новый адрес (результат)
end ICTR; 

architecture BEH of ICTR is
signal RG: BIT_VECTOR(2 downto 0);
signal SM: BIT_VECTOR(3 downto 0);
signal CTR:BIT_VECTOR(15 downto 3);
signal CTRi:SIGNED(16 downto 0);
begin
	
---------СУММАТОР-----------
SUM:SM <= INT_TO_BIT((BIT_TO_INT(RG) + 4),4) when F="011" else --+4
		  INT_TO_BIT((BIT_TO_INT(RG) + 8),4) when F="100" else --+8
		  INT_TO_BIT((BIT_TO_INT(RG) + BIT_TO_INT(F)),4);

---------РЕГИСТР МЛ. ЧАСТИ АДРЕСА-----------
 R_3:process(R,CLK)
begin
 --асинхронный сброс
 if R='1' then 
 	RG<="000";
 --возбуждение по фронту синхросерии
 elsif CLK='1' and CLK'event then 
 case F is 
	--запись 3 мл. битов из сумматора 
	when "001"|"010"|"011"|"100"=>RG<=SM(2 downto 0);
	--синхронный сброс
 	when "101" => RG<="000";
	--запись троих младших разрядов адреса перехода (смещения)
 	when "110" | "111" => RG<=D(2 downto 0); 
 	when others=> null;
 end case;
 end if;
end process;

--------РЕГСТИР-СЧЕТЧИК СТ. ЧАСТИ АДРЕСА--------
 CT:process(CLK,R)
begin 
 --асинхронный сброс
 if R='1' then
	--начальное состояние счетчика(28*32=896=0011 1000 0000)
 	CTRi<="00000001110000000";
 --возбуждение по фронту синхросерии	 
 elsif CLK='1' and CLK'event then 
 	--синхронный сброс
	if F="101" then	
		--начальное состояние
 		CTRi<="00000001110000000"; 
	elsif F="110" then 
		--запись адреса перехода
 		CTRi(15 downto 3)<= "00000"&SIGNED(D(10 downto 3)); 
	elsif F="111" then
		--"склейка" с адресом короткого перехода произойдет на этапе формирования результата,
		--сейчас же сдвинем влево уже имеющийся адрес
 		CTRi(15 downto 3)<= CTRi(12 downto 0);
	elsif (F(2) = '0' or F="100") and SM(3) ='1' then 
		--инкремент
 		CTRi<= CTRi+1;
	end if;
 end if; 
end process;

 CTR<= BIT_VECTOR(CTRi(15 downto 3));
 A<=CTR&RG; --"склейка" результатов регстира-счетчика и регистра сумматора
end BEH;