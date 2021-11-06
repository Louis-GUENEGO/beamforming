----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2017 11:28:53 AM
-- Design Name: 
-- Module Name: UART_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_loop is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           sw : in std_logic_vector(1 downto 0);
           led : out std_logic_vector(15 downto 0);
           i_uart : in STD_LOGIC;
           o_uart : out STD_LOGIC);
end UART_loop;

architecture Behavioral of UART_loop is

component UART_fifoed_send is
    Generic ( fifo_size             : integer := 4096;
              fifo_almost           : integer := 4090;
              drop_oldest_when_full : boolean := False;
              asynch_fifo_full      : boolean := True;
              --baudrate              : integer := 921600;   -- [bps]
              baudrate              : integer := 115200;   -- [bps]
              clock_frequency       : integer := 100000000 -- [Hz]
    );
    Port (
        clk_100MHz : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        dat_en     : in  STD_LOGIC;
        dat        : in  STD_LOGIC_VECTOR (7 downto 0);
        TX         : out STD_LOGIC;
        fifo_empty : out STD_LOGIC;
        fifo_afull : out STD_LOGIC;
        fifo_full  : out STD_LOGIC
    );
end component;

component UART_recv is
   Generic( baudrate        : integer := 115200;   -- [bps]
            clock_frequency : integer := 100000000 -- [Hz]
    );
   Port ( clk    : in  STD_LOGIC;
          reset  : in  STD_LOGIC;
          rx     : in  STD_LOGIC;
          dat    : out STD_LOGIC_VECTOR (7 downto 0);
          dat_en : out STD_LOGIC);
end component;

component transmitter is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           stream_in : in STD_LOGIC_VECTOR(7 downto 0);
           stream_out : out STD_LOGIC_VECTOR(7 downto 0);
           data_valid : out std_logic);
end component;

signal dat_en : std_logic;
signal dat : std_logic_vector(7 downto 0);
signal scrambled_bit : std_logic;
signal sent_byte : std_logic_vector(7 downto 0);
signal data_valid : std_logic;
signal en_counter, dv_counter : unsigned(13 downto 0) := (others => '0');
signal s_o_uart : std_logic;
signal fifo_empty, fifo_afull, fifo_full : std_logic;

begin

	enable_counters:
	process (clk, rst) begin
		if (rising_edge(clk)) then
         if (rst = '1') then
               en_counter <= (others => '0');
         elsif(dat_en = '1') then				
				  en_counter <= en_counter + 1;				  
         else
               en_counter <= en_counter;		
         end if;
         if (rst = '1') then
               dv_counter <= (others => '0');
         elsif(data_valid = '1') then            
              dv_counter <= dv_counter + 1;
         else
               dv_counter <= dv_counter;         
         end if;
		end if;
	end process;
	
	--led(13 downto 0) <= std_logic_vector(en_counter) when sw(0) = '1' else std_logic_vector(dv_counter);
	
	led(15) <= i_uart;
	led(14) <= s_o_uart;
	led(13 downto 6) <= dat;
	led(5) <=  dat_en;
	led(4) <= data_valid;
	led(3 downto 0) <= sent_byte(3 downto 0);
	--led(14) <= fifo_empty;
	--led(15) <= fifo_afull;
	--led(2) <= fifo_full;
	--led(8 downto 3) <= (others => '1'); 

    recv : UART_recv generic map(baudrate => 921600,
                                 --   baudrate => 115200,
                                 clock_frequency => 100000000)
                        port map(clk => clk,
                                 reset => rst,
                                 rx => i_uart,
                                 dat => dat,
                                 dat_en => dat_en);
		                    
	trans : transmitter port map(  rst => rst,
                                  clk => clk,
                                  enable => dat_en,
                                  stream_in => dat,
                                  stream_out => sent_byte,
                                  data_valid => data_valid);
		                      
	send : UART_fifoed_send Generic map( fifo_size => 15000,
					      fifo_almost => 8,
					      drop_oldest_when_full => false,
					      asynch_fifo_full => True,
					      baudrate => 921600,
					      --baudrate => 115200,
					      clock_frequency => 100000000)
	    Port map(   clk_100MHz => clk,
			reset => rst,
			dat_en => data_valid,
			dat    => sent_byte,
			TX     => s_o_uart,
			fifo_empty => fifo_empty, 
			fifo_afull => fifo_afull,
			fifo_full  => fifo_full);

o_uart <= s_o_uart;

end Behavioral;
