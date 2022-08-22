
library IEEE;
use IEEE.STD_LOGIC_1164.all, work. RISC_lib.all;
entity PORT0 is port(  CLK : in std_logic;
      RST : in std_logic;
      DATA_I : in WORD;  --���� ������
      ADDRD : in WORD;   --���� ������
      WE: in std_logic;      --���������� ������
      RE: in std_logic;       --���������� ������
      PORT0_I : in WORD;-- ���� �����
      RDY:out std_logic;     -- ���������� �����
      DATA_O : out WORD; --���� ������
      PORT0_O : out WORD ); --����� �����
end PORT0;

architecture PORT0_synt of PORT0 is
   signal port_I :WORD;
   signal oe:std_logic;--���������� ������ � DATA_O
   signal sel:std_logic; --�������� ������ 
begin 
   sel<= '1' when ADDRD=PORT0_ADDR else '0';           
   R_PORT0:process(CLK,RST)  --�������� �����
   begin                      
      if  RST='1' then
         port_I<=(others=>'0');   
         PORT0_O<=(others=>'0');  
         oe<='0';         
      elsif Rising_edge(CLK) then 
         port_I<=PORT0_I;             --������� �������� �����    
         oe<= RE and sel ;             -- ������� ���������� ������
         if WE='1' and sel='1'  then
            PORT0_O<=DATA_I;       --������� ��������� ����� 
         end if;                    
      end if;                 
   end process;
   DATA_O<=port_I when oe='1' else (others=>'Z');--������������� ����� 
   RDY<='H';
end PORT0_synt;

