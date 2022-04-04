entity MPU is
port(C : in BIT;
 RST : in BIT;
 START:in BIT;
 OUTHL:in BIT;
 DA : in BIT_VECTOR(15 downto 0); 
 DB : in BIT_VECTOR(15 downto 0); 
 RDY : out BIT; 
 Z: out BIT; 
 N: out BIT; 
 DP : out BIT_VECTOR(14 downto 0) );
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
 N: out BIT; -- result sign
 DP : out BIT_VECTOR(14 downto 0)); -- result bus 
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
 Z=>Z,N=>N,DP=>DP);
 
 --final state machine
 U_FSM:FSM port map(C,RST, -- ??????????? ???????
 START=>start, B0=>b0, LAB=>lab, STOP=>stop, REZ=>rez,
 ADD=>add, SHIFT=>shift, RDY=>RDY);
end BEH; 