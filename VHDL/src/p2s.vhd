library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity p2s is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           data_in : in STD_LOGIC_vector (7 downto 0);
           data_out : out STD_LOGIC;
           enable_out : out std_logic);
end p2s;

architecture Behavioral of p2s is  

       signal data_in_buf : unsigned(7 downto 0);
       signal cpt : unsigned (3 downto 0);

begin

buf : process (clk)
begin
    if rising_edge(clk) then
        if (rst = '1') then
            
            data_out <= '0';
            enable_out <= '0';
            cpt <= to_unsigned(0,cpt'length);
            
        elsif ( (enable_in = '1') OR (cpt /= to_unsigned(0,cpt'length)) ) then
          
            if (cpt = to_unsigned(0,cpt'length)) then
                data_in_buf <= unsigned(data_in);
                cpt <= cpt + to_unsigned(1,cpt'length);
                
            elsif (cpt < to_unsigned(9,cpt'length)) then
                data_in_buf <= shift_left(data_in_buf,1);
                enable_out <= '1';
                data_out <= data_in_buf(7);
                cpt <= cpt + to_unsigned(1,cpt'length);
                
            else
                enable_out <= '0';
                cpt <= to_unsigned(0,cpt'length);
                
            end if;
            
        
        end if;
        
        
    end if;
end process;


end Behavioral;