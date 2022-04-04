---------------------------------------------------------------------------------------------------
--
-- Title       : CNetlist_Lib
-- Design      : Computer Netlist Engineering
-- Author      : Anatolij Sergyienko
-- Company     : NTUU "KPI"
---------------------------------------------------------------------------------------------------
-- File        : CNetlist_Lib.vhd
-- Generated   : Thu Sep 23 08:55:32 2004
---------------------------------------------------------------------------------------------------
-- Description : Библиотека функций и объектов
--              для разработки логических схем на основе ПЛМ и ПЛИС
--              основные типы - integer, bit и bit_vector 
--				 Synopsys.BV_Arithmetic
---------------------------------------------------------------------------------------------------
Library IEEE;  
use	 IEEE.STD_LOGIC_1164.all;
Package CNetwork is
	constant MINUS1: bit_vector(31 downto 0):=(31=>'1', others=>'0');
	subtype Z01 is STD_uLOGIC range '0'to'Z';-- '0' to 'Z'; 
	--преобразование вектора бит - числа в прямом коде в целое
	function BIT_TO_INT(b:bit_vector) return integer;	   				 
	--BVtoI
	--преобразование вектора бит - числа в доп.коде в целое
	function BITS_TO_INT(b:bit_vector) return integer;	   				 
	--SBVtoI
	--преобразование бита в целое
	function BIT_TO_INT(b:bit) return integer;	   				 
	
	--преобразование целого со знаком в вектор бит - число в прямом коде
	function INT_TO_BIT(i,l:integer) return bit_vector;
	
	--преобразование целого со знаком в вектор бит - число в доп.коде
	function INT_TO_BITS(i,l:integer) return bit_vector;
	--ItoBV
	--преобразование целого 0|1 в бит
	function INT_TO_BIT(i:integer) return bit;
	
	--реализация логической табличной  функции 
	-- 	e,d,c,b,a - образуют адрес в таблице, е- старший бит,
	-- mask-содержимое таблицы, левый бит- по старшему адресу 
	function LOG_TAB(e,d,c,b,a:BIT:='0';mask:bit_vector) return bit;	
	
	
	
end CNetwork;


Package body CNetwork is	   	 
	
	function BIT_TO_INT(b:bit_vector) return integer is
		variable bi:bit_vector(b'range); 
		variable fl:boolean:=false;
		variable t,j:integer:=0;
	begin							   
		assert b'length<=32 report "слишком длинный вектор бит" severity failure;
		-- 	переводим в целое	
		for i in b'reverse_range loop
			if b(i)='1' then
				t:=t+2**j;
			end if;
			j:=j+1;
		end loop; 	
		return t;		
	end function;
	
	function BITS_TO_INT(b:bit_vector) return integer is
		variable bi:bit_vector(b'range); 
		variable fl:boolean:=false;
		variable t,j:integer:=0;
	begin							   
		assert b'length<=32   report "слишком длинный вектор бит" severity failure;
		bi:=b;
		--получаем прямой код 
		if b(b'left)='1' then
			for i in b'reverse_range loop
				if not fl and b(i)='1' then
					fl:=true;
				elsif fl then	
					bi(i):=not b(i);
				end if;	
			end loop; 
		end if;
		-- и	переводим в целое	
		for i in b'reverse_range loop
			if bi(i)='1' then
				t:=t+2**j;
			end if;
			j:=j+1;
		end loop; 	
		--и представляем со знаком
		if b(b'left)='1' then	 
			t:=-t;
		end if;	 
		return t;		
	end function;
	
	function BIT_TO_INT(b:bit) return integer is
	begin		  
		if b='0' then
			return 0;
		else
			return 1;
		end if;
	end function;
	
	function INT_TO_BIT(i,l:integer) return bit_vector is
		variable bv: bit_vector(l-1 downto 0):=(others=>'0');
		variable ii,i2:integer;	 
		variable fl:boolean:=false;
	begin	 
		assert l<=32 report "слишком длинный вектор";
		ii:=i;
		--построение вектора битов
		for j in bv'reverse_range loop
			i2:=ii/2;
			if i2*2/=ii then
				bv(j):='1';
			end if;
			ii:=i2;				
		end loop;	
		return bv;
	end function;
	
	function INT_TO_BITS(i,l:integer) return bit_vector is
		variable bv: bit_vector(l-1 downto 0):=(others=>'0');
		variable ii,i2:integer;	 
		variable fl:boolean:=false;
	begin	 
		assert l<=32 report "слишком длинный вектор";
		ii:=abs(i);
		--построение вектора битов
		for j in bv'reverse_range loop
			i2:=ii/2;
			if i2*2/=ii then
				bv(j):='1';
			end if;
			ii:=i2;				
		end loop;	
		--получение доп.кода
		if i<0 then
			for j in bv'reverse_range loop
				if not fl and bv(j)='1' then
					fl:=true;
				elsif fl then	
					bv(j):=not bv(j);
				end if;			
			end loop;
		end if;
		return bv;
	end function;
	
	function INT_TO_BIT(i:integer) return bit is
		
	begin
		assert i=0 or i=1 or i=integer'left report"неизвестной длины вектор" severity failure;
		if i=0 then
			return '0';
		else
			return '1';
		end if;
	end function;
	
	
	function LOG_TAB(e,d,c,b,a:BIT:='0';mask:bit_vector) return bit is
		variable adr: integer:=0;
		variable v:bit_vector(4 downto 0);	 
	begin	   						
		v:=e&d&c&b&a;
		for i in 0 to 4 loop
			if v(i)='1' then 
				adr:=adr+2**i ;
			end if;
		end loop;
		return mask(adr);
	end function ;
	
end package body;		   


use Cnetwork.all;  
entity LUT4 is	
	generic(mask:bit_vector(15 downto 0):=X"ffff";
		td:time:=1 ns);
	port(
		a : in BIT;
		b : in BIT;
		c : in BIT;
		d : in BIT;
		Y : out BIT
		);
end LUT4;

architecture BEH of LUT4 is	 
begin	   
	y<=LOG_TAB('0',d,c,b,a,mask) after td;	 
end BEH;

use Cnetwork.all;
entity LUT5 is
	generic(mask:bit_vector(31 downto 0):=X"ffffffff";
		td:time:=1 ns);
	port(
		a : in BIT;
		b : in BIT;
		c : in BIT;
		d : in BIT;			   
		e : in BIT;
		Y : out BIT
		);
end LUT5;

architecture BEH of LUT5 is	 
begin	   
	y<=LOG_TAB(e,d,c,b,a,mask) after td;	 
end BEH;	


-- генератор случайных чисел с равномерным распределением
Library IEEE;
Use IEEE.MATH_REAL.ALL;
use Cnetwork.all;
entity RANDOM_GEN is	  
	generic(n:positive:=8; --разрядность выходного слова
		tp:time:=100 ns	;		-- период следования  
		SEED:positive:=12345   -- начальное состояние
		);		
	port(CLK:out BIT;
		Y : out BIT_vector(n-1 downto 0)
		);
end RANDOM_GEN; 				

architecture BEH of RANDOM_GEN is
begin	  
	process		  
		variable clki:bit;
		variable a,b:positive:=SEED;
		variable s:real;
	begin  
		Uniform(a,b,s);
		clki:=not clki;
		CLK<=clki;
		wait for tp/2;
		clki:=not clki;
		CLK<=clki;
		Y<=INT_TO_BIT(integer(s*real(2**n)),n) ;
		wait for tp/2 ;
		
	end process;
	
end BEH;	 

--Триггер с разрешением записи CE и асинхронным сбросом R
entity FDRE  is generic(td:time:=1 ns);
	port (Q:out  bit; 
		D :	in   bit;
		C :	in   bit;
		CE:	in   bit;
		R :	in   bit);
end FDRE;
architecture BEH of FDRE is	
	signal qi:bit;
begin
	process(C,R) begin
		if R='1' then
			qi<='0';
		elsif C='1' and C'event then
			if CE='1' then
				qi<=D;
			end if;
		end if;
	end process;
	Q<=qi after td;
end BEH;


use  Cnetwork.all;
entity PLM_6 is	  
	generic(td:time:=1 ns);			-- задержка
	port(A,	B,C,D,E,F: in BIT;
		Y : out BIT);
end PLM_6; 

use  Cnetwork.all;
entity PLM_5 is	  
	generic(td:time:=1 ns);			-- задержка
	port(A,	B,C,D,E: in BIT;
		Y : out BIT);
end PLM_5; 

use  Cnetwork.all;
entity PLM_4 is	  
	generic(td:time:=1 ns);			-- задержка
	port(A,	B,C,D: in BIT;
		Y : out BIT);
end PLM_4; 

use  Cnetwork.all;
entity PLM_3 is	  
	generic(td:time:=1 ns);			-- задержка
	port(A,	B,C: in BIT;
		Y : out BIT);
end PLM_3;