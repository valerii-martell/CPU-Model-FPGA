library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,work. RISC_lib.all; 
--pragma translate_off
library unisim;
--pragma translate_on
entity PRAM is   
	port( CLK : in std_logic;
		RST : in std_logic; 
		ENA:in std_logic;
		ADDRI : in WORD;   
		INSTR : out WORD 	);
end PRAM;                      
architecture PRAM_SYNT of PRAM is  
   component ramb4_s16      -- Block_RAM объемом 256 16-разр€дных слов               
      --pragma translate_off
      generic(   INIT_00, INIT_01, INIT_02: bit_vector); --начальное состо€ние модели   
      --pragma translate_on
      port(
         DI : in std_logic_vector(15 downto 0);
         EN : in std_ulogic;
         WE : in std_ulogic;
         RST : in std_ulogic;
         CLK : in std_ulogic;
         ADDR : in std_logic_vector(7 downto 0);
         DO : out std_logic_vector(15 downto 0));
   end component;         
   attribute INIT_00:  string; -- €чейки пам€ти с 0 по 15
   attribute INIT_01:  string; -- €чейки пам€ти с 16 по 31
   attribute INIT_02:  string; -- €чейки пам€ти с 32 по 47
                                --начальное состо€ние Block_RAM , программируемое в ѕЋ»—=
-- исполн€ема€ программа в RISC_ST_CORE
   attribute INIT_00 of U_PROM: label is "000000000000000000000000e4418104" &
                                                           "000000000000000000000000e3318104" ;
   attribute INIT_01 of U_PROM: label is  "00000000000000000000000000000000" &
                                                           "000000000000000000000000e5518104"; 
   attribute INIT_02 of U_PROM: label is "00000000000000000000350391fcb402" &
                                                           "33013210755174417331620f610c7001";
   signal gnd,eni:std_ulogic;   
   signal DI:word;
begin       
   gnd<='0';      	 
   eni<=To_X01(ENA);
   DI<=(others=>gnd);     
U_PROM:  ramb4_s16 
   --pragma translate_off     --состо€ние пам€ти модели Block_RAM
   generic map(INIT_00 => X"0000_0000_0000_0000_0000_0000_e441_8104" &
                           X"0000_0000_0000_0000_0000_0000_e331_8104" ,
      INIT_01 =>  X"0000_0000_0000_0000_0000_0000_0000_0000" &
                        X"0000_0000_0000_0000_0000_0000_e551_8104",
      INIT_02 => X"0000_0000_0000_0000_0000_3503_91fc_b402" &
                        X"3301_3210_7551_7441_7331_620f_610c_7001")
   --pragma translate_on
   port map(
      DI =>DI,
      EN =>eni,
      WE=>gnd,
      RST =>RST,
      CLK =>CLK,
      ADDR =>ADDRI(7 downto 0),
      DO =>INSTR);       
end PRAM_SYNT;

