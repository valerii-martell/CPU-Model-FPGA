library IEEE;
use IEEE.std_logic_1164.all,IEEE.std_logic_unsigned.all,IEEE.std_logic_arith.all;
use work. RISC_lib.all;
entity RRAM is   port(CLK : in std_logic;
      RST : in std_logic;    
      RSTD:in std_logic;
      ENA : in std_logic; --���������� ������ � ��.
      DALU : in WORD; --������ �� ALU
      INSTR : in WORD; -- �������
      DATAI : in WORD; -- ������ �� DRAM
      RE: out  std_logic; --������ DRAM
      WE: out  std_logic;--������ DRAM
      RS : out WORD;   --������� RS
      RD : out WORD;   --������� RD
      ADDRD : out WORD; --����� DRAM
      DATAO : out WORD); --������ � DRAM
end RRAM;
architecture RRAM_SYNT of RRAM is   
   signal data_w: WORD;
   signal INSTR_R: WORD;     
   signal rsi,rdi : WORD;    
   signal wei,rei,red:std_logic;                        
   signal as : NIBBLE;              --����� �������� RS
   signal ad,add : NIBBLE;       -- ����� �������� RD
   signal cop:TRIPLET;            -- ��� ��������
   signal Imm4:NIBBLE;            -- 4- ������� ���������������� ������� 
   signal Imm : BYTE;             -- 8- ������� ���������������� �������
begin
   R_INSTR:process(CLK,RST)   --������� �������
   begin
      if RST='1' then
         INSTR_R<=NOP;
      elsif  Rising_edge(CLK)  then  
         if  ENA='1' and RSTD= '0' then
            INSTR_R<=INSTR;   
         end if;
      end if;          
   end process;         
   
   cop<=  INSTR_R(14 downto 12);     --��������� ����� �������                              
   Imm<= INSTR_R(7 downto 0);
   Imm4<=INSTR_R(3 downto 0);
   as<=  INSTR_R(7 downto 4);           --a���� RS
                                 -- ������������� ������ RD
   MXA:ad<= add when REd='1' else --����� ������ ���������� �� DRAM
             INSTR_R(11 downto 8);     -- ����� �� �������
                                  --������� ��������������   �������
   MXL: data_w(7 downto 0)<=DATAI(7 downto 0) when REd='1' else
                                       Imm when cop=LL else
                                       rdi(7 downto 0) when cop=LH else
                                       DALU(7 downto 0); 
   MXH: data_w(15 downto 8)<=DATAI(15 downto 8) when REd='1' else
                                       rdi(15 downto 8)when cop=LL else
                                       Imm when cop=LH else
                                       DALU(15 downto 8);     
   wei<=ENA when (REd='1' or cop=LL or cop = LH or cop=ADDI or cop = ALU) 
                              and (RSTD='0') else '0' ;                  --������ ������ � RRAM

   R_RAM:process(CLK,as,ad)              --����������� ���, ������������� �� RAM16X1D 
      type ARR is array (0 to 15) of std_logic_vector(15 downto 0);
      variable RAM:ARR:=(others=>X"0000");
   begin
      RSi<= RAM(Conv_Integer(as));            --������ RS
      RDi<= RAM(Conv_Integer(ad));           --������ RD
      if  Rising_edge(CLK) then      
         if wei ='1'  then
            RAM(Conv_Integer(ad)):= data_w;  --������ �  RD
         end if;   
      end if;  
   end process;                      
   RS <=RSi;
   RD <=RDi when cop=ALU else  --�������� �������������
             SXT(Imm4,16);           --���������������� �������, ����������� �� 16 ����.
   ADDRD<=RSi + SXT(Imm4,16);   --����� ��� DRAM  
   DATAO<=RDi;                            --������ ��� DRAM
   
   TT_RW:process(CLK,RST,cop,ENA)  --������� ������-������ DRAM .
      --DRAM ���������� ������ � ����� �� ������ �L�, ������ ���������� �
--��������� ����� � ������� ���������� �� red. ���� ��������� �������������, 
--�� DRAM ������ ������ RDY=0 ��� ���������� ����
   begin           
      rei<='0';   
      WE<='0';
      if cop=LD and ENA='1'  then
         rei<='1';                 --���������� ������
      end if;         
      if   cop=SD  and ENA='1' then
         WE<='1';               --���������� ������
      end if;       
      if  RST='1' then       -- ������� red , ������� add
         red<='0';      
         add<="0000";
      elsif  Rising_edge(CLK)  then  
         if  RSTD= '0' then      
            red<=rei;      
            add<=INSTR_R(11 downto 8);    --����� ������ ���������� �� DRAM
         end if;
      end if;
   end process; 
   RE<=rei;
end RRAM_SYNT;

