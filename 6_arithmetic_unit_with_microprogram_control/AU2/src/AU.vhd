Library IEEE;
use IEEE.NUMERIC_BIT.all;
use CNetwork.all;

entity AU is port(
 C : in BIT; --sycnhro
 RST : in BIT; --reset
 START : in BIT; --start operation in AU
 RD: in BIT; -- read from FM to DO bus
 WRD : in BIT; -- write from DI bus
 RET : in BIT; -- return from subprogram
 CALL: in BIT; -- start subprogram
 DI : in BIT_VECTOR(15 downto 0); --in data bus
 AB : in BIT_VECTOR(5 downto 0); -- register B address
 AD : in BIT_VECTOR(5 downto 0); -- register D address
 AQ : in BIT_VECTOR(5 downto 0); -- register Q address
 ARET : in BIT_VECTOR(12 downto 0); --in return address
 ACOP : in BIT_VECTOR(2 downto 0); -- AU operation code
 RDY : out BIT; --result ready
 ARETO : out BIT_VECTOR(12 downto 0);--out return address
 DO : out BIT_VECTOR(15 downto 0); --out data bus
 BO : out BIT_VECTOR(15 downto 0); --out data bus D
 CNZ: out BIT_VECTOR(2 downto 0)); --out state reg
end AU; 

architecture BEH of AU is

component FM is port(
 C: in BIT; -- synchro
 WR: in BIT; -- write
 INCQ: in BIT;-- inc Q address
 CALL: in BIT;-- write return address and CNZ
 AB: in BIT_VECTOR(5 downto 0);-- address B
 AD: in BIT_VECTOR(5 downto 0);-- address D
 AQ: in BIT_VECTOR(5 downto 0);-- address Q
 ARETC: in BIT_VECTOR (15 downto 0);--????? ???????? ? CNZ 
 Q: in BIT_VECTOR (15 downto 0);-- ?????? ?????? Q
 B: out BIT_VECTOR(15 downto 0);-- ?????? ?????? ?
 D: out BIT_VECTOR(15 downto 0);-- ?????? ?????? D
 ARETCO: out BIT_VECTOR (15 downto 0));-- ????? ???????? ? CNZ
end component ;

component LSM is port(
 F : in BIT_VECTOR(1 downto 0);-- function
	 A : in BIT_VECTOR(15 downto 0);-- first operand
	 B : in BIT_VECTOR(15 downto 0);-- second operand 
	 Y : out BIT_VECTOR(15 downto 0);-- result
	 C15: out BIT; -- transfer output
	 Z: out BIT; -- bit of zero result
	 N: out BIT);-- sign bit
end component ;

component MPU is port(
 C : in BIT;
 RST : in BIT;
 START:in BIT;
 OUTHL:in BIT;
 DA : in BIT_VECTOR(15 downto 0); 
 DB : in BIT_VECTOR(15 downto 0); 
 RDY : out BIT; 
 Z: out BIT; 
 DP : out BIT_VECTOR(15 downto 0) );
end component ;

type STAT_AU is (free,mpy,mpyl);-- fsm states
signal st:STAT_AU;
signal b,q,d,y,dp,aretc,aretco:BIT_VECTOR(15 downto 0);
signal c0,c15,csh,zlsm,wr,mult,outhl:BIT;
signal rdym,zmpy,nmpy:BIT;
signal cnzr,cnzo,cnzi:BIT_VECTOR(2 downto 0);

begin
---------FM unit---------	
 U_FM: FM port map(C, 
 WR=>wr, INCQ=>outhl, CALL=>CALL,
 AB=>AB, AD=>AD, AQ=>AQ,
 ARETC=>aretc,
 Q=>q, B=>b, D=>d,
 ARETCO=>aretco);
 
 aretc<=cnzr&ARET;
 cnzo<=aretco(15 downto 13); --read control bits (C, N, Z) from high bits of last register of FM 
 ARETO<=aretco(12 downto 0); --read return address from low bits of register of FM
 
 --MUX_C:c0<='1' when ACOP(1 downto 0)="10" else --мультиплексор С0
 --   cnzi(2) when ACOP(1 downto 0)="01" else '0';
 
----------LSM unit----------
 U_LSM:LSM port map(F=>ACOP(1 downto 0), 
 A=>d,B=>b,Y =>y,
 C15=>c15, Z =>zlsm );

----------MPU----------
 U_MPU:MPU port map(C,RST, 
 START=>mult, OUTHL=>outhl,
 DA=>d, DB=>b,
 RDY=>rdym,Z=>zmpy, DP=>dp);
 
 ---------MUL multiplexor---------
 --MUX_CI:csh<=cnzi(2) when ACOP(1 downto 0)="01" else --задвиг. разр.
 --            cnzi(1) when ACOP(1 downto 0)="11" else '0';
	 
 ----- result multiplexor ---------
 MUX_Q:       q<=dp when st/=free else --multiply result
 "10"&d(14 downto 1) when ACOP="110" and d(15)='1' else --right shift
 '0'&d(15 downto 1)  when ACOP="110" and d(15)='0' else
 INT_TO_BIT((BIT_TO_INT(d(15 downto 0))+1),16) when ACOP="101" else --inc	 
                 DI when WRD='1' else --result subprogram
                  d when RD='1' else --data from AD in AD address
                         y; --LSM result

-------state refister with multiplexor--------------
 SR:process(C,RST)
 begin
	 if RST='1' then
	 	cnzi<="000";
	 elsif C='1' and C'event then
	 	if RET='1' then
	 		cnzi<=cnzo;
	 	elsif st=mpyl then
	 		cnzi<='0'&nmpy&zmpy;
	 	elsif mult='0' then
	 		cnzi<=c15&y(15)&zlsm; 

	 	end if;
	 end if;
 end process;
 
 mult<='1' when ACOP="111" else '0';--multiply decoder

---------AU FSM-----------
 FSM_AU:process(C,RST) 
 begin
	 if RST='1' then
	 	st<=free; -- fsm state register
	 elsif C='1' and C'event then
	 	case st is
	 		when free => if START='1'and mult='1'then --not use
	 			st<=mpy;
	 			end if;
	 		when mpy=> if rdym='1' then -- there is a multiplication
	 			st<=mpyl ;
	 			end if;
	 		when mpyl=> st<=free; --multiplication finish
	 	end case;
	 end if;
 end process;

--fsm outs
 outhl<='1' when st=mpyl else '0';
 wr<='1' when WRD='1' or st=mpyl or (st=mpy and rdym='1') or (START='1' and mult='0') else '0';
 RDY<='1'when st=mpyl or (WRD='0' and st/=mpy and mult='0') else'0';
 DO<=q; --output data
 BO<=B;
 CNZ<=cnzi; --state reg out
end BEH; 