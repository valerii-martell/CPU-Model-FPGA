library IEEE;   
use IEEE.std_logic_1164.all, IEEE.std_logic_unsigned.all, IEEE.std_logic_arith.all;  
use work. RISC_lib.all;
entity PC is   port( CLK : in std_logic;
		RST : in std_logic;
		ENA : in std_logic;                  --���������� ������
		INTAFD : in std_logic;             -- ���������� ����������
		INSTR : in WORD;                  --���� ������
		RS : in  WORD;                      --������� RS �� RRAM
		CNVZ : in NIBBLE;                  --������ ������� �� ���
		INTVEC : in std_logic_vector(N_INTVEC downto 0); --������ ����������
		CY : out std_logic;                  --���� ��������   � ���      
		RSTD:buffer std_logic;           --������������������ RST
		INTCALL : out std_logic;         --���� ������ �� ��������� ����������     
		INTRET: out std_logic;            -- ���� ���������� ������� RETI
		ADDRI : out WORD   );           -- ����� �������
end PC;

architecture PC_SYNT of PC is       
	signal INSTR_R: WORD;    --������� �������   
	signal cop:TRIPLET;          --��� ��������
	signal conds : TRIPLET;     --��� ������� 
	signal neg_cond:std_logic;--�������� �������
	signal name:NIBBLE;         --��� �������� ��������
	signal disp: BYTE;             --�������� ������
	signal pc,pci: WORD;                    --������� ������
	signal pcplus1:WORD;       --������� ������ + 1
	signal int_vect:WORD;       --����� �� ����������           
	signal jcond,jcondu:std_logic; -- ������� ��������     
	signal  carry,neg,overf,zero:std_logic;  --���� �������        
	signal stack_i,stack_o:std_logic_vector(19 downto 0);--����-����� �����        
	signal sp,spcall,spret:NIBBLE;  --��������� �����
	signal wstack:std_logic;      --������ � ����
	signal CNVZi:NIBBLE;        --������ �������
	signal no_int:std_logic;     --������ ���������� � ������ �������
begin              
	T_RST:process(CLK,RST)   --������� ������������� RST
	begin
		if  RST='1'  then
			RSTD<='1';     
		elsif Rising_edge(CLK) then
			RSTD<='0';
		end if;        
	end process;
	
	R_INSTR:process(CLK,RST)   --������� �������
	begin
		if RST='1' then
			INSTR_R<=NOP;
		elsif  Rising_edge(CLK)  then  
			if  ENA='1'  and RSTD= '0' then
				INSTR_R<=INSTR;   
			end if;
		end if;          
	end process;                               
	--��������� ����� �������
	no_int<=  INSTR_R(15);                --������ ����������
	cop<=  INSTR_R(14 downto 12);  --��� ��������
	conds<=INSTR_R(11 downto 9);  --��� ������� �������� 
	neg_cond<=INSTR_R(8);              --�������� ������� ��������
	name<= INSTR_R(3 downto 0);  -- ��� ������� ��������
	disp<=  INSTR_R(7 downto 0);   --�������� ������
	int_vect<=  INT_NULL & INTVEC & "000"; --�� 1 �� ���������� -�� 8 ������
	(carry,neg,overf,zero)<=CNVZi;            --������ �������   ��������                   
	
	MX_COND:  with conds select          --������������� ������� ��������
	jcondu<= '1'  when JUMP,
	zero when EQ,
	carry xor neg when LT,
	zero or carry when LE, 
	overf when OVF ,
	carry when others;
	jcond<=jcondu xnor neg_cond;  -- ��� ������� ��������
	--������� - ������� ������
	R_PC:process(CLK,RST,RSTD,int_vect,cop,name,no_int,intafd,jcond,pc,
		disp,RS,stack_o,pcplus1,pci)  
	begin                                           
		pcplus1<=pc+1;      -- ��������� ������ 
		pci<=pcplus1;            --��������� ����� �������   ��� ��������� ��������    
		if  INTAFD='1' and no_int='0'  then   --������� ��� ����������
			pci<=int_vect;
		elsif  jcond='1' then          -- ������� �� ������� �������� - �������
			if cop=BRA then             -- ���� �������� ������� �� ��+��������
				pci<= pc+ SXT(disp,16);
			elsif cop=JMP then        -- ���� �������� ������� �� ���������� ����
				if name=LJMP or name=CALL  then
					pci<= RS;                 -- ���� ������� �������� ������� ��� ����� ��
				else 
					pci<= stack_o(15 downto 0); -- ���� ������� �� ��
				end if;  
			end if;
		elsif RSTD='1' then    
			pci<=INIT_ADDR;          --����� ����� ������������������� ������ 
		end if;  
		if RST='1' then
			pc<=INIT_ADDR;                           --����� ����� ������ 
		elsif  Rising_edge(CLK)  then  
			if  ENA='1'  then      
				pc<=   pci;                                --�������-������� ������               
			end if;
		end if;
	end process;             
	
	R_CNVZ:process(CLK,RST)   --������� coc������ ������
	begin
		if RST='1' then
			CNVZi<="0000";
		elsif  Rising_edge(CLK)  then  
			if ENA='1' and RSTD='0' then
				if  jcond='1' and cop=JMP and ((name = RET)or(name = RETI)) then
					CNVZi<=stack_o(19 downto 16);   --�������� �� ����� ��� �������� �� ��
				else
					CNVZi<=CNVZ;                            -- ������ ������ �� ���
				end if;
			end if;
		end if;          
	end process;     
	
	stack_i<=CNVZ & pcplus1;   --��������� � ����
	RAM_STACK:process(CLK,sp)                  -- ��� �����, ������������� �� RAM16X1S 
		type ARR is array (0 to 15) of std_logic_vector(19 downto 0);
		variable RAM:ARR:=(others=>X"00000");
	begin
		stack_o<= RAM(Conv_Integer(sp));    -- ������ �����
		if  Rising_edge(CLK)  then      
			if wstack ='1' then
				RAM(Conv_Integer(sp)):= stack_i; --������ � ����
			end if;   
		end if;  
	end process;                 
	
	TTR_SP:process(CLK,RST)                  --��������� ����� � �������� ������
	begin 
		if  RST='1'  then
			spcall<= "0000"; --��������� ����� ��� ������ ��  
			spret<= "1111"; --��������� ����� ��� �������� �� ��, �� 1 ������, ��� spcall    
			INTRET<='0';     --���� ���������� ������� RETI
		elsif  Rising_edge(CLK) then      
			if ENA='1' then                
				INTRET<='0';          
				if  INTAFD='1' and no_int='0' then      --����� �� ����������
					spcall<=spcall+1 ;              
					spret<=spret+1 ;
				elsif  jcond='1' and cop=JMP and name = CALL then   --����� ��
					spcall<=spcall+1 ;              
					spret<=spret+1 ;
				elsif  jcond='1' and cop=JMP and name = RET then  --������� �� ��
					spcall<=spcall-1 ;               
					spret<=spret-1 ;  
				elsif  jcond='1' and cop=JMP and  name = RETI then
					spcall<=spcall-1 ;                                       --������� �� �� ����������
					spret<=spret-1 ;    
					INTRET <='1';       
				end if;                                                     
			end if;                                                     
		end if;      
	end process;
	
	MX_SP:process(INTAFD,no_int,jcond,cop,name) --������������� ��������� �����
	begin
		if ( INTAFD='1' and no_int='0')or( jcond='1' and cop=JMP and name = CALL) then
			wstack<='1';
			sp<=spcall ;
		else  			   
			wstack<='0';
			sp<=spret ; 
		end if;
	end process;
	INTCALL<='1' when INTAFD='1' and no_int='0' else '0'; --���� ������ �� ��������� ����������	
	ADDRI<=pci; 
	CY<=carry;
end PC_SYNT;

