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
 DP : out BIT_VECTOR(15 downto 0)); -- result bus
end OB;	

architecture BEH of OB is
signal A:bit_vector(31 downto 0); -- register A data
signal SA:bit; --A sign bit
signal B:bit_vector(15 downto 0); -- register B data
signal SB:bit; --B sign bit
signal S: unsigned(31 downto 0); -- adder buffer
signal P: unsigned(31 downto 0); -- register P data
begin		  
 -- register A	
 RG_A:process(C,RST) 		 
begin
 if RST='1' then
 	A<=X"00000000"; --reset all bits
 elsif C='1' and C'event then
	if LAB='1' then	
		A(31 downto 16)<=X"0000"; --reset 16 last bits
		A(15 downto 0)<=DA(15 downto 0); -- load A data bits
	elsif SHIFT='1' then   
		A(31 downto 0)<=A(30 downto 0)&'0'; --left shift 
	end if;
 end if;
end process; 

 -- register B
 RG_B:process(C,RST) 
begin
 if RST='1' then
 	B<=X"0000";	--reset	register
	STOP<='0'; --reset checks bits
	B0<='0';
 elsif C='1' and C'event then
 	if LAB='1' then
		STOP<='0';	--reset checks bits
		B0<='0';
	    if DB(0)='1' then B0<='1'; else B0<='0'; end if; --check first bit of B 
		if BIT_TO_INT(DB(15 downto 0))=0 then STOP<='1'; else STOP<='0'; end if; --if B=0 then stop  
		B(15 downto 0)<=DB(15 downto 0); --load B data bits
 	elsif SHIFT='1' then
 		if B(1)='1' then B0<='1'; else B0<='0'; end if;
		if BIT_TO_INT('0'&B(15 downto 1))=0 then STOP<='1'; else STOP<='0'; end if;
		B<='0'& B(15 downto 1); --right shift	 	
    end if;
 end if;
end process; 

 -- Adder
 SM:S(31 downto 0) <= unsigned(P)+unsigned(A) when ADD='1' else P(31 downto 0);
 
 -- register P (result)	 
 RG_P:process(C,RST,P) 
 variable zi:bit;
begin
 if RST='1' then
 	P<=X"00000000"; --reset
 elsif C='1' and C'event then
 	if LAB='1' then
 		P<=X"00000000"; --reload
	elsif REZ='1' then
		P<='0'&P(31 downto 1); --result correction
 	else 
		P(31 downto 0)<=S(31 downto 0);
 	end if;
 end if;
 zi:='0'; --zero result check
 for i in P'range loop
 	zi:=zi or P(i);
 end loop;
 Z<= not zi; -- zero result flag
end process;

 --output multiplexor
 MUX_P:DP<= bit_vector(P(15 downto 0)) when OUTHL='1' else bit_vector(P(31 downto 16));
end BEH;

entity FSM is
port(
 C : in BIT; --synchro
 RST : in BIT; --reset FSM
 START : in BIT; --start FSM
 B0 : in BIT;
 STOP: in BIT; -- check '1' bits of B
 LAB : out BIT; -- load operands
 SHIFT : out BIT; --shift A and B
 ADD: out BIT; -- add 
 REZ: out BIT;
 RDY : out BIT); --finish
end FSM;

architecture BEH of FSM is
type STATES is (ststart,st1,st2,st3,st4,stfinish); --machine states
signal st:STATES; --current state
begin
 STATE:process(C,RST) -- state register
begin
 if RST='1' then
 st<=ststart;
 elsif C='1' and C'event then 
	 if st=ststart and START='1' then
		 st<=st1; --from start to load-operands-state
	 elsif st=st1 and STOP='1' then
		 st<=stfinish; --if B=0 then finish without other states
	 elsif st=st1 and STOP='0' and B0='1' then
		 st<=st2; --if B(0)=1 then ADD
	 elsif st=st1 and STOP='0' and B0='0' then
		 st<=st3; --if B(0)=0 then SHIFT
     elsif st=st2 then
		 st<=st3; --after ADD always SHIFT
	 elsif st=st3 and STOP='0' and B0='0' then
		 st<=st3; --if after SHIFT B(0)='0' then one more SHIFT
	 elsif st=st3 and STOP='0' and B0='1' then
		 st<=st2; --if after SHIFT B(0)='1' then ADD
	 elsif st=st3 and STOP='1' then
		 st<=st4; --if after SHIFT B=0 then RSH result
	 elsif st=st4 then
		 st<=stfinish; --always go to finish after RSH
	 elsif st=stfinish and START='1' then
		 st<=ststart;
	 end if; 
 end if; 
end process;
-- output signals logic
 LAB<='1' when st=st1 else '0';
 ADD<='1' when st=st2 else '0';
 SHIFT<='1' when st=st3 else '0';
 REZ<='1' when st=st4 else '0';
 RDY<='1' when st=stfinish else '0';
end BEH;  

entity MPU is
port(C : in BIT;
 RST : in BIT;
 START:in BIT;
 OUTHL:in BIT;
 DA : in BIT_VECTOR(15 downto 0); 
 DB : in BIT_VECTOR(15 downto 0); 
 RDY : out BIT; 
 Z: out BIT;  
 DP : out BIT_VECTOR(15 downto 0) );
end MPU; 

architecture BEH of MPU is
component OB is port(
 C : in BIT; --synchro
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
 DP : out BIT_VECTOR(15 downto 0)); -- result bus 
end component; 

component FSM is port(
 C : in BIT; --synchro
 RST : in BIT; --reset FSM
 START : in BIT; --start FSM
 B0 : in BIT;  --first bit B flag
 STOP: in BIT; -- check '1' bits of B
 LAB : out BIT; -- load operands
 SHIFT : out BIT; --shift A and B
 ADD: out BIT; -- add
 REZ: out BIT; --correction flag
 RDY : out BIT); --finish
end component ;	

signal lab,shift,add,b0,stop,rez:bit;
begin	  
 --operation block
 U_OP:OB port map(C,RST, 
 LAB=>lab, SHIFT=>shift,
 ADD=>add,B0=>b0,OUTHL=>OUTHL,
 DA=>DA, DB=>DB, STOP=>stop, REZ=>rez,
 Z=>Z,DP=>DP);
 
 --final state machine
 U_FSM:FSM port map(C,RST, -- ??????????? ???????
 START=>start, B0=>b0, LAB=>lab, STOP=>stop, REZ=>rez,
 ADD=>add, SHIFT=>shift, RDY=>RDY);
end BEH; 



  

