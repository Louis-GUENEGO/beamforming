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

    component conv_enc is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           stream_in : in STD_LOGIC;
           stream_out : out STD_LOGIC_VECTOR(1 downto 0);
           data_valid : out std_logic);
    end component;

begin

    inst_conv_enc : conv_enc port map(rst, clk, enable, stream_in(0), stream_out(1 downto 0), data_valid);
    
    stream_out(7 downto 2) <= "000000";

end Behavioral;