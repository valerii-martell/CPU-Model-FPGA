architecture STR_LUT of LSM is
signal a_ovf_c, b_ovf_c, y_ovf_c, c, c2, x, yi, yr: BIT_VECTOR (13 downto 0);
signal zer:BIT_VECTOR(2 downto 0);
signal a_buf, b_buf, y_buf, adk, bdk, ydk, ydk1, ypk, m, rez: BIT_VECTOR (11 downto 0); 
signal buffer1, buffer2, R: BIT;


 component LUT4 is
 generic(mask:BIT_VECTOR(15 downto 0):=X"ffff"; td:time:=1 ns); 
 port (a, b, c, d: in BIT;
 Y: out BIT);
 end component;
 component LUT5 is
 generic(mask:BIT_VECTOR(31 downto 0):=X"ffffffff"; td:time:=1 ns); 
 port (a, b, c, d, e: in BIT;
 Y: out BIT);
 end component;
 begin
 c(0)<=C0; 													   
 --BUFFERING: for i in 0 to 11 generate
 	--a_buf(i)<=A(i);
 	--b_buf(i)<=B(i);
 --end generate;
-- Arithmetic-logic circuit diagram ---------------------------

--if F=1 then reverse sign B
--LSM_REVERSE:LUT4 generic map(mask=>X"0006") 
--port map(a=>B(11), b=>F,c=>'0',d=> '0', Y =>buffer1);

--save A and B sing
a_buf(11)<=A(11); 
b_buf(11)<=not B(11);

--Two's complement code
LSM_TCC:for i in 0 to 10 generate
 --invertor
 INVERSION_A:LUT4 generic map(mask=>X"0006") --if sign "-"(1) then inv.
 port map(a=>A(i), b=>a_buf(11),c=>'0',d=>'0', Y =>a_buf(i)); 
 INVERSION_B:LUT4 generic map(mask=>X"0006") --if sign "-"(1) then inv.
 port map(a=>B(i), b=>b_buf(11),c=>'0',d=>'0', Y =>b_buf(i));
end generate; 

 --add 1
ADD1_A:LUT4 generic map(mask=>X"0006")
port map(a=>a_buf(0), b=>a_buf(11),c=>'0',d=>'0', Y =>adk(0));
ADD1_B:LUT4 generic map(mask=>X"0006")
port map(a=>b_buf(0), b=>b_buf(11),c=>'0',d=>'0', Y =>bdk(0));

 --overflow check
OVF_CHECK_A:LUT4 generic map(mask=>X"0008")
port map(a=>a_buf(0), b=>a_buf(11),c=>'0',d=>'0', Y =>a_ovf_c(1));  
OVF_CHECK_B:LUT4 generic map(mask=>X"0008")
port map(a=>b_buf(0), b=>b_buf(11),c=>'0',d=>'0', Y =>b_ovf_c(1));
 
LSM_OVF:for i in 1 to 10 generate
 FULL_OVF_CHECK_A:LUT4 generic map(mask=>X"0080")
 port map(a=>a_ovf_c(i), b=>a_buf(i),c=>a_buf(11),d=>'0', Y =>a_ovf_c(i+1));
 OVERFLOW_ADD_A:LUT4 generic map(mask=>X"006C")
 port map(a=>a_ovf_c(i), b=>a_buf(i),c=>a_buf(11),d=>'0', Y =>adk(i));
 FULL_OVF_CHECK_B:LUT4 generic map(mask=>X"0080")
 port map(a=>b_ovf_c(i), b=>b_buf(i),c=>b_buf(11),d=>'0', Y =>b_ovf_c(i+1));
 OVERFLOW_ADD_B:LUT4 generic map(mask=>X"006C")
 port map(a=>b_ovf_c(i), b=>b_buf(i),c=>b_buf(11),d=>'0', Y =>bdk(i));
end generate;

--sign bit
adk(11)<=a_buf(11);
bdk(11)<=b_buf(11);	

--ADDER
LSM_ADDER:for i in 0 to 11 generate
 ADD:LUT4 generic map(mask=>X"0006")
 port map(a=>bdk(i), b=>adk(i),c=>'0',d=>'0', Y =>x(i));
 OVERFLOW_CHECK:LUT4 generic map(mask=>X"0008")
 port map(a=>bdk(i), b=>adk(i),c=>'0',d=>'0', Y =>c(i+1));
 OVERFLOW_ADD:LUT4 generic map(mask=>X"0006")
 port map(a=>c(i), b=>x(i),c=>'0',d=>'0', Y =>ydk1(i));
end generate;

LSM_ADDER1:for i in 1 to 11 generate
 OVERFLOW_CHECK2:LUT4 generic map(mask=>X"0008")
 port map(a=>c(i), b=>x(i),c=>'0',d=>'0', Y =>c2(i+1));
 OVERFLOW_ADD2:LUT4 generic map(mask=>X"0006")
 port map(a=>ydk1(i), b=>c2(i),c=>'0',d=>'0', Y =>ydk(i));
end generate;

--CHECK SIGN OVERFLOW
 --SIGN_OVF_CHECK:LUT4 generic map(mask=>X"0006")
 --port map(a=>c(12), b=>c(11),c=>'0',d=>'0', Y =>R);
 --R<='0';
 
--RESULT BIN CODE
LSM_TCC_REZ:for i in 0 to 10 generate
 --invertor
 INVERSION_REZ:LUT4 generic map(mask=>X"0006") --if sign "-"(1) then inv.
 port map(a=>ydk(i), b=>ydk(11), c=>'0', d=>'0', Y =>y_buf(i));
end generate; 
y_buf(11)<=ydk(11);

 --add 1
ADD1_REZ:LUT4 generic map(mask=>X"0006")
port map(a=>y_buf(0), b=>y_buf(11),c=>'0',d=>'0', Y =>ypk(0));

 --overflow check
OVF_CHECK_REZ:LUT4 generic map(mask=>X"0008")
port map(a=>y_buf(0), b=>y_buf(11),c=>'0',d=>'0', Y =>y_ovf_c(1));
 
LSM_OVF_REZ:for i in 1 to 10 generate
 FULL_OVF_CHECK_REZ:LUT4 generic map(mask=>X"0080")
 port map(a=>y_ovf_c(i), b=>y_buf(i),c=>y_buf(11),d=>'0', Y =>y_ovf_c(i+1));
 OVERFLOW_ADD_REZ:LUT4 generic map(mask=>X"006C")
 port map(a=>y_ovf_c(i), b=>y_buf(i),c=>y_buf(11),d=>'0', Y =>ypk(i));
end generate;

--sign bit
ypk(11)<=y_buf(11);	
 
--MINIMUM
LSM_MIN:for i in 0 to 11 generate
 MIN:LUT4 generic map(mask=>X"00CA")
 port map(a=>B(i), b=>A(i),c=>ypk(11),d=>'0', Y =>m(i));
end generate; 

--MULTIPLEXER 
LSM_MULT:for i in 0 to 11 generate
 MULT:LUT4 generic map(mask=>X"00CA")
 port map(a=>ypk(i), b=>m(i),c=>F,d=>'0', Y =>rez(i));
end generate;

-- Definition of zero result
 UZ1:LUT4 generic map(mask=>X"0001")
 port map(a=>rez(3),b=>rez(2),c=> rez(1),d =>rez(0), Y =>zer(0));
 UZ2:LUT4 generic map(mask=>X"0001")
 port map(a=>rez(7),b=>rez(6),c=> rez(5),d =>rez(4), Y =>zer(1));
 UZ3:LUT4 generic map(mask=>X"0001")
 port map(a=>rez(11),b=>rez(10),c=> rez(9),d =>rez(8), Y =>zer(2));
 UZ4:LUT4 generic map(mask=>X"0080")
 port map(a=>zer(0),b=>zer(1),c=> zer(2),d =>'0', Y =>Z);
 
 Y<=rez(11 downto 0); 
 N<=rez(11);
 C3<=y_ovf_c(12);  --extraction of transfer
end STR_LUT;