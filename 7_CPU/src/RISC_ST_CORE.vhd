library IEEE;
use IEEE.std_logic_1164.all, work. RISC_lib.all; 
entity RISC_ST_CORE is   port(CLK : in std_logic;
      RST : in std_logic;
      ENA : in std_logic;         --готовность данных в DRAM
      INSTR : in WORD;         --команда из PRAM
      INTREQ : in std_logic_vector( N_INTSRC downto 0);--запросы на прерывание
      DATAI : in WORD;          --даннoе из DRAM 
      ADDRI : out WORD;      --адрес команды
      RE : out std_logic;         --сигнал чтения из DRAM
      WE : out std_logic;        --сигнал записи в DRAM
      DATAO : out WORD;     --даннoе в DRAM
      ADDRD : out WORD );   --адрес данного
end RISC_ST_CORE;                          

architecture RISC_SYNT of RISC_ST_CORE is     
   component ALU is port(CLK : in std_logic;
         RST : in std_logic;
         ENA : in std_logic;  
         CY:in std_logic;         --флаг переноса   
         RSTD:in std_logic;
         RD : in WORD;         --первый операнд
         RS : in WORD;         --второй операнд
         INSTR : in WORD;    --команда
         DALU :  out WORD;     --результат
         CNVZ : out NIBBLE );     --вектор состояний   
   end component;               
   component PC is  port( CLK : in std_logic;
         RST : in std_logic;
         ENA : in std_logic;
         INTAFD : in std_logic;            -- требование прерывания
         INSTR : in WORD;                  --шина команд
         RS : in  WORD;                     --операнд RS
         CNVZ : in NIBBLE;                 --вектор условий
         INTVEC : in std_logic_vector(1 downto 0); --вектор прерывания     
         RSTD:buffer std_logic;
         CY : out std_logic;                --флаг переноса
         INTCALL : out std_logic;       --флаг отработки прерывания     
         INTRET: out std_logic;          --квитирование  INTAFD
         ADDRI : out WORD   );         --Адрес команды
   end component;
   component  RRAM is     port(CLK : in std_logic;
         RST : in std_logic;  
         RSTD:in std_logic;
         ENA : in std_logic;
         DALU : in WORD;                --данное из ALU
         INSTR : in WORD;               -- команда
         DATAI : in WORD;              -- данное из DRAM
         RE:out std_logic;                --чтение DRAM
         WE:out  std_logic;              --запись DRAM
         RS : out WORD;                 --операнд RS
         RD : out WORD;                 --операнд RD
         ADDRD : out WORD;            --адрес DRAM
         DATAO : out WORD);           --данное в DRAM
   end component;    
   component  INT_CNTRL is  port (CLK : in std_logic;
         RST : in std_logic;      
         INTCALL: in std_logic; --=1 при вызове ПП прерывания
         INTRET:in std_logic; --=1 при RETI
         WE:in std_logic;         --запись  в intmask
         ADDRD : in WORD;       --адрес intmask      
         DATAI:in WORD;
         INTREQ : in std_logic_vector(N_INTSRC downto 0); --запросы на прерывание
         INTAFD : out std_logic; --требование прерывания
         INTVEC : out std_logic_vector(N_INTVEC downto 0));-- вектор прерывания
   end component;   
   signal cy,rstd: std_logic;
   signal intafd, intcall, intret,wei,ENAi :std_logic;
   signal rs,rd,dataoi:WORD;    
   signal dalu,addrdi:WORD;
   signal cnvz:NIBBLE;
   signal intvec:std_logic_vector(N_INTVEC downto 0);
begin                                   
   ENAi<=To_X01(ENA);                    --приведение 'H','L' к 1,0

   U_RAM: RRAM    port map(CLK=>CLK,  -- ОЗУ
      RST=>RST,    
      RSTD=>rstd,
      ENA =>ENAi,
      DALU =>dalu,
      INSTR =>INSTR,
      DATAI=>DATAI,
      RE=>RE,
      WE=>WEi,
      RS =>rs,
      RD =>rd,
      ADDRD =>ADDRDi,
      DATAO =>DATAOi) ;
   
   U_PC:PC port map( CLK=>CLK,   --блок счетчика команд
      RST=>RST,
      ENA =>ENAi,
      INTAFD=>intafd,
      INSTR =>INSTR,
      RS =>rs,   
      RSTD=>rstd,
      CNVZ =>cnvz,
      INTVEC =>intvec,
      CY =>cy,
      INTCALL =>intcall,    
      INTRET=>intret,
      ADDRI =>ADDRI   ); 
   
   U_ALU:ALU  port map(CLK =>CLK,    -- АЛУ
      RST=>rst,
      ENA =>ENAi,  
      CY =>cy,    
      RSTD=>rstd,
      RD => rd,
      RS =>rs,
      INSTR =>INSTR,
      DALU =>dalu,
      CNVZ =>cnvz   );           
   
   U_INT: INT_CNTRL port map( CLK=>CLK, --блок управления прерываниями
      RST=>RST,      
      WE => WEi,
      ADDRD=>addrdi,  
      DATAI =>dataoi,
      INTCALL=>intcall,
      INTRET=>intret,
      INTREQ=>INTREQ,
      INTAFD=>intafd,
      INTVEC=>intvec);   
   
   WE<=WEi;
   ADDRD<=addrdi; 
   DATAO<=dataoi;
end RISC_SYNT;

