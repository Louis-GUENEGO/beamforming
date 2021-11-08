library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitter is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           stream_in : in STD_LOGIC_VECTOR(7 downto 0);
           stream_out : out STD_LOGIC_VECTOR(7 downto 0);
           data_valid : out std_logic);
end transmitter;

architecture Behavioral of transmitter is  

    signal enable_int : std_logic;
    signal data_int : std_logic;

begin


    inst_p2s : entity work.p2s
    Port map ( rst => rst,
               clk => clk,
               enable_in => enable,
               data_in => stream_in,
               data_out => data_int,
               enable_out => enable_int );


     
    inst_conv_enc :entity work.conv_enc
    Port map ( rst => rst,
               clk => clk,
               enable => enable_int,
               stream_in => data_int,
               stream_out => stream_out(1 downto 0),
               data_valid => data_valid );
    
    stream_out(7 downto 2) <= "000000";

end Behavioral;