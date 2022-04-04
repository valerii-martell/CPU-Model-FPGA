library ieee;
use ieee.std_logic_1164.all, work. RISC_lib.all;
entity risc_cpu_tb is  generic(TCLK:time:=20 ns);--период синхросерии    
end risc_cpu_tb;

architecture TB_ARCHITECTURE of risc_cpu_tb is
	component risc_cpu   port(	CLK : in std_logic;
			RST : in std_logic;
			INTREQ : in std_logic_vector(3 downto 0);
			PORT0_I : in std_logic_vector(15 downto 0);
			PORT0_O : out std_logic_vector(15 downto 0) );
	end component;
	signal CLK : std_logic:='0';
	signal RST : std_logic;
	signal INTREQ : std_logic_vector(3 downto 0):="0000";
	signal PORT0_I : std_logic_vector(15 downto 0);
	signal PORT0_O : std_logic_vector(15 downto 0);  
    signal end_s:boolean;
begin
	UUT : risc_cpu	port map (CLK => CLK,
		RST => RST,
		INTREQ => INTREQ,
		PORT0_I => PORT0_I,
		PORT0_O => PORT0_O	);  
        --стимулирующие сигналы		 
	INTREQ(2)<=not INTREQ(2) after 0.5 us  when not end_simulation else '0' ;
	INTREQ(1)<=not INTREQ(1) after 0.65 us  when not end_simulation else '0' ;
	INTREQ(0)<=not INTREQ(0) after 0.8 us  when not end_simulation else '0' ; 
  	CLK<=not CLK after TCLK/2 when not end_simulation else '0' ;   
	RST<='1', '0' after 30 ns;    
	END_SIM:process	begin
		end_simulation:=false;
   		wait for 16 us;  --время моделирования
		end_simulation:=true;    
        wait;
	end process;
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_risc_cpu of risc_cpu_tb is
	for TB_ARCHITECTURE
		for UUT : risc_cpu
			use entity work.risc_cpu(risc_cpu_synt);
		end for;
	end for;
end TESTBENCH_FOR_risc_cpu;

