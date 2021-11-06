library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_enc is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           stream_in : in STD_LOGIC;
           stream_out : out STD_LOGIC_VECTOR(1 downto 0);
           data_valid : out std_logic);
end conv_enc;

architecture Behavioral of conv_enc is  

    signal stream_in_0 : std_logic;
    signal stream_in_1 : std_logic;
    signal stream_in_2 : std_logic;
    signal stream_in_3 : std_logic;
    signal stream_in_4 : std_logic;
    signal stream_in_5 : std_logic;
    signal stream_in_6 : std_logic;    

begin

buf : process (clk)
begin
    if rising_edge(clk) then
        if (rst = '1') then
            stream_in_0 <= '0';
            stream_in_1 <= '0';
            stream_in_2 <= '0';
            stream_in_3 <= '0';
            stream_in_4 <= '0';
            stream_in_5 <= '0';
            stream_in_6 <= '0';
            
            data_valid <= '0';
            
            
        elsif ( enable = '1' ) then
          
                stream_in_0 <= stream_in;
                stream_in_1 <= stream_in_0;
                stream_in_2 <= stream_in_1;
                stream_in_3 <= stream_in_2;
                stream_in_4 <= stream_in_3;
                stream_in_5 <= stream_in_4;
                stream_in_6 <= stream_in_5;
                data_valid <= '0';                
        end if;
        
        data_valid <= enable;
        
    end if;
end process;

stream_out(1) <= stream_in_0 xor stream_in_1 xor stream_in_2 xor stream_in_3 xor stream_in_6;
stream_out(0) <= stream_in_0 xor stream_in_2 xor stream_in_3 xor stream_in_5 xor stream_in_6;

end Behavioral;