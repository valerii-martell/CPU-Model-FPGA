

library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,IEEE.std_logic_arith.all;
use  work. RISC_lib.all;
entity INT_CNTRL is    port( CLK : in std_logic;
      RST : in std_logic;      
      INTCALL: in std_logic; --=1 при вызове ПП прерывания
      INTRET:in std_logic;   --=1 при RETI
      WE:in std_logic;         --запись  в intena
      ADDRD : in WORD;     --адрес intena     
      DATAI:in WORD;         --шина данных
      INTREQ : in std_logic_vector(N_INTSRC downto 0); --запросы на прерывание
      INTAFD : out std_logic; --требование прерывания
      INTVEC : out std_logic_vector(N_INTVEC downto 0));-- вектор прерывания
end INT_CNTRL;            

architecture INT_CNTRL_SYNT of INT_CNTRL is      
   signal intena:WORD;  --регистр маски        
   signal intreqd1,intreqd2,intreq_edge,intreqr:std_logic_vector(N_INTSRC downto 0); 
   signal intveci,intnum:std_logic_vector(N_INTVEC downto 0); 
   signal intreq_event,intbusy,intbusyd,intafdi:std_logic;
begin              
   R_INTENA:process(CLK,RST) begin  --регистр разрешения прерывания
      if RST='1'  then
         intena<=(others=>'0') ;
      elsif  Rising_edge(CLK) then
         if  ADDRD= INTENA_ADDR and WE='1' then
            intena<=DATAI;
         end if;
      end if;
   end process;   
   
   RR_INT :process(CLK,RST)   begin   --регистры прерывания
      if RST='1'   then
         intreqd1<=(others=>'0'); --первый уровень триггеров запроса прерывания 
         intreqd2<=(others=>'0'); --второй уровень триггеров запроса прерывания 
         intreqr<=(others=>'0');     --регистр фиксации запросов прерывания 
      elsif  Rising_edge(CLK)  then
         intreqd1<=INTREQ;       --запросы прерывания, задержанные на 1 и 2 такта
         intreqd2<=intreqd1; 
         for i in 0 to N_INTSRC loop       
            if ( intreqd1(i) and not  intreqd2(i)) ='1'  then  --фронт сигнала запроса
               intreqr(i)<='1'   ;         --фиксация запроса прерывания
            elsif i= Conv_Integer(intveci) and INTRET='1' then
               intreqr(i)<='0'   ;        --сброс запроса прерывания
            end if;                
         end loop;            
      end if;
   end process ;        
   
   PRIORITY:process(INTREQr ,intena) --приоритетный шифратор запроса прерывания          
      variable reqnum:natural;             
   begin 
      intreq_event<='0';
      intnum<=(others=>'1');
      for i in 0 to N_INTSRC loop                      --    i=0 - старший приоритет  
         if intreqr(i)='1' and intena(i)='1' then   
            intnum<=Conv_std_logic_vector(i,N_INTVEC+1);--номер запроса 
            intreq_event<='1';                                            --событие запроса
            exit;
         end if;                  
      end loop;              
   end process;     
   
   RTT_INTVEC:process (CLK,RST)
   begin    
      if  RST='1' then
         intveci<=(others=>'1') ;  --вектор прерывания
         intafdi<='0';                    --триггер требования прерывания
         intbusy<='0';                  --триггер занятости отработкой прерывания
         intbusyd<='0';               --триггер занятости отработкой прерывания, задержан
      elsif Rising_edge(CLK) then      
         intbusyd<=intbusy;           --задержка на такт состояния занятости
         if   intbusy='0' and intreq_event='1' and intafdi='0'  then
            intafdi<='1';    
         elsif  INTCALL='1' then    --был вызов ПП прерывания
            intafdi<='0';
            intbusy<='1';
         elsif  INTRET='1'  then     --был возрат из ПП прерывания
            intbusy<='0'; 
         end if;                                       
         if   (intbusy='0' and intreq_event='1'  and INTCALL='0') or
            (intbusy='0' and intbusyd='1') then     -- задний фронт    intbusy
            intveci<=intnum;                               --новый вектор прерывания
         end if;
      end if;        
   end process;                    
   INTVEC<=intveci;
   INTAFD<=intafdi;
end INT_CNTRL_SYNT;
