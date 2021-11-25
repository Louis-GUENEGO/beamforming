LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

LIBRARY work;
USE work.txt_util.ALL;

entity read_int_file is
generic (
		file_name:       string  := "default.txt";
		line_size:			integer := 32;
		symb_max_val : integer := 3;
		data_size : integer := 2
	 );
port(	clk : in  STD_LOGIC;
		rst : in std_logic;
		enable : in  STD_LOGIC;
		stream_out : out STD_LOGIC_vector(data_size-1 downto 0));
end read_int_file;

architecture logic of read_int_file is

signal data_counter : integer range 0 to line_size-1;
signal buf_data : std_logic_vector(data_size-1 downto 0);

begin
	-- keep track of the value index in the current parsed line
	data_count : process(rst,clk)
	begin
		if(rst = '1') then
			data_counter <= 0;
		elsif(clk'event and clk = '1') then
			if(enable = '1') then
				if(data_counter = 0) then
					data_counter <= line_size - 1;
				else
					data_counter <= data_counter  - 1;
				end if;
			end if;
		end if;
	end process;

	-- parse file
	process(rst,clk)
		FILE data_file     : TEXT OPEN read_mode IS file_name;
		VARIABLE data_line : line;
		variable tmp : integer;
	BEGIN
		if(rst = '1') then
			buf_data <= (others => '0');
		elsif(clk'event and clk = '1') then
			if(data_counter = 0 and enable = '1' and rst = '0') then
				IF NOT endfile(data_file) THEN
					readline(data_file, data_line);
				end if;				
			end if;
			read(data_line, tmp);
			buf_data <=  std_logic_vector(to_unsigned(tmp,data_size));
		END IF;        
	END PROCESS;
	
	stream_out <= buf_data;
	
END;