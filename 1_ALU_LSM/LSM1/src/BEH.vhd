--use CNetwork.all, FUN.all;	
library ieee;
use ieee.numeric_bit.all;	

entity LSM is
port(F : in BIT;-- function
	 A : in BIT_VECTOR(11 downto 0);-- first operand
	 B : in BIT_VECTOR(11 downto 0);-- second operand
	 C0: in BIT; -- transfer port
	 Y : out BIT_VECTOR(11 downto 0);-- result
	 C3: out BIT; -- transfer output
	 Z: out BIT; -- bit of zero result
	 N: out BIT);-- sign bit
end LSM;

architecture BEH of LSM is
signal ai, bi, ci: signed(11 downto 0);	
signal yi: signed(12 downto 0);
signal ybi: BIT_VECTOR (12 downto 0);	

function MIN(a,b:signed)return signed is
begin			  
	if a> b then
		return b;
	else
		return a;
	end if;  
end function ;

begin
-- Present the input data as signed --
ai <= signed(A);
bi <= signed(B);
-- Adder --
ADDER: yi <= RESIZE(SIGNED(ai),13) - RESIZE(SIGNED(bi),13) - signed('0'&C0) when F = '0';
-- Results multiplexer --
MUX: with F select
 ybi <= bit_vector(yi) when '0', -- adder
 '0'&bit_vector(MIN(ai,bi)) when others;
 C3 <= ybi (12); -- output transfer	
 N <= ybi(11); --sign bit
 Z <= '1' when ybi (11 downto 0) = "000000000000" else '0'; -- zero sign
 Y <= ybi (11 downto 0); -- Result
end BEH;