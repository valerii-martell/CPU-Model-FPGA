library IEEE;
use IEEE.Numeric_Bit.all;
use CNetwork.all;

entity OB is
port(C : in BIT; --synchro
 RST : in BIT; --reset
 LAB : in BIT; -- load A,B, reset P
 SHIFT : in BIT; --shift A and B flag
 OUTHL : in BIT; --get first(1) or last(0) result word
 DA : in BIT_VECTOR(15 downto 0); --A bus
 DB : in BIT_VECTOR(15 downto 0); --B bus
 ADD : in BIT; --adder start flag
 REZ : in BIT; --correction flag
 B0 : out BIT; --first bit B
 STOP : out BIT; --stop flag
 Z: out BIT; -- result zero flag
 N: out BIT; -- result sign
 DP : out BIT_VECTOR(14 downto 0)); -- result bus
end OB;	

architecture BEH of OB is
signal A:bit_vector(29 downto 0); -- register A data
signal SA:bit; --A sign bit
signal B:bit_vector(14 downto 0); -- register B data
signal SB:bit; --B sign bit
signal S: unsigned(29 downto 0); -- adder buffer
signal P: unsigned(29 downto 0); -- register P data
begin		  
 -- register A	
 RG_A:process(C,RST) 
 --variable high,low:natural;
begin
 if RST='1' then
 	A<="000000000000000000000000000000"; --reset all 30 bits
 elsif C='1' and C'event then
	if LAB='1' then	
		A(29 downto 15)<="000000000000000"; --reset 15 last bits
		SA<=DA(15); --load A sign bit
		A(14 downto 0)<=DA(14 downto 0); -- load A data bits
		--high:=14; --start values of pointers
		--low:=0;
	elsif SHIFT='1' then
		--if high/=29 then 
			A(29 downto 0)<=A(29 downto 1)&'0'; --left shift
			--A(high+1 downto low+1)<=A(high downto low); --left shift
--			A(low)<='0';
--			high:=high+1;
--			low:=low+1;
		--end if;
	end if;
 end if;
end process; 

 -- register B
 RG_B:process(C,RST) 
begin
 if RST='1' then
 	B<="000000000000000";	--reset	register
	STOP<='0'; --reset checks bits
	B0<='0';
 elsif C='1' and C'event then
 	if LAB='1' then
		STOP<='0';	--reset checks bits
		B0<='0';
	    if DB(0)='1' then B0<='1'; else B0<='0'; end if; --check first bit of B 
		if BIT_TO_INT(DB(14 downto 0))=0 then STOP<='1'; else STOP<='0'; end if; --if B=0 then stop  
 		SB<=DB(15); --load B sign bit
		B(14 downto 0)<=DB(14 downto 0); --load B data bits
 	elsif SHIFT='1' then
 		if B(1)='1' then B0<='1'; else B0<='0'; end if;
		if BIT_TO_INT('0'&B(14 downto 1))=0 then STOP<='1'; else STOP<='0'; end if;
		B<='0'& B(14 downto 1); --right shift	 	
    end if;
 end if;
end process; 

 -- Adder
 SM:S(29 downto 0) <= unsigned(P)+unsigned(A) when ADD='1' else P(29 downto 0);
 
 -- register P (result)	 
 RG_P:process(C,RST,P) 
 variable zi:bit;
begin
 if RST='1' then
 	P<="000000000000000000000000000000"; --reset
 elsif C='1' and C'event then
 	if LAB='1' then
 		P<="000000000000000000000000000000"; --reload
	elsif REZ='1' then
		P<='0'&P(29 downto 1); --result correction
		N<=SA xor SB;
 	else 
		P(29 downto 0)<=S(29 downto 0);
 	end if;
 end if;
 zi:='0'; --zero result check
 for i in P'range loop
 	zi:=zi or P(i);
 end loop;
 Z<= not zi; -- zero result flag
end process;

 --output multiplexor
 MUX_P:DP<= bit_vector(P(14 downto 0)) when OUTHL='1' else bit_vector(P(29 downto 15));
end BEH;