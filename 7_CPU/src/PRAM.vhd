
library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,work. RISC_lib.all; 
--pragma translate_off
library unisim;                --���������� � �������� ���, ������������ � ����
--pragma translate_on
entity PRAM is  port( CLK : in std_logic;
      RST : in std_logic; 
      ENA:in std_logic;     -- ���������� ������
      ADDRI : in WORD;   --  ����� �������
      INSTR : out WORD);--��������� ������� 
end PRAM;                      

architecture PRAM_BEH of PRAM is  --������������� ������ ������ ��������
   signal address : natural;
begin   
   PRAM: process
      variable PROM:PMEM_ARR;
   begin
      Load_F( PROG_FILE,PROM);                     --�������� ������ �� �����             
      loop                    
         if   Rising_edge(CLK) and (ENA='1' or ENA='H') then
            address<= Conv_Integer(ADDRI);  --����������� ������
         end if;            
         INSTR<=PROM(address);                    -- ������ �������            
         wait on CLK,RST,ADDRI,address ;
      end loop;
   end process;                
end PRAM_BEH;

