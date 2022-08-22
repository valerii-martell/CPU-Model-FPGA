library IEEE;
use IEEE.std_logic_1164.all,IEEE.std_logic_signed.all, work. RISC_lib.all;
entity ALU is
   port(CLK : in std_logic;
      RST : in std_logic;
      ENA : in std_logic;         --���������� ������ 
      CY :   in std_logic;         --���� �������� 
      RSTD:in std_logic;         --�����, ������������������ �� CLK
      RD :   in WORD;            --������ �������
      RS :   in WORD;            --������ �������
      INSTR : in WORD;         --�������
      DALU : out WORD;        --���������
      CNVZ : out NIBBLE   );  --������ �������        
end ALU;
architecture ALU_SYNT of ALU is        
   signal INSTR_R:WORD;
   signal  func :NIBBLE;  
   signal cop:TRIPLET;
   signal c:std_logic;  --������� -+1
begin                                                                  
   R_INSTR:process(CLK,RST)  --������� �������
   begin
      if RST='1' then
         INSTR_R<=NOP;
      elsif  Rising_edge(CLK)  then  
         if  ENA='1'  and RSTD='0' then
            INSTR_R<=INSTR;   
         end if;
      end if;          
   end process;       
   
ALU_2:process(RD,RS,func,INSTR_R, CY,c)                                       
      variable y, a,b: std_logic_vector(17 downto 0); 
      variable carry,neg,overf,zero:std_logic;
   begin   
      func <= INSTR_R(3 downto 0);     --�������  ���
      if INSTR_R(12)='0' then              --���������� �������� ADDI � �������� ADD
         func(3)<='1'; func(0)<='0';
      end if;
       if func(1)='0' or INSTR_R(12)='0' then  --��������� CY � ������ ����� ��������
         c<=func(0);                             --������� ADD, SUB
      else 
         c<=CY xor func(0);                 --������� ADDC,SUBC,ADDI
      end if;
      b:= RD(15) & RD & c  ;       --������������� ���� ��������
      a:= RS(15) & RS & '1';   
      case func is                       --���������� �������, �����, ��������� � ��������
         when \AND\=>        y:= b and a;  
         when \XOR\=>        y:= b xor a;
         when \SRL\=>         y:= "00" & a (15 downto 0);
         when \SRA\=>         y:= '0' & a(15) & a (15 downto 0);  
         when SUB | SUBC=> y:=b - a;
         when others=>       y:=b + a;
      end case;        
      carry:=y(17);                                                   --  ���� ��������
      neg:=y(16);                                                     --  ���� ��������������
      overf:=y(17) xor y(16) xor RS(15) xor RD(15);  --  ���� ������������
      if   y(16 downto 1)=X"0000" then
         zero:='1';                                                      --  ���� �������� ����������
      else
         zero:= '0' ; 
      end if;   
      CNVZ<=(carry,neg,overf,zero);   --������ ������ �������    
      DALU<=y(16 downto 1);           --���������  ���       
   end process;
end ALU_SYNT;

