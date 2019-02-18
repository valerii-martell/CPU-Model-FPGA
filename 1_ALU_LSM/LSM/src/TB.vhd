use CNetwork.all;
entity lsm_tb is
end lsm_tb;
architecture TB_ARCHITECTURE of lsm_tb is
 component LSM
 port(F : in BIT;
 A : in BIT_VECTOR(11 downto 0);
 B : in BIT_VECTOR(11 downto 0);
 C0: in BIT;
 Y : out BIT_VECTOR(11 downto 0);
 C3: out BIT;
 N: out BIT;
 Z : out BIT );
end component;
component RANDOM_GEN is
 generic(n:positive:=12; 
 tp:time:=100 ns ; 
 SEED:positive:=1234); 
 port(CLK:out BIT;
 Y : out BIT_VECTOR(n-1 downto 0));
end component;
component RANDOM_BIT is
 generic(tp:time:=100 ns ; 
 SEED:positive:=1234); 
 port(CLK:out BIT;
 Y : out BIT);
end component;

signal F : BIT:='1';
signal C0 : BIT:='0';
signal A,B : BIT_VECTOR(11 downto 0);
signal Y1,Y2,Y : BIT_VECTOR(11 downto 0);
signal C31,C32,C, Z1,Z2,Z, N1,N2,N: BIT;
signal A1, B1, C1 : BIT_VECTOR(11 downto 0);
begin
G1: RANDOM_GEN
 generic map(n=>12,SEED=>123)
 port map(CLK=>open,Y =>A1);
G2: RANDOM_GEN 
generic map(n=>12,SEED=>654) 
port map(CLK=>open,Y =>B1);
BUFFERING: for i in 1 to 10 generate
 A(i)<=A1(i);
 B(i)<=B1(i);
end generate;	
A(11)<='0';
--A(10)<='0';
--A(9)<='0';
--A(8)<='0';
--A(7)<='0';
--A(6)<='0';
--A(5)<='0';
--A(4)<='0';
--A(3)<='1';
--A(2)<='0';
--A(1)<='1';
A(0)<='1';
B(11)<='0';
--B(10)<='0';
--B(9)<='0';
--B(8)<='0';
--B(7)<='0';
--B(6)<='0';
--B(5)<='0';
--B(4)<='1';
--B(3)<='1';
--B(2)<='0';
--B(1)<='0';
B(0)<='1';
--A<="000000001011";
--B<="000000011001";
UUT2 :entity LSM(BEH) 
 port map (F => F,A => A,B => B,C0 => C0,
 Y => Y2, C3 => C32, N=>N2, Z => Z2);
UUT1 :entity LSM(STR_LUT) 
 port map (F => F,A => A,B => B, C0 => C0,
 Y => Y1, C3 => C31, N=>N1, Z => Z1);

 COMP_Y: Y<=Y1 xor Y2;
 COMP_C: C<=C31 xor C32;
 COMP_Z: Z<=Z1 xor Z2;
 COMP_N: N<=N1 xor N2;
end TB_ARCHITECTURE; 