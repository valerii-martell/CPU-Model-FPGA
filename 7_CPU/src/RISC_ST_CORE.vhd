library IEEE;
use IEEE.std_logic_1164.all, work. RISC_lib.all; 
entity RISC_ST_CORE is   port(CLK : in std_logic;
      RST : in std_logic;
      ENA : in std_logic;         --���������� ������ � DRAM
      INSTR : in WORD;         --������� �� PRAM
      INTREQ : in std_logic_vector( N_INTSRC downto 0);--������� �� ����������
      DATAI : in WORD;          --����o� �� DRAM 
      ADDRI : out WORD;      --����� �������
      RE : out std_logic;         --������ ������ �� DRAM
      WE : out std_logic;        --������ ������ � DRAM
      DATAO : out WORD;     --����o� � DRAM
      ADDRD : out WORD );   --����� �������
end RISC_ST_CORE;                          

architecture RISC_SYNT of RISC_ST_CORE is     
   component ALU is port(CLK : in std_logic;
         RST : in std_logic;
         ENA : in std_logic;  
         CY:in std_logic;         --���� ��������   
         RSTD:in std_logic;
         RD : in WORD;         --������ �������
         RS : in WORD;         --������ �������
         INSTR : in WORD;    --�������
         DALU :  out WORD;     --���������
         CNVZ : out NIBBLE );     --������ ���������   
   end component;               
   component PC is  port( CLK : in std_logic;
         RST : in std_logic;
         ENA : in std_logic;
         INTAFD : in std_logic;            -- ���������� ����������
         INSTR : in WORD;                  --���� ������
         RS : in  WORD;                     --������� RS
         CNVZ : in NIBBLE;                 --������ �������
         INTVEC : in std_logic_vector(1 downto 0); --������ ����������     
         RSTD:buffer std_logic;
         CY : out std_logic;                --���� ��������
         INTCALL : out std_logic;       --���� ��������� ����������     
         INTRET: out std_logic;          --������������  INTAFD
         ADDRI : out WORD   );         --����� �������
   end component;
   component  RRAM is     port(CLK : in std_logic;
         RST : in std_logic;  
         RSTD:in std_logic;
         ENA : in std_logic;
         DALU : in WORD;                --������ �� ALU
         INSTR : in WORD;               -- �������
         DATAI : in WORD;              -- ������ �� DRAM
         RE:out std_logic;                --������ DRAM
         WE:out  std_logic;              --������ DRAM
         RS : out WORD;                 --������� RS
         RD : out WORD;                 --������� RD
         ADDRD : out WORD;            --����� DRAM
         DATAO : out WORD);           --������ � DRAM
   end component;    
   component  INT_CNTRL is  port (CLK : in std_logic;
         RST : in std_logic;      
         INTCALL: in std_logic; --=1 ��� ������ �� ����������
         INTRET:in std_logic; --=1 ��� RETI
         WE:in std_logic;         --������  � intmask
         ADDRD : in WORD;       --����� intmask      
         DATAI:in WORD;
         INTREQ : in std_logic_vector(N_INTSRC downto 0); --������� �� ����������
         INTAFD : out std_logic; --���������� ����������
         INTVEC : out std_logic_vector(N_INTVEC downto 0));-- ������ ����������
   end component;   
   signal cy,rstd: std_logic;
   signal intafd, intcall, intret,wei,ENAi :std_logic;
   signal rs,rd,dataoi:WORD;    
   signal dalu,addrdi:WORD;
   signal cnvz:NIBBLE;
   signal intvec:std_logic_vector(N_INTVEC downto 0);
begin                                   
   ENAi<=To_X01(ENA);                    --���������� 'H','L' � 1,0

   U_RAM: RRAM    port map(CLK=>CLK,  -- ���
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
   
   U_PC:PC port map( CLK=>CLK,   --���� �������� ������
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
   
   U_ALU:ALU  port map(CLK =>CLK,    -- ���
      RST=>rst,
      ENA =>ENAi,  
      CY =>cy,    
      RSTD=>rstd,
      RD => rd,
      RS =>rs,
      INSTR =>INSTR,
      DALU =>dalu,
      CNVZ =>cnvz   );           
   
   U_INT: INT_CNTRL port map( CLK=>CLK, --���� ���������� ������������
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

