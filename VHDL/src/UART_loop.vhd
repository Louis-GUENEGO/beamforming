library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_loop is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           i_uart : in STD_LOGIC;
           o_uart : out STD_LOGIC);
end UART_loop;

architecture Behavioral of UART_loop is

    signal dat_en : std_logic;
    signal dat : std_logic_vector(7 downto 0);
    signal sent_byte : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;
    signal s_o_uart : std_logic;
    signal fifo_empty, fifo_afull, fifo_full : std_logic;

begin

    recv : entity work.UART_recv generic map(baudrate => 921600, --115200,
                                             clock_frequency => 100000000)
                                 port map(clk => clk,
                                          reset => rst,
                                          rx => i_uart,
                                          dat => dat,
                                          dat_en => dat_en);
		              
		              
		                    
	trans : entity work.transmitter port map(  rst => rst,
                                               clk => clk,
                                               enable => dat_en,
                                               stream_in => dat,
                                               stream_out => sent_byte,
                                               data_valid => data_valid);
		                  
		                  
		                      
	send : entity work.UART_fifoed_send Generic map( fifo_size => 15000,
                                                     fifo_almost => 8,
                                                     drop_oldest_when_full => false,
                                                     asynch_fifo_full => True,
                                                     baudrate => 921600,-- 115200,
                                                     clock_frequency => 100000000)
                                        Port map( clk_100MHz => clk,
                                                  reset => rst,
                                                  dat_en => data_valid,
                                                  dat    => sent_byte,
                                                  TX     => s_o_uart,
                                                  fifo_empty => fifo_empty, 
                                                  fifo_afull => fifo_afull,
                                                  fifo_full  => fifo_full);


    o_uart <= s_o_uart;

end Behavioral;
