library IEEE;
use IEEE.std_logic_1164.all,IEEE.std_logic_signed.all, work. RISC_lib.all;
entity ALU is
   port(CLK : in std_logic;
      RST : in std_logic;
      ENA : in std_logic;         --разрешение работы 
      CY :   in std_logic;         --флаг переноса 
      RSTD:in std_logic;         --сброс, синхронизированный по CLK
      RD :   in WORD;            --первый операнд
      RS :   in WORD;            --второй операнд
      INSTR : in WORD;         --команда
      DALU : out WORD;        --результат
      CNVZ : out NIBBLE   );  --вектор условий        
end ALU;
architecture ALU_SYNT of ALU is        
   signal INSTR_R:WORD;
   signal  func :NIBBLE;  
   signal cop:TRIPLET;
   signal c:std_logic;  --перенос -+1
begin                                                                  
   R_INSTR:process(CLK,RST)  --регистр команды
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
      func <= INSTR_R(3 downto 0);     --функция  АЛУ
      if INSTR_R(12)='0' then              --приведение операции ADDI к операции ADD
         func(3)<='1'; func(0)<='0';
      end if;
       if func(1)='0' or INSTR_R(12)='0' then  --коррекция CY с учетом знака сложения
         c<=func(0);                             --функции ADD, SUB
      else 
         c<=CY xor func(0);                 --функции ADDC,SUBC,ADDI
      end if;
      b:= RD(15) & RD & c  ;       --присоединение бита переноса
      a:= RS(15) & RS & '1';   
      case func is                       --логические функции, сдвиг, вычитание и сложение
         when \AND\=>        y:= b and a;  
         when \XOR\=>        y:= b xor a;
         when \SRL\=>         y:= "00" & a (15 downto 0);
         when \SRA\=>         y:= '0' & a(15) & a (15 downto 0);  
         when SUB | SUBC=> y:=b - a;
         when others=>       y:=b + a;
      end case;        
      carry:=y(17);                                                   --  флаг переноса
      neg:=y(16);                                                     --  флаг отрицательного
      overf:=y(17) xor y(16) xor RS(15) xor RD(15);  --  флаг переполнения
      if   y(16 downto 1)=X"0000" then
         zero:='1';                                                      --  флаг нулевого результата
      else
         zero:= '0' ; 
      end if;   
      CNVZ<=(carry,neg,overf,zero);   --вектор флагов условий    
      DALU<=y(16 downto 1);           --результат  АЛУ       
   end process;
end ALU_SYNT;

