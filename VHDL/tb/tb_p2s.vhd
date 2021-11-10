library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_p2s is
end entity;

architecture tb_arch of tb_p2s is

   signal clk  : std_logic; -- 100MHz
   signal rst  : STD_LOGIC;
   
   signal enable_in : STD_LOGIC;
   signal data_in : STD_LOGIC_vector (7 downto 0);
   
   signal data_out : STD_LOGIC;
   signal enable_out : std_logic;

  begin

 -- component instantiation
p2s : entity work.p2s
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
        data_in <= x"00";
        enable_in <= '0';
    wait for 50 ns;
        rst <= '0';
        
    wait for 10ns;

        data_in <= "11010010";
        enable_in <= '1';
        assert (enable_out = '0') report "ERREUR" severity ERROR;
        
    wait for 10ns;

        enable_in <= '0';
        
    for i in 7 downto 0 loop
        assert (data_out = data_in(i)) report "ERREUR" severity ERROR;
        assert (enable_out = '1') report "ERREUR" severity ERROR;
        wait for 10ns;
    end loop;
    
    
    assert (enable_out = '0') report "enable_out ERREUR" severity ERROR;

    wait for 10 ns;
    
        data_in <= "10101101";
        enable_in <= '1';
        
    wait for 10ns;

        enable_in <= '0';

        for i in 7 downto 0 loop
            assert (data_out = data_in(i)) report "ERREUR" severity ERROR;
            assert (enable_out = '1') report "ERREUR" severity ERROR;
            wait for 10ns;
        end loop;

    wait for 10 ns;
        assert (enable_out = '0') report "enable_out ERREUR" severity ERROR;
    wait for 10 ns;

    assert (false) report  "Simulation ended." severity failure;

    end process;

  end architecture;