library IEEE;
use IEEE.std_logic_1164.all,work. RISC_lib.all;
entity RISC_CPU is   port(CLK : in std_logic;  --����������
      RST : in  std_logic;                                  --�����
      INTREQ: in std_logic_vector(3 downto 0); --������� ����������
      PORT0_I: in std_logic_vector(15 downto 0);--������� ����
      PORT0_O: out std_logic_vector(15 downto 0));--�������� ����
end RISC_CPU;                                                   

architecture RISC_CPU_SYNT of RISC_CPU is    
   component  RISC_ST_CORE is   port(CLK :in    std_logic;
         RST : in  std_logic;
         ENA : in std_logic; --���������� ������ � DRAM
         INSTR : in WORD;         --������� �� PROM
         INTREQ : in std_logic_vector( N_INTSRC downto 0);--������� �� ����������
         DATAI : in WORD;          --����o� �� DRAM 
         ADDRI : out WORD;      --����� �������
         RE : out std_logic;   --������ ������ �� DRAM
         WE : out std_logic;  --������ ������ � DRAM
         DATAO : out WORD;     --����o� � DRAM
         ADDRD : out WORD );   --����� �������
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
         DATA_I : in WORD;  --���� ������
         ADDRD : in WORD;   --���� ������
         WE: in std_logic;      --���������� ������
         RE: in std_logic;       --���������� ������
         RDY:out std_logic;    -- ���������� �����
         PORT0_I : in WORD; -- ���� �����
         DATA_O : out WORD;    --���� ������
         PORT0_O : out WORD ); --����� �����
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
