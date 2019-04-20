
library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,work. RISC_lib.all; 
--pragma translate_off
library unisim;                --библиотека с моделями ОЗУ, реализуемыми в ПЛИС
--pragma translate_on
entity PRAM is  port( CLK : in std_logic;
      RST : in std_logic; 
      ENA:in std_logic;     -- разрешение работы
      ADDRI : in WORD;   --  адрес команды
      INSTR : out WORD);--считанная команда 
end PRAM;                      

architecture PRAM_BEH of PRAM is  --поведенческая модель памяти программ
   signal address : natural;
begin   
   PRAM: process
      variable PROM:PMEM_ARR;
   begin
      Load_F( PROG_FILE,PROM);                     --загрузка памяти из файла             
      loop                    
         if   Rising_edge(CLK) and (ENA='1' or ENA='H') then
            address<= Conv_Integer(ADDRI);  --запоминание адреса
         end if;            
         INSTR<=PROM(address);                    -- чтение команды            
         wait on CLK,RST,ADDRI,address ;
      end loop;
   end process;                
end PRAM_BEH;

