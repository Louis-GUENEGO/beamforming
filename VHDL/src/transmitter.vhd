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

    signal enable_fifo : std_logic;
    signal data_fifo : std_logic_vector(7 downto 0);
    signal last : std_logic;
    signal user_last : std_logic;
    signal user_busy : std_logic;

    signal enable_inter : std_logic;
    signal data_inter : std_logic_vector(7 downto 0);

    signal enable_p2s : std_logic;
    signal data_p2s : std_logic_vector(7 downto 0);

    signal enable_enc : std_logic;
    signal data_enc : std_logic;

begin

--    inst_RS : entity work.rs_encoder
--    port map (
--            -- Output
--            Data         => data_fifo,
--            Valid        => enable_fifo,
--            Last         => last,
        
--            -- Input
--            User_Data    => stream_in,
--            User_Valid   => enable,
--            User_Last    => user_last,
--            User_Busy    => user_busy,
            
--            -- Infr
--            Clk          => clk,
--            Rst          => rst
--            );
--    user_last <= '0';
--    user_busy <= '0';
    


    inst_buff : entity work.FIFO_P2S
    Port map ( rst => rst,
           clk => clk,
           enable => enable,--enable_fifo,
           shift_in => stream_in,--data_fifo,
           shift_out => data_inter,
           data_valid => enable_inter);

    inst_conv_interleaver : entity work.conv_interleaver
        generic map ( N => 8 )
        port map (
            i_clk => clk,
            i_rstb => rst,
            i_data_enable => enable_inter,
            i_data => data_inter,
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