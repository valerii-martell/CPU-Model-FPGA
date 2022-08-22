library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,work. RISC_lib.all;       
entity DRAM is   
   port(CLK : in std_logic;
      RST : in std_logic;    
      RE: in std_logic;             --���������� ������ 
      WE: in std_logic;            --���������� ������
      ADDRD : in WORD;        --����� �������
      DATAI: in WORD;          --������� ������
      RDY:out std_logic;         -- ���������� ������
      DATAO : out WORD   ); --�������� ������
end DRAM;                    
  
architecture DRAM_BEH of DRAM is       
   signal address : natural;          
   signal dataoi,dataoii:WORD; 
    signal rdyi:std_logic;
   begin                          
   RAMD: process
      variable DRAM:DMEM_ARR; 
      variable addr:natural;
   begin
      Load_F(IDATA_FILE,DRAM);      --�������� ������ �� �����         
      loop     
         addr:= Conv_Integer(To_X01(ADDRD));
         if  addr>DATA_ADDRH  then   -- ����������� ��������� �������
            addr:=0;
         end if;            
         if RST='1'  then                     -- ������� ������
            address<=0 ;
         elsif 
            Rising_edge(CLK) then
            address<=addr;          
            if ( WE='1' ) then
               DRAM(addr):=DATAI; 
            end if;            
         end if;            
         dataoi<=DRAM(address);  
         if  end_simulation  then -- ���������� ��������� ������ � ����� �������������
            Store_F(ODATA_FILE,DRAM);  
                wait;
         end if;            
         wait on CLK,RST,ADDRD ;
      end loop;
   end process;                                   
                   -- ������ ������������ �������, ���� ����� ������ � ��������
   DATAOii<=dataoi when address<=DATA_ADDRH else (others=>'Z');  
   RDY<='H'; 
end DRAM_BEH;

