
library IEEE;
use IEEE.STD_LOGIC_1164.all, work. RISC_lib.all;
entity PORT0 is port(  CLK : in std_logic;
      RST : in std_logic;
      DATA_I : in WORD;  --шина данных
      ADDRD : in WORD;   --Шина адреса
      WE: in std_logic;      --разрешение записи
      RE: in std_logic;       --разрешение чтения
      PORT0_I : in WORD;-- Вход порта
      RDY:out std_logic;     -- готовность порта
      DATA_O : out WORD; --шина данных
      PORT0_O : out WORD ); --Выход порта
end PORT0;

architecture PORT0_synt of PORT0 is
   signal port_I :WORD;
   signal oe:std_logic;--разрешение выдачи в DATA_O
   signal sel:std_logic; --селектор адреса 
begin 
   sel<= '1' when ADDRD=PORT0_ADDR else '0';           
   R_PORT0:process(CLK,RST)  --регистры порта
   begin                      
      if  RST='1' then
         port_I<=(others=>'0');   
         PORT0_O<=(others=>'0');  
         oe<='0';         
      elsif Rising_edge(CLK) then 
         port_I<=PORT0_I;             --регистр входного порта    
         oe<= RE and sel ;             -- триггер разрешения выдачи
         if WE='1' and sel='1'  then
            PORT0_O<=DATA_I;       --регистр выходного порта 
         end if;                    
      end if;                 
   end process;
   DATA_O<=port_I when oe='1' else (others=>'Z');--тристабильный буфер 
   RDY<='H';
end PORT0_synt;

