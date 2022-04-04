library ieee;
use ieee.numeric_bit.all;	
use CNetwork.all;

entity LSM is
port(F : in BIT_VECTOR(1 downto 0);-- function
	 A : in BIT_VECTOR(15 downto 0);-- first operand
	 B : in BIT_VECTOR(15 downto 0);-- second operand 
	 Y : out BIT_VECTOR(15 downto 0);-- result
	 C15: out BIT; -- transfer output
	 Z: out BIT; -- bit of zero result
	 N: out BIT);-- sign bit
end LSM;

architecture BEH of LSM is

signal atcc, btcc, ytcc  : BIT_VECTOR(15 downto 0);
signal uatcc,ubtcc,uytcc : BIT_VECTOR(14 downto 0);
signal ai, bi, yi: integer;
signal sb: BIT;
signal usa,usb : unsigned(15 downto 0);
signal uy: unsigned (16 downto 0);
signal yb: BIT_VECTOR (15 downto 0);	

begin 
--for SUB--
SUB:sb<=not B(15) when F="11" else B(15) when F="00";	
	
--two's complement code of operands--
INV_A: uatcc(14 downto 0)<=not A(14 downto 0) when A(15)='1' else A(14 downto 0) when A(15)='0';
INV_B: ubtcc(14 downto 0)<=not B(14 downto 0) when sb='1' else B(14 downto 0) when sb='0';
INC_A: atcc(14 downto 0)<=INT_TO_BIT(BIT_TO_INT(uatcc(14 downto 0))+1 , 15) when A(15)='1' else uatcc(14 downto 0) when A(15)='0';
INC_B: btcc(14 downto 0)<=INT_TO_BIT(BIT_TO_INT(ubtcc(14 downto 0))+1 , 15) when sb='1' else ubtcc(14 downto 0) when sb='0';
SIGN_A:	atcc(15)<=A(15);
SIGN_B:	btcc(15)<=sb;

-- Adder --
ADDER: uy(16 downto 0) <= RESIZE(unsigned(atcc(15 downto 0)),17) + RESIZE(unsigned(btcc(15 downto 0)),17) when (F = "00" or F = "11");

-- Result correction --
INV_Y:uytcc(14 downto 0) <= not BIT_VECTOR(uy(14 downto 0)) when uy(15)='1' else BIT_VECTOR(uy(14 downto 0));
INC_Y:yb(14 downto 0) <= INT_TO_BIT(BIT_TO_INT(uytcc(14 downto 0))+1 , 15) when uy(15)='1' else uytcc(14 downto 0);
SIGN_Y:yb(15)<=BIT(uy(15));	

-- Results multiplexer --
MUX: with F select
Y <= yb(15 downto 0) when "00"|"11", -- adder
           (A and B) when "01", --AND
            (A or B) when "10"; --OR
            
 C15 <= not BIT(uy(16)) when BIT(uy(15))='0' else BIT(uy(16)); -- output transfer	
   N <= yb(15); --sign bit
ZERO_DEF: Z <= '1' when yb (15 downto 0) = X"0000" else '0'; -- zero sign
end BEH;