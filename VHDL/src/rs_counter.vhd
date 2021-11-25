library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rs_counter is
  port(
    -- Output
    Data         : out std_logic_vector(7 downto 0);
    Valid        : out std_logic;

    -- Input
    User_Data    : in  std_logic_vector(7 downto 0);
    User_Valid   : in  std_logic;
    
    -- Infr
    Clk          : in  std_logic;
    Rst          : in  std_logic
    );
end entity;

architecture rtl of rs_counter is

    signal cpt : unsigned (8 downto 0);
    signal User_Last : std_logic;
    signal User_Busy : std_logic;
    
    signal sig_User_Data : std_logic_vector(7 downto 0);
    signal sig_User_Valid : std_logic;

begin
  
    process (clk)
    begin
    
        if (rising_edge(clk)) then
        
            if (rst = '1') then
            
                cpt <= to_unsigned(0,cpt'length); 
                User_Last <= '0';       
        
            elsif (User_Valid = '1') then
            
                if (cpt = to_unsigned(187,cpt'length)) then
                    cpt <= to_unsigned(0,cpt'length);
                    User_Last <= '1';
                else
                    cpt <= cpt + 1;
                    User_Last <= '0';
                end if;
                
            else
                User_Last <= '0';
            end if;
        
            sig_User_Data <= User_Data;
            sig_User_Valid <= User_Valid;
        
        end if;
        
    end process;
  
    inst_RS : entity work.rs_encoder
    port map (
        -- Output
        Data         => Data,
        Valid        => Valid,
        Last         => open,
        User_Busy    => User_Busy,
    
        -- Input
        User_Data    => sig_User_Data,
        User_Valid   => sig_User_Valid,
        User_Last    => User_Last,
        
        
        -- Infr
        Clk          => clk,
        Rst          => rst
    );

end architecture;