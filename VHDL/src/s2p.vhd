library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity s2p is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           data_in : in STD_LOGIC;
           data_out : out STD_LOGIC_vector (7 downto 0);
           enable_out : out std_logic);
end s2p;

architecture Behavioral of s2p is  

       signal data_in_buf : unsigned(7 downto 0);
       signal cpt : unsigned (2 downto 0);

begin

buf : process (clk)
begin
    if rising_edge(clk) then
        if (rst = '1') then
            
            data_in_buf <= x"00";
            data_out <= x"00";
            
            enable_out <= '0';
            cpt <= to_unsigned(0,cpt'length);        
        
        elsif (enable_in = '1') then
            
            if (cpt = to_unsigned (7, cpt'length) ) then
            
                if (data_in = '1') then
                    data_out <= std_logic_vector (shift_left(data_in_buf,1)) OR x"01";
                else
                    data_out <= std_logic_vector (shift_left(data_in_buf,1));
                end if;
                
                enable_out <= '1';
                
                if (data_in = '1') then
                    data_in_buf <=  to_unsigned (1, data_in_buf'length);
                else
                    data_in_buf <=  to_unsigned (0, data_in_buf'length);
                end if;
                
                cpt <= cpt + 1;
            
            
            else
            
                enable_out <= '0';
            
                if (data_in = '1') then
                    data_in_buf <= shift_left(data_in_buf,1) + 1;
                else
                    data_in_buf <= shift_left(data_in_buf,1);
                end if;
                
                cpt <= cpt + 1;
                
             end if;
        
        else
            enable_out <= '0';
        end if;
        
        
    end if;
end process;

end Behavioral;