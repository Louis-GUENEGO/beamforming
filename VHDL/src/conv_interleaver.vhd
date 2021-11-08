library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_interleaver is
generic (
  N : integer := 8 ); -- number of I/O bit
port (
  i_clk                                   : in  std_logic;
  i_rstb                                  : in  std_logic;
  i_data_enable                           : in  std_logic;
  i_data                                  : in  std_logic_vector(N-1 downto 0);
  o_data_valid                            : out std_logic;
  o_data_out                              : out std_logic_vector(N-1 downto 0));
end conv_interleaver;

architecture rtl of conv_interleaver is

    signal r_counter_enc   : integer range 0 to 11;


    type p_row_fifo is array(integer range <>) of std_logic_vector(N-1 downto 0);
    signal p_row_1         : p_row_fifo(0 to 17*1 - 1) := ( others => x"00" );
    signal p_row_2         : p_row_fifo(0 to 17*2 - 1) := ( others => x"00" );
    signal p_row_3         : p_row_fifo(0 to 17*3 - 1) := ( others => x"00" );
    signal p_row_4         : p_row_fifo(0 to 17*4 - 1) := ( others => x"00" );
    signal p_row_5         : p_row_fifo(0 to 17*5 - 1) := ( others => x"00" );
    signal p_row_6         : p_row_fifo(0 to 17*6 - 1) := ( others => x"00" );
    signal p_row_7         : p_row_fifo(0 to 17*7 - 1) := ( others => x"00" );
    signal p_row_8         : p_row_fifo(0 to 17*8 - 1) := ( others => x"00" );
    signal p_row_9         : p_row_fifo(0 to 17*9 - 1) := ( others => x"00" );
    signal p_row_10        : p_row_fifo(0 to 17*10- 1) := ( others => x"00" );
    signal p_row_11        : p_row_fifo(0 to 17*11- 1) := ( others => x"00" );
    
begin

p_interleaver_control : process(i_clk)
begin
    if( rising_edge(i_clk) ) then
        if(i_rstb='1') then
            r_counter_enc    <= 0;
            o_data_valid     <= '0';
            r_counter_enc    <= 0;
            
        
        else
            o_data_valid     <= i_data_enable;                
            if(i_data_enable='1') then
            
                case r_counter_enc is
                    when 1   => o_data_out  <= p_row_1 (p_row_1 'length-1); p_row_1  <= i_data&p_row_1 (0 to p_row_1 'length-2); 
                    when 2   => o_data_out  <= p_row_2 (p_row_2 'length-1); p_row_2  <= i_data&p_row_2 (0 to p_row_2 'length-2); 
                    when 3   => o_data_out  <= p_row_3 (p_row_3 'length-1); p_row_3  <= i_data&p_row_3 (0 to p_row_3 'length-2); 
                    when 4   => o_data_out  <= p_row_4 (p_row_4 'length-1); p_row_4  <= i_data&p_row_4 (0 to p_row_4 'length-2); 
                    when 5   => o_data_out  <= p_row_5 (p_row_5 'length-1); p_row_5  <= i_data&p_row_5 (0 to p_row_5 'length-2); 
                    when 6   => o_data_out  <= p_row_6 (p_row_6 'length-1); p_row_6  <= i_data&p_row_6 (0 to p_row_6 'length-2); 
                    when 7   => o_data_out  <= p_row_7 (p_row_7 'length-1); p_row_7  <= i_data&p_row_7 (0 to p_row_7 'length-2); 
                    when 8   => o_data_out  <= p_row_8 (p_row_8 'length-1); p_row_8  <= i_data&p_row_8 (0 to p_row_8 'length-2); 
                    when 9   => o_data_out  <= p_row_9 (p_row_9 'length-1); p_row_9  <= i_data&p_row_9 (0 to p_row_9 'length-2); 
                    when 10  => o_data_out  <= p_row_10(p_row_10'length-1); p_row_10 <= i_data&p_row_10(0 to p_row_10'length-2); 
                    when 11  => o_data_out  <= p_row_11(p_row_11'length-1); p_row_11 <= i_data&p_row_11(0 to p_row_11'length-2); 
                    when others   => o_data_out  <= i_data  ;
                end case;
            
                if(r_counter_enc=11) then
                    r_counter_enc    <= 0;
                else
                    r_counter_enc    <= r_counter_enc + 1;
                end if;
            end if;
        end if;
    end if;
end process p_interleaver_control;

end rtl;