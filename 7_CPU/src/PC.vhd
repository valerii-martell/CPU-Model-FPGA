library IEEE;   
use IEEE.std_logic_1164.all, IEEE.std_logic_unsigned.all, IEEE.std_logic_arith.all;  
use work. RISC_lib.all;
entity PC is   port( CLK : in std_logic;
		RST : in std_logic;
		ENA : in std_logic;                  --разрешение работы
		INTAFD : in std_logic;             -- требование прерывания
		INSTR : in WORD;                  --шина команд
		RS : in  WORD;                      --операнд RS из RRAM
		CNVZ : in NIBBLE;                  --вектор условий из АЛУ
		INTVEC : in std_logic_vector(N_INTVEC downto 0); --вектор прерывания
		CY : out std_logic;                  --флаг переноса   в АЛУ      
		RSTD:buffer std_logic;           --синхронизированный RST
		INTCALL : out std_logic;         --флаг вызова ПП отработки прерывания     
		INTRET: out std_logic;            -- флаг исполнения команды RETI
		ADDRI : out WORD   );           -- Адрес команды
end PC;

architecture PC_SYNT of PC is       
	signal INSTR_R: WORD;    --регистр команды   
	signal cop:TRIPLET;          --код операции
	signal conds : TRIPLET;     --код условия 
	signal neg_cond:std_logic;--инверсия условия
	signal name:NIBBLE;         --код операции перехода
	signal disp: BYTE;             --смещение адреса
	signal pc,pci: WORD;                    --счетчик команд
	signal pcplus1:WORD;       --счетчик команд + 1
	signal int_vect:WORD;       --адрес ПП прерывания           
	signal jcond,jcondu:std_logic; -- условие перехода     
	signal  carry,neg,overf,zero:std_logic;  --биты условий        
	signal stack_i,stack_o:std_logic_vector(19 downto 0);--вход-выход стека        
	signal sp,spcall,spret:NIBBLE;  --указатель стека
	signal wstack:std_logic;      --запись в стек
	signal CNVZi:NIBBLE;        --вектор условий
	signal no_int:std_logic;     --запрет прерывания в данной команде
begin              
	T_RST:process(CLK,RST)   --Триггер синхронизации RST
	begin
		if  RST='1'  then
			RSTD<='1';     
		elsif Rising_edge(CLK) then
			RSTD<='0';
		end if;        
	end process;
	
	R_INSTR:process(CLK,RST)   --Регистр команды
	begin
		if RST='1' then
			INSTR_R<=NOP;
		elsif  Rising_edge(CLK)  then  
			if  ENA='1'  and RSTD= '0' then
				INSTR_R<=INSTR;   
			end if;
		end if;          
	end process;                               
	--Выделение полей команды
	no_int<=  INSTR_R(15);                --запрет прерываний
	cop<=  INSTR_R(14 downto 12);  --код операции
	conds<=INSTR_R(11 downto 9);  --код условия перехода 
	neg_cond<=INSTR_R(8);              --инверсия условия перехода
	name<= INSTR_R(3 downto 0);  -- имя команды перехода
	disp<=  INSTR_R(7 downto 0);   --смещение адреса
	int_vect<=  INT_NULL & INTVEC & "000"; --на 1 ПП прерывания -до 8 команд
	(carry,neg,overf,zero)<=CNVZi;            --вектор условий   перехода                   
	
	MX_COND:  with conds select          --Мультиплексор условия перехода
	jcondu<= '1'  when JUMP,
	zero when EQ,
	carry xor neg when LT,
	zero or carry when LE, 
	overf when OVF ,
	carry when others;
	jcond<=jcondu xnor neg_cond;  -- бит условия перехода
	--Регистр - счетчик команд
	R_PC:process(CLK,RST,RSTD,int_vect,cop,name,no_int,intafd,jcond,pc,
		disp,RS,stack_o,pcplus1,pci)  
	begin                                           
		pcplus1<=pc+1;      -- инкремент адреса 
		pci<=pcplus1;            --следующий адрес команды   при остальных условиях    
		if  INTAFD='1' and no_int='0'  then   --переход при прерывании
			pci<=int_vect;
		elsif  jcond='1' then          -- переход по условию перехода - истинно
			if cop=BRA then             -- если условный переход на РС+смещение
				pci<= pc+ SXT(disp,16);
			elsif cop=JMP then        -- если условный переход на абсолютный адес
				if name=LJMP or name=CALL  then
					pci<= RS;                 -- если длинный условный переход или вызов ПП
				else 
					pci<= stack_o(15 downto 0); -- если возврат из ПП
				end if;  
			end if;
		elsif RSTD='1' then    
			pci<=INIT_ADDR;          --адрес после синхронизированного сброса 
		end if;  
		if RST='1' then
			pc<=INIT_ADDR;                           --адрес после сброса 
		elsif  Rising_edge(CLK)  then  
			if  ENA='1'  then      
				pc<=   pci;                                --регистр-счетчик адреса               
			end if;
		end if;
	end process;             
	
	R_CNVZ:process(CLK,RST)   --Регистр cocтояния флагов
	begin
		if RST='1' then
			CNVZi<="0000";
		elsif  Rising_edge(CLK)  then  
			if ENA='1' and RSTD='0' then
				if  jcond='1' and cop=JMP and ((name = RET)or(name = RETI)) then
					CNVZi<=stack_o(19 downto 16);   --загрузка из стека при возврате из ПП
				else
					CNVZi<=CNVZ;                            -- запись флагов из АЛУ
				end if;
			end if;
		end if;          
	end process;     
	
	stack_i<=CNVZ & pcplus1;   --состояние в стек
	RAM_STACK:process(CLK,sp)                  -- ОЗУ стека, синтезируется на RAM16X1S 
		type ARR is array (0 to 15) of std_logic_vector(19 downto 0);
		variable RAM:ARR:=(others=>X"00000");
	begin
		stack_o<= RAM(Conv_Integer(sp));    -- чтение стека
		if  Rising_edge(CLK)  then      
			if wstack ='1' then
				RAM(Conv_Integer(sp)):= stack_i; --запись в стек
			end if;   
		end if;  
	end process;                 
	
	TTR_SP:process(CLK,RST)                  --Указатели стека и триггеры флагов
	begin 
		if  RST='1'  then
			spcall<= "0000"; --указатель стека для вызова ПП  
			spret<= "1111"; --указатель стека для возврата из ПП, на 1 меньше, чем spcall    
			INTRET<='0';     --флаг исполнения команды RETI
		elsif  Rising_edge(CLK) then      
			if ENA='1' then                
				INTRET<='0';          
				if  INTAFD='1' and no_int='0' then      --вызов ПП прерывания
					spcall<=spcall+1 ;              
					spret<=spret+1 ;
				elsif  jcond='1' and cop=JMP and name = CALL then   --вызов ПП
					spcall<=spcall+1 ;              
					spret<=spret+1 ;
				elsif  jcond='1' and cop=JMP and name = RET then  --возврат из ПП
					spcall<=spcall-1 ;               
					spret<=spret-1 ;  
				elsif  jcond='1' and cop=JMP and  name = RETI then
					spcall<=spcall-1 ;                                       --возврат из ПП прерывания
					spret<=spret-1 ;    
					INTRET <='1';       
				end if;                                                     
			end if;                                                     
		end if;      
	end process;
	
	MX_SP:process(INTAFD,no_int,jcond,cop,name) --мультиплексор указателя стека
	begin
		if ( INTAFD='1' and no_int='0')or( jcond='1' and cop=JMP and name = CALL) then
			wstack<='1';
			sp<=spcall ;
		else  			   
			wstack<='0';
			sp<=spret ; 
		end if;
	end process;
	INTCALL<='1' when INTAFD='1' and no_int='0' else '0'; --флаг вызова ПП отработки прерывания	
	ADDRI<=pci; 
	CY<=carry;
end PC_SYNT;

