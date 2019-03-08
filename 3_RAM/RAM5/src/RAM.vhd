library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.all;
use CNetwork.all;

entity RAM is
port(
 CLK : in BIT; -- synchro
 R : in BIT; -- reset
 WR: in BIT; -- write
 AE: in BIT; --address fixation
 A: in STD_LOGIC_VECTOR(15 downto 0); --address bus
 D : inout STD_LOGIC_VECTOR(15 downto 0));-- data bus
end RAM; 		

architecture BEH of RAM is
type MEM48KX16 is array(0 to 49151) of BIT_VECTOR(15 downto 0);
constant RAM_init: MEM48KX16:= -- initial memory status
 (X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",others=> X"0000");
signal addr: BIT_VECTOR(15 downto 0);
signal addri : INTEGER;
begin
 ------Address register-----------
RG_ADDR:process(CLK,R) begin 
 if R='1' then
 	addr<=X"0000";
 elsif CLK='1' and CLK'event and AE='1' then
 	addr<= To_bitvector(A);
 end if;
end process; 
 ------ Memory block ------------------
RAM768K:process(CLK,addr,addri)
variable RAM: MEM48KX16:= RAM_init; 
--variable addri: INTEGER;
 begin
 addri <= BIT_TO_INT(addr(15 downto 0));  
 if CLK='1' and CLK'event then
	 if WR = '1' then
	 	RAM(addri):= To_bitvector(D); --write 
	 end if;
	 if R='1' then
	 	D<= X"0000"; --reset
	 else
	 	D<= To_StdLogicVector(RAM(addri)); --read
	 end if;
 end if;
end process; 
end BEH; 