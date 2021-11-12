library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FIFO_P2S is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           shift_in : in STD_LOGIC_VECTOR (7 downto 0);
           shift_out : out STD_LOGIC_VECTOR (7 downto 0);
           data_valid : out STD_LOGIC);
end FIFO_P2S;

architecture Behavioral of FIFO_P2S is

type t_shift_reg is array (15 downto 0) of std_logic_vector(7 downto 0);

signal shift_reg_in : t_shift_reg;
signal shift_reg_out : t_shift_reg;
signal data_counter : unsigned(7 downto 0);
signal shift_counter : unsigned(7 downto 0);

begin

shift_out <= shift_reg_out(0);
data_valid <= '1' when shift_counter(2 downto 0) = "001" else '0';

data_count : process(clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then
            data_counter <= (others => '0');
      else
         if(enable = '1') then
            if(data_counter = to_unsigned(15,8)) then             
               data_counter <= (others =>'0');
            else              
               data_counter <= data_counter + 1;
            end if;
         else
         end if;
      end if;
   end if;
end process;

shift_count_count_proc : process(clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then
            shift_counter <= (others => '0');
      else
         if(data_counter = to_unsigned(15,8)) then             
            shift_counter <= to_unsigned(128,8);
         elsif(shift_counter /= to_unsigned(0,8)) then
            shift_counter <= shift_counter - 1;
         else
            shift_counter <= shift_counter;
         end if;
      end if;
   end if;
end process;


shift_in_reg_proc : process(clk)
begin
   if(clk'event and clk='1') then
      if(rst = '1') then
         shift_reg_in <= (others =>(others =>'0'));
      else
         if(enable ='1') then
            shift_reg_in(14 downto 0) <= shift_reg_in(15 downto 1);         
            shift_reg_in(15) <= shift_in;
         end if;
      end if;
   end if;
end process;

shift_out_reg_proc : process(clk)
begin
   if(clk'event and clk='1') then
      if(rst = '1') then
         shift_reg_out <= (others =>(others =>'0'));
      else
         if(data_counter = to_unsigned(15,8)) then
            shift_reg_out(14 downto 0) <= shift_reg_in(15 downto 1);
            shift_reg_out(15) <= shift_in;
         elsif( shift_counter(2 downto 0) = "001") then
            shift_reg_out(14 downto 0) <= shift_reg_out(15 downto 1);         
            shift_reg_out(15) <= (others =>'0');
         else
            shift_reg_out <= shift_reg_out;
         end if;
      end if;
   end if;
end process;



end Behavioral;