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
   constant CALL: NIBBLE:="0001";   --   Вызов подпрограммы по  {RS}
   constant RET:  NIBBLE:="0010";   --    Возврат из подпрограммы
   constant RETI: NIBBLE:="0100";   --    Возврат из подпрограммы прерывания   
   constant LJMP:NIBBLE:="1000";   --    Условный переход по  {RS}
   constant BRA:TRIPLET:= "001";   --   Условный переход по {PC}+Disp
   constant  LD:TRIPLET:=  "010";   --   Загрузка RD данного по  {RS}+Imm4
   constant SD:TRIPLET:=   "011";   --   Сохранение  из RD  по  {RS}+Imm4
   constant LL:TRIPLET:=    "100";   --   Загрузка Imm в младший байт RD 
   constant LH:TRIPLET:=   "101";   --   Загрузка Imm в старший байт RD
   constant ADDI:TRIPLET:="110";   --  Запись RS+Imm4 в RD 
   constant ALU:TRIPLET:=  "111";   --  Запись RS (Func) RD в RD      
   constant  JMP:TRIPLET:= "000";   --  Команда перехода
   constant JUMP:TRIPLET:="000";   --  Безусловный переход
   constant EQ:TRIPLET:="001";    --    Результат Y=0
   constant LT:TRIPLET:="010";     --    Результат Y<0
   constant LE:TRIPLET:="011";     --    Результат Y<=0
   constant AC:TRIPLET:="100";     --   Перенос C=1
   constant OVF:TRIPLET:="101";   --   Переполнение    
   constant NOP:WORD:=X"0000";  --   команда НОП
   constant INIT_ADDR: WORD :=X"0020";   --Начальный адрес программы
   constant DATA_ADDRH:natural:=255;       --Верхняя граница памяти данных        
   constant INSTR_ADDRH:natural:=255;      --Верхняя граница памяти программ 
   constant N_INTSRC:integer:=3;                --=число источников прерывания-1
   constant N_INTVEC:integer:=1;               -- =разрядность вектора прерываний-1     
   constant INT_NULL:std_logic_vector(12-(N_INTVEC+1) downto 0):=(others=>'0');
   constant PORT0_ADDR:WORD:=X"FFF8";   --адрес регистра порта
   constant INTENA_ADDR:WORD:=X"FFFC"; --адрес рг.  разрешения прерывания
   type       MEM_ARR is array(natural range <>) of WORD;    
   subtype DMEM_ARR is MEM_ARR( 0 to DATA_ADDRH);
   subtype PMEM_ARR is MEM_ARR( 0 to INSTR_ADDRH);  
   constant PROG_FILE: string := "src\PRG.TXT" ;      --файл с программой
   constant IDATA_FILE: string := "src\DATA.TXT" ;   --файл с входными данными  
   constant ODATA_FILE: string := "src\DATA.RES" ;  --файл с выходными данными
                                         --процедура загрузки ОЗУ/ПЗУ mem из файла file_name
   procedure Load_F(file_name:in string; mem: out MEM_ARR);   
                                         --процедура сохранения ОЗУ mem в файле file_name
   procedure Store_F(file_name:in string; mem: in MEM_ARR); 
   shared variable end_simulation:boolean;    --конец моделирования   
end package;  
--pragma translate_off
package body RISC_lib is
   procedure Load_F(file_name:in string; mem: out MEM_ARR) is
      file txt_file : text open READ_MODE is file_name;
      variable addr:natural;
      variable fline : line;
      variable val:WORD;
   begin
      Write( output, "Инициализация RAM..." ); --сообщение на консоль
      for addr in mem'range loop   --заполнение памяти неизвестным
         mem(addr) := (others=>'X');  
      end loop; 
      while not endfile(txt_file) loop
         Readline(txt_file, fline );--чтение строки из файла
         Read (fline, addr);         --чтение адреса из строки
         Hread (fline, val);          --чтение шестнадцатиричного значения из строки
         mem( addr ) :=val;
      end loop;
      Write( output, "Инициализация RAM завершена" );          
   end Load_F;        
   procedure Store_F(file_name:in string; mem: in MEM_ARR) is
      file txt_file : text open WRITE_MODE is file_name;
      variable fline : line;
      variable val:WORD;
   begin
      Write( output, "Сохранение RAM...." );          
      for addr in mem'range loop 
         val:=mem(addr);
         Write (fline, addr,right,4); --запись десятичного адреса, выравненного до 4 цифр    
         Write(fline,"   ");              --запись пробелов в строку
         Hwrite (fline, val);            --запись 16-го значения в строку
         Writeline(txt_file, fline );   --запись  строки в файл
      end loop;
      Write( output, "Сохранение RAM завершенo" );          
   end Store_F;        
end RISC_lib;
