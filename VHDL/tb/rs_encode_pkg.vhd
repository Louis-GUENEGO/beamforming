--------------------------------------------------------------------------------
--{{{ Copyright 2010 C. D. Stahl, All rights reserved.
--
--    1. Redistributions of source code must retain the above copyright 
--       notice, this list of conditions and the following disclaimer.
--    
--    2. Redistributions in binary form must reproduce the above copyright 
--       notice, this list of conditions and the following disclaimer in 
--       the documentation and/or other materials provided with the 
--       distribution.
--    
--    THIS SOFTWARE IS PROVIDED BY C. D. STAHL ``AS IS'' AND ANY EXPRESS OR 
--    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
--    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
--    IN NO EVENT SHALL C. D. STAHL OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
--    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
--    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
--    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
--    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
--    SUCH DAMAGE.
-- 
--}}}


--------------------------------------------------------------------------------
--{{{ Discription
--}}}


--------------------------------------------------------------------------------
--{{{ Includes
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gf256_pkg.all;
--}}}


--------------------------------------------------------------------------------
--{{{ Package
package rs_encoder_pkg is

  ------------------------------------------------------------------------------
  --{{{ Reed-Solomon Encoder
  component rs_encoder is
    port(
      -- Output
      Data         : out std_logic_vector(7 downto 0);
      Valid        : out std_logic;
      Last         : out std_logic;
  
      -- Input
      User_Data    : in  std_logic_vector(7 downto 0);
      User_Valid   : in  std_logic;
      User_Last    : in  std_logic;
      User_Busy    : out std_logic;
      
      -- Infr
      Clk          : in  std_logic;
      Rst          : in  std_logic
      );
  end component;
  --}}}
  
  
  ------------------------------------------------------------------------------
  --{{{ encoder logic
  component rs_encode_logic is
    port(
      Lo  : out gf256_a(15 downto 0);
      Li  : in  gf256_a(15 downto 0);
      Di  : in  std_logic_vector(7 downto 0)
      );
  end component;
  --}}}


end package;
--}}}


