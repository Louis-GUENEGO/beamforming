library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_s2p is
end entity;

architecture tb_arch of tb_s2p is

   signal clk  : std_logic; -- 100MHz
   signal rst  : STD_LOGIC;
   
   signal enable_in : STD_LOGIC;
   signal data_in : STD_LOGIC;
   
   signal data_out : STD_LOGIC_vector (7 downto 0);
   signal enable_out : std_logic;

  begin

 -- component instantiation
s2p : entity work.s2p
    Port map ( rst => rst,
           clk => clk,
           enable_in => enable_in,
           data_in => data_in,
           data_out => data_out,
           enable_out => enable_out );


 -- clock generation
 process
 begin
    clk <= '0';
    loop
      wait for 10 ns;  -- 100MHz
      clk <= '1', '0' after 5 ns;
    end loop;
end process;



 -- main process
  process
    begin
        rst <= '1';
        data_in <= '0';
        enable_in <= '0';
    wait for 50 ns;
        rst <= '0';
        
    wait for 10ns;

    for i in 7 downto 0 loop
        data_in <= '1';
        enable_in <= '1';
        wait for 10ns;
    end loop;
        
    assert (data_out = x"FF") report "ERREUR" severity ERROR;
        
    data_in <= '0';
    enable_in <= '0';
    
    wait for 20ns;
    
    assert (false) report  "Simulation ended." severity failure;

    end process;

  end architecture;