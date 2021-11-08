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

    signal enable_p2s : std_logic;
    signal data_p2s : std_logic_vector(7 downto 0);

    signal enable_enc : std_logic;
    signal data_enc : std_logic;

begin

    inst_conv_interleaver : entity work.conv_interleaver
        generic map (
 N => 8 )
        port map (
            i_clk => clk,
            i_rstb => rst,
            i_data_enable => enable,
            i_data => stream_in,
            o_data_valid => enable_p2s,
            o_data_out => data_p2s );



    inst_p2s : entity work.p2s
    Port map ( rst => rst,
               clk => clk,
               enable_in => enable_p2s,
               data_in => data_p2s,
               data_out => data_enc,
               enable_out => enable_enc );


     
    inst_conv_enc :entity work.conv_enc
    Port map ( rst => rst,
               clk => clk,
               enable => enable_enc,
               stream_in => data_enc,
               stream_out => stream_out(1 downto 0),
               data_valid => data_valid );
    
    stream_out(7 downto 2) <= "000000";

end Behavioral;