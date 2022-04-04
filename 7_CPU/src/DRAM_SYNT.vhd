library IEEE;
use IEEE.std_logic_1164.all, IEEE.std_logic_UNSIGNED.all,work. RISC_lib.all;      
--pragma translate_off
library unisim;
--pragma translate_on
entity DRAM is   
	port(CLK : in std_logic;
		RST : in std_logic;    
		RE: in std_logic;
		WE: in std_logic;
		ADDRD : in WORD; 
		DATAI:   in WORD; 
		RDY:out std_logic;
		DATAO : out WORD	);
end DRAM;                      
architecture DRAM_SYNT of DRAM is 	   	  
	component ramb4_s16						   
		port(
			DI : in std_logic_vector(15 downto 0);
			EN : in std_ulogic;
			WE : in std_ulogic;
			RST : in std_ulogic;
			CLK : in std_ulogic;
			ADDR : in std_logic_vector(7 downto 0);
			DO : out std_logic_vector(15 downto 0));
	end component;	
	signal dataoi:WORD; 
	signal en:std_logic;
	signal red:std_logic;
begin                    
	en<= '1' when ADDRD <= DATA_ADDRH else '0' ;   
	U_RAMD: ramb4_s16	port map(DI =>DATAI,
			EN =>en,
			WE =>WE,
			RST =>RST,
			CLK =>CLK,
			ADDR => ADDRD(7 downto 0),
			DO => dataoi);		 
	
	T_RE:process(CLK,RST) begin	--задержанный RE
		if RST='1' then 
			red<='0';
		elsif rising_edge(CLK) then
			red<=RE and en;
		end if;
	end process;
	DATAO<=dataoi when red='1' else (others=>'Z');  
	rdy<='H';
end DRAM_SYNT;
