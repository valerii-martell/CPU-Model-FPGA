library IEEE;
use IEEE.std_logic_1164.all,work. RISC_lib.all;
entity RISC_CPU is   port(CLK : in std_logic;  --синхровход
      RST : in  std_logic;                                  --сброс
      INTREQ: in std_logic_vector(3 downto 0); --запросы прерывания
      PORT0_I: in std_logic_vector(15 downto 0);--входной порт
      PORT0_O: out std_logic_vector(15 downto 0));--выходной порт
end RISC_CPU;                                                   

architecture RISC_CPU_SYNT of RISC_CPU is    
   component  RISC_ST_CORE is   port(CLK :in    std_logic;
         RST : in  std_logic;
         ENA : in std_logic; --готовность данных в DRAM
         INSTR : in WORD;         --команда из PROM
         INTREQ : in std_logic_vector( N_INTSRC downto 0);--запросы на прерывание
         DATAI : in WORD;          --даннoе из DRAM 
         ADDRI : out WORD;      --адрес команды
         RE : out std_logic;   --сигнал чтения из DRAM
         WE : out std_logic;  --сигнал записи в DRAM
         DATAO : out WORD;     --даннoе в DRAM
         ADDRD : out WORD );   --адрес данного
   end component;
   component  DRAM is port(CLK :in    std_logic;
         RST : in std_logic;  
         RE: in std_logic;
         WE: in std_logic;
         ADDRD : in WORD; 
         DATAI: in WORD; 
         RDY: out std_logic;
         DATAO : out WORD   );
   end component ;
   component PRAM is  port( CLK :in    std_logic;
         RST : in std_logic;      
         ENA: in std_logic;
         ADDRI : in WORD;   
         INSTR : out WORD    );
   end component;                      
   component PORT0 is port(  CLK :in std_logic;
         RST : in std_logic;
         DATA_I : in WORD;  --шина данных
         ADDRD : in WORD;   --Шина адреса
         WE: in std_logic;      --разрешение записи
         RE: in std_logic;       --разрешение чтения
         RDY:out std_logic;    -- готовность порта
         PORT0_I : in WORD; -- Вход порта
         DATA_O : out WORD;    --шина данных
         PORT0_O : out WORD ); --Выход порта
   end component;      
   signal rdy,re,we,ena:std_logic;
   signal instr:WORD;
   signal datai,datao:WORD;
   signal addri:WORD;
   signal addrd:WORD;
   
begin               
 U_CORE:  RISC_ST_CORE     port map( CLK =>CLK,
      RST=>RST,
      ENA =>rdy,
      INSTR =>instr,
      INTREQ =>INTREQ,
      DATAI =>datai, 
      ADDRI =>addri,
      RE =>re,
      WE =>we,
      DATAO =>datao,
      ADDRD =>addrd );          
   U_DRAM: DRAM port map(CLK=>CLK,
      RST=>RST,  
      RE=>RE,
      WE=>WE,
      ADDRD =>addrd, 
      DATAI=>datao, 
      RDY=>rdy,
      DATAO=>datai   );   
   U_PRAM: PRAM port map( CLK =>CLK,
      RST=>RST,   
      ENA=>rdy,
      ADDRI =>addri,   
      INSTR =>instr);
   U_PORT0:PORT0 port map( CLK=>CLK,
      RST =>RST,
      DATA_I =>datao,
      ADDRD =>addrd,
      WE=>we,
      RE=>re,
      RDY=>rdy,
      PORT0_I=>PORT0_I,
      DATA_O =>datai,
      PORT0_O =>PORT0_O);          
end RISC_CPU_SYNT;
