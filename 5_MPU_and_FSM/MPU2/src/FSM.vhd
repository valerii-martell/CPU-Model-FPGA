entity FSM is
port(
 C : in BIT; --synchro
 RST : in BIT; --reset FSM
 START : in BIT; --start FSM
 B0 : in BIT;
 STOP: in BIT; -- check '1' bits of B
 LAB : out BIT; -- load operands
 SHIFT : out BIT; --shift A and B
 ADD: out BIT; -- add 
 REZ: out BIT;
 RDY : out BIT); --finish
end FSM;

architecture BEH of FSM is
type STATES is (ststart,st1,st2,st3,st4,stfinish); --machine states
signal st:STATES; --current state
begin
 STATE:process(C,RST) -- state register
begin
 if RST='1' then
 st<=ststart;
 elsif C='1' and C'event then 
	 if st=ststart and START='1' then
		 st<=st1; --from start to load-operands-state
	 elsif st=st1 and STOP='1' then
		 st<=stfinish; --if B=0 then finish without other states
	 elsif st=st1 and STOP='0' and B0='1' then
		 st<=st2; --if B(0)=1 then ADD
	 elsif st=st1 and STOP='0' and B0='0' then
		 st<=st3; --if B(0)=0 then SHIFT
     elsif st=st2 then
		 st<=st3; --after ADD always SHIFT
	 elsif st=st3 and STOP='0' and B0='0' then
		 st<=st3; --if after SHIFT B(0)='0' then one more SHIFT
	 elsif st=st3 and STOP='0' and B0='1' then
		 st<=st2; --if after SHIFT B(0)='1' then ADD
	 elsif st=st3 and STOP='1' then
		 st<=st4; --if after SHIFT B=0 then RSH result
	 elsif st=st4 then
		 st<=stfinish; --always go to finish after RSH
	 elsif st=stfinish and START='1' then
		 st<=ststart;
	 end if; 
 end if; 
end process;
-- output signals logic
 LAB<='1' when st=st1 else '0';
 ADD<='1' when st=st2 else '0';
 SHIFT<='1' when st=st3 else '0';
 REZ<='1' when st=st4 else '0';
 RDY<='1' when st=stfinish else '0';
end BEH; 