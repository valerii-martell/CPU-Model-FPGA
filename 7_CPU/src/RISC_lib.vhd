library IEEE;
use IEEE.std_logic_1164.all; 
--pragma translate_off
use STD.textio.all,IEEE.std_logic_textio.all;
--pragma translate_on
package RISC_lib is            
   subtype TRIPLET is   std_logic_vector(2 downto 0);
   subtype NIBBLE is std_logic_vector(3 downto 0);
   subtype BYTE is std_logic_vector(7 downto 0);
   subtype WORD is std_logic_vector(15 downto 0);   
   constant \AND\:NIBBLE:="0000";    --     RD and RS -> RD
   constant \XOR\:NIBBLE:="0001";   --      RD xor RS -> RD
   constant \SRL\: NIBBLE:="0010";    --       '0' & RS(15..1) -> RD
   constant \SRA\: NIBBLE:="0011";    --      RS(15) & RS(15..1) -> RD
   constant ADD:  NIBBLE:="1000";      --         RD + RS -> RD
   constant SUB:  NIBBLE:="1001";     --     RD - RS -> RD
   constant ADDC:NIBBLE:="1010";    --    RD + RS +C -> RD
   constant SUBC:NIBBLE:="1011";     --  RD - RS - C -> RD
   constant CALL: NIBBLE:="0001";   --   ����� ������������ ��  {RS}
   constant RET:  NIBBLE:="0010";   --    ������� �� ������������
   constant RETI: NIBBLE:="0100";   --    ������� �� ������������ ����������   
   constant LJMP:NIBBLE:="1000";   --    �������� ������� ��  {RS}
   constant BRA:TRIPLET:= "001";   --   �������� ������� �� {PC}+Disp
   constant  LD:TRIPLET:=  "010";   --   �������� RD ������� ��  {RS}+Imm4
   constant SD:TRIPLET:=   "011";   --   ����������  �� RD  ��  {RS}+Imm4
   constant LL:TRIPLET:=    "100";   --   �������� Imm � ������� ���� RD 
   constant LH:TRIPLET:=   "101";   --   �������� Imm � ������� ���� RD
   constant ADDI:TRIPLET:="110";   --  ������ RS+Imm4 � RD 
   constant ALU:TRIPLET:=  "111";   --  ������ RS (Func) RD � RD      
   constant  JMP:TRIPLET:= "000";   --  ������� ��������
   constant JUMP:TRIPLET:="000";   --  ����������� �������
   constant EQ:TRIPLET:="001";    --    ��������� Y=0
   constant LT:TRIPLET:="010";     --    ��������� Y<0
   constant LE:TRIPLET:="011";     --    ��������� Y<=0
   constant AC:TRIPLET:="100";     --   ������� C=1
   constant OVF:TRIPLET:="101";   --   ������������    
   constant NOP:WORD:=X"0000";  --   ������� ���
   constant INIT_ADDR: WORD :=X"0020";   --��������� ����� ���������
   constant DATA_ADDRH:natural:=255;       --������� ������� ������ ������        
   constant INSTR_ADDRH:natural:=255;      --������� ������� ������ �������� 
   constant N_INTSRC:integer:=3;                --=����� ���������� ����������-1
   constant N_INTVEC:integer:=1;               -- =����������� ������� ����������-1     
   constant INT_NULL:std_logic_vector(12-(N_INTVEC+1) downto 0):=(others=>'0');
   constant PORT0_ADDR:WORD:=X"FFF8";   --����� �������� �����
   constant INTENA_ADDR:WORD:=X"FFFC"; --����� ��.  ���������� ����������
   type       MEM_ARR is array(natural range <>) of WORD;    
   subtype DMEM_ARR is MEM_ARR( 0 to DATA_ADDRH);
   subtype PMEM_ARR is MEM_ARR( 0 to INSTR_ADDRH);  
   constant PROG_FILE: string := "src\PRG.TXT" ;      --���� � ����������
   constant IDATA_FILE: string := "src\DATA.TXT" ;   --���� � �������� �������  
   constant ODATA_FILE: string := "src\DATA.RES" ;  --���� � ��������� �������
                                         --��������� �������� ���/��� mem �� ����� file_name
   procedure Load_F(file_name:in string; mem: out MEM_ARR);   
                                         --��������� ���������� ��� mem � ����� file_name
   procedure Store_F(file_name:in string; mem: in MEM_ARR); 
   shared variable end_simulation:boolean;    --����� �������������   
end package;  
--pragma translate_off
package body RISC_lib is
   procedure Load_F(file_name:in string; mem: out MEM_ARR) is
      file txt_file : text open READ_MODE is file_name;
      variable addr:natural;
      variable fline : line;
      variable val:WORD;
   begin
      Write( output, "������������� RAM..." ); --��������� �� �������
      for addr in mem'range loop   --���������� ������ �����������
         mem(addr) := (others=>'X');  
      end loop; 
      while not endfile(txt_file) loop
         Readline(txt_file, fline );--������ ������ �� �����
         Read (fline, addr);         --������ ������ �� ������
         Hread (fline, val);          --������ ������������������ �������� �� ������
         mem( addr ) :=val;
      end loop;
      Write( output, "������������� RAM ���������" );          
   end Load_F;        
   procedure Store_F(file_name:in string; mem: in MEM_ARR) is
      file txt_file : text open WRITE_MODE is file_name;
      variable fline : line;
      variable val:WORD;
   begin
      Write( output, "���������� RAM...." );          
      for addr in mem'range loop 
         val:=mem(addr);
         Write (fline, addr,right,4); --������ ����������� ������, ������������ �� 4 ����    
         Write(fline,"   ");              --������ �������� � ������
         Hwrite (fline, val);            --������ 16-�� �������� � ������
         Writeline(txt_file, fline );   --������  ������ � ����
      end loop;
      Write( output, "���������� RAM ��������o" );          
   end Store_F;        
end RISC_lib;
