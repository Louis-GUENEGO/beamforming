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
--
-- This automatically generated code performs an LFSR.  Normally, this would use
-- a GF multiply add.  Such an operation takes a substantial amount of longest
-- path logic.  This code is optimized by the realization that some factors
-- of the multiply are constant. 
--
-- Example:
-- x + a^n | x^2 a^i + x a^j + a^k
-- to get x^2 a^i, multiply by x a^i
-- this gives x a^i + a^n a^i
-- 
-- this cancels out the first term exactly, and gives a remainder for x of:
-- a^j - a^n a^i
--
-- This is where the multiply and add come from.  Addition (and subtraction) in
-- GF256 is simply "xor".  
--
-- In the above equation, a^n is constant.  An operator "multiply by a^n" can be
-- defined.  Such an operator woul be the same as multiplying a^i by a, n times.
-- This would be n shift operations of a binary lfsr.  This is a simple
-- operation, requiring at most 8 xor operations per bit (typically less).
--
-- The remaining addition is just another xor.  This gives up to 9 xor's per 
-- bit.  Depending on the synthesizer, area might be saved if the tools extract
-- common factors from all of the operations.  For timing, it should be possible
-- to implement this operation as 1 level of logic, using 2 6LUTs and an XORCY.
--
-- The polynomial is (MSB on right):
-- [79, 44, 81, 100, 49, 183, 56, 17, 232, 187, 126, 104, 31, 103, 52, 118, 1]
--
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
--{{{ Entity Declaration
entity rs_encode_logic is
  port(
    Lo  : out gf256_a(15 downto 0);
    Li  : in  gf256_a(15 downto 0);
    Di  : in  std_logic_vector(7 downto 0)
    );
end entity;
--}}}


--------------------------------------------------------------------------------
--{{{ Architecture Declaration
architecture rtl of rs_encode_logic is
  signal fb : std_logic_vector(7 downto 0);
begin

  ------------------------------------------------------------------------------
  --{{{ Feedback Value
  fb <= Li(Li'high) xor Di;
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 16 with coef 118
  Lo(15)(0) <= Li(14)(0) xor fb(2) xor fb(3) xor fb(4)
                         xor fb(7);
  Lo(15)(1) <= Li(14)(1) xor fb(0) xor fb(3) xor fb(4)
                         xor fb(5);
  Lo(15)(2) <= Li(14)(2) xor fb(0) xor fb(1) xor fb(2)
                         xor fb(3) xor fb(5) xor fb(6)
                         xor fb(7);
  Lo(15)(3) <= Li(14)(3) xor fb(1) xor fb(6);
  Lo(15)(4) <= Li(14)(4) xor fb(0) xor fb(3) xor fb(4);
  Lo(15)(5) <= Li(14)(5) xor fb(0) xor fb(1) xor fb(4)
                         xor fb(5);
  Lo(15)(6) <= Li(14)(6) xor fb(0) xor fb(1) xor fb(2)
                         xor fb(5) xor fb(6);
  Lo(15)(7) <= Li(14)(7) xor fb(1) xor fb(2) xor fb(3)
                         xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 15 with coef 52
  Lo(14)(0) <= Li(13)(0) xor fb(3) xor fb(4) xor fb(6)
                         xor fb(7);
  Lo(14)(1) <= Li(13)(1) xor fb(4) xor fb(5) xor fb(7);
  Lo(14)(2) <= Li(13)(2) xor fb(0) xor fb(3) xor fb(4)
                         xor fb(5) xor fb(7);
  Lo(14)(3) <= Li(13)(3) xor fb(1) xor fb(3) xor fb(5)
                         xor fb(7);
  Lo(14)(4) <= Li(13)(4) xor fb(0) xor fb(2) xor fb(3)
                         xor fb(7);
  Lo(14)(5) <= Li(13)(5) xor fb(0) xor fb(1) xor fb(3)
                         xor fb(4);
  Lo(14)(6) <= Li(13)(6) xor fb(1) xor fb(2) xor fb(4)
                         xor fb(5);
  Lo(14)(7) <= Li(13)(7) xor fb(2) xor fb(3) xor fb(5)
                         xor fb(6);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 14 with coef 103
  Lo(13)(0) <= Li(12)(0) xor fb(0) xor fb(2) xor fb(3)
                         xor fb(7);
  Lo(13)(1) <= Li(12)(1) xor fb(0) xor fb(1) xor fb(3)
                         xor fb(4);
  Lo(13)(2) <= Li(12)(2) xor fb(0) xor fb(1) xor fb(3)
                         xor fb(4) xor fb(5) xor fb(7);
  Lo(13)(3) <= Li(12)(3) xor fb(1) xor fb(3) xor fb(4)
                         xor fb(5) xor fb(6) xor fb(7);
  Lo(13)(4) <= Li(12)(4) xor fb(3) xor fb(4) xor fb(5)
                         xor fb(6);
  Lo(13)(5) <= Li(12)(5) xor fb(0) xor fb(4) xor fb(5)
                         xor fb(6) xor fb(7);
  Lo(13)(6) <= Li(12)(6) xor fb(0) xor fb(1) xor fb(5)
                         xor fb(6) xor fb(7);
  Lo(13)(7) <= Li(12)(7) xor fb(1) xor fb(2) xor fb(6)
                         xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 13 with coef 31
  Lo(12)(0) <= Li(11)(0) xor fb(0) xor fb(4) xor fb(5)
                         xor fb(6) xor fb(7);
  Lo(12)(1) <= Li(11)(1) xor fb(0) xor fb(1) xor fb(5)
                         xor fb(6) xor fb(7);
  Lo(12)(2) <= Li(11)(2) xor fb(0) xor fb(1) xor fb(2)
                         xor fb(4) xor fb(5);
  Lo(12)(3) <= Li(11)(3) xor fb(0) xor fb(1) xor fb(2)
                         xor fb(3) xor fb(4) xor fb(7);
  Lo(12)(4) <= Li(11)(4) xor fb(0) xor fb(1) xor fb(2)
                         xor fb(3) xor fb(6) xor fb(7);
  Lo(12)(5) <= Li(11)(5) xor fb(1) xor fb(2) xor fb(3)
                         xor fb(4) xor fb(7);
  Lo(12)(6) <= Li(11)(6) xor fb(2) xor fb(3) xor fb(4)
                         xor fb(5);
  Lo(12)(7) <= Li(11)(7) xor fb(3) xor fb(4) xor fb(5)
                         xor fb(6);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 12 with coef 104
  Lo(11)(0) <= Li(10)(0) xor fb(2) xor fb(3) xor fb(5)
                         xor fb(6);
  Lo(11)(1) <= Li(10)(1) xor fb(3) xor fb(4) xor fb(6)
                         xor fb(7);
  Lo(11)(2) <= Li(10)(2) xor fb(2) xor fb(3) xor fb(4)
                         xor fb(6) xor fb(7);
  Lo(11)(3) <= Li(10)(3) xor fb(0) xor fb(2) xor fb(4)
                         xor fb(6) xor fb(7);
  Lo(11)(4) <= Li(10)(4) xor fb(1) xor fb(2) xor fb(6)
                         xor fb(7);
  Lo(11)(5) <= Li(10)(5) xor fb(0) xor fb(2) xor fb(3)
                         xor fb(7);
  Lo(11)(6) <= Li(10)(6) xor fb(0) xor fb(1) xor fb(3)
                         xor fb(4);
  Lo(11)(7) <= Li(10)(7) xor fb(1) xor fb(2) xor fb(4)
                         xor fb(5);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 11 with coef 126
  Lo(10)(0) <= Li(9)(0) xor fb(2) xor fb(3) xor fb(4)
                        xor fb(5) xor fb(7);
  Lo(10)(1) <= Li(9)(1) xor fb(0) xor fb(3) xor fb(4)
                        xor fb(5) xor fb(6);
  Lo(10)(2) <= Li(9)(2) xor fb(0) xor fb(1) xor fb(2)
                        xor fb(3) xor fb(6);
  Lo(10)(3) <= Li(9)(3) xor fb(0) xor fb(1) xor fb(5);
  Lo(10)(4) <= Li(9)(4) xor fb(0) xor fb(1) xor fb(3)
                        xor fb(4) xor fb(5) xor fb(6)
                        xor fb(7);
  Lo(10)(5) <= Li(9)(5) xor fb(0) xor fb(1) xor fb(2)
                        xor fb(4) xor fb(5) xor fb(6)
                        xor fb(7);
  Lo(10)(6) <= Li(9)(6) xor fb(0) xor fb(1) xor fb(2)
                        xor fb(3) xor fb(5) xor fb(6)
                        xor fb(7);
  Lo(10)(7) <= Li(9)(7) xor fb(1) xor fb(2) xor fb(3)
                        xor fb(4) xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 10 with coef 187
  Lo(9)(0) <= Li(8)(0) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(4) xor fb(6) xor fb(7);
  Lo(9)(1) <= Li(8)(1) xor fb(0) xor fb(1) xor fb(2)
                       xor fb(4) xor fb(5) xor fb(7);
  Lo(9)(2) <= Li(8)(2) xor fb(2) xor fb(4) xor fb(5)
                       xor fb(7);
  Lo(9)(3) <= Li(8)(3) xor fb(0) xor fb(1) xor fb(4)
                       xor fb(5) xor fb(7);
  Lo(9)(4) <= Li(8)(4) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(4) xor fb(5) xor fb(7);
  Lo(9)(5) <= Li(8)(5) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(4) xor fb(5) xor fb(6);
  Lo(9)(6) <= Li(8)(6) xor fb(1) xor fb(2) xor fb(4)
                       xor fb(5) xor fb(6) xor fb(7);
  Lo(9)(7) <= Li(8)(7) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(5) xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 9 with coef 232
  Lo(8)(0) <= Li(7)(0) xor fb(1) xor fb(2) xor fb(3)
                       xor fb(7);
  Lo(8)(1) <= Li(7)(1) xor fb(2) xor fb(3) xor fb(4);
  Lo(8)(2) <= Li(7)(2) xor fb(1) xor fb(2) xor fb(4)
                       xor fb(5) xor fb(7);
  Lo(8)(3) <= Li(7)(3) xor fb(0) xor fb(1) xor fb(5)
                       xor fb(6) xor fb(7);
  Lo(8)(4) <= Li(7)(4) xor fb(3) xor fb(6);
  Lo(8)(5) <= Li(7)(5) xor fb(0) xor fb(4) xor fb(7);
  Lo(8)(6) <= Li(7)(6) xor fb(0) xor fb(1) xor fb(5);
  Lo(8)(7) <= Li(7)(7) xor fb(0) xor fb(1) xor fb(2)
                       xor fb(6);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 8 with coef 17
  Lo(7)(0) <= Li(6)(0) xor fb(0) xor fb(4);
  Lo(7)(1) <= Li(6)(1) xor fb(1) xor fb(5);
  Lo(7)(2) <= Li(6)(2) xor fb(2) xor fb(4) xor fb(6);
  Lo(7)(3) <= Li(6)(3) xor fb(3) xor fb(4) xor fb(5)
                       xor fb(7);
  Lo(7)(4) <= Li(6)(4) xor fb(0) xor fb(5) xor fb(6);
  Lo(7)(5) <= Li(6)(5) xor fb(1) xor fb(6) xor fb(7);
  Lo(7)(6) <= Li(6)(6) xor fb(2) xor fb(7);
  Lo(7)(7) <= Li(6)(7) xor fb(3);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 7 with coef 56
  Lo(6)(0) <= Li(5)(0) xor fb(3) xor fb(4) xor fb(5)
                       xor fb(7);
  Lo(6)(1) <= Li(5)(1) xor fb(4) xor fb(5) xor fb(6);
  Lo(6)(2) <= Li(5)(2) xor fb(3) xor fb(4) xor fb(6);
  Lo(6)(3) <= Li(5)(3) xor fb(0) xor fb(3);
  Lo(6)(4) <= Li(5)(4) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(5) xor fb(7);
  Lo(6)(5) <= Li(5)(5) xor fb(0) xor fb(1) xor fb(2)
                       xor fb(4) xor fb(6);
  Lo(6)(6) <= Li(5)(6) xor fb(1) xor fb(2) xor fb(3)
                       xor fb(5) xor fb(7);
  Lo(6)(7) <= Li(5)(7) xor fb(2) xor fb(3) xor fb(4)
                       xor fb(6);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 6 with coef 183
  Lo(5)(0) <= Li(4)(0) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(4) xor fb(5) xor fb(7);
  Lo(5)(1) <= Li(4)(1) xor fb(0) xor fb(1) xor fb(2)
                       xor fb(4) xor fb(5) xor fb(6);
  Lo(5)(2) <= Li(4)(2) xor fb(0) xor fb(2) xor fb(4)
                       xor fb(6);
  Lo(5)(3) <= Li(4)(3) xor fb(4);
  Lo(5)(4) <= Li(4)(4) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(4) xor fb(7);
  Lo(5)(5) <= Li(4)(5) xor fb(0) xor fb(1) xor fb(2)
                       xor fb(4) xor fb(5);
  Lo(5)(6) <= Li(4)(6) xor fb(1) xor fb(2) xor fb(3)
                       xor fb(5) xor fb(6);
  Lo(5)(7) <= Li(4)(7) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(4) xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 5 with coef 49
  Lo(4)(0) <= Li(3)(0) xor fb(0) xor fb(3) xor fb(4)
                       xor fb(7);
  Lo(4)(1) <= Li(3)(1) xor fb(1) xor fb(4) xor fb(5);
  Lo(4)(2) <= Li(3)(2) xor fb(2) xor fb(3) xor fb(4)
                       xor fb(5) xor fb(6) xor fb(7);
  Lo(4)(3) <= Li(3)(3) xor fb(5) xor fb(6);
  Lo(4)(4) <= Li(3)(4) xor fb(0) xor fb(3) xor fb(4)
                       xor fb(6);
  Lo(4)(5) <= Li(3)(5) xor fb(0) xor fb(1) xor fb(4)
                       xor fb(5) xor fb(7);
  Lo(4)(6) <= Li(3)(6) xor fb(1) xor fb(2) xor fb(5)
                       xor fb(6);
  Lo(4)(7) <= Li(3)(7) xor fb(2) xor fb(3) xor fb(6)
                       xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 4 with coef 100
  Lo(3)(0) <= Li(2)(0) xor fb(2) xor fb(3);
  Lo(3)(1) <= Li(2)(1) xor fb(3) xor fb(4);
  Lo(3)(2) <= Li(2)(2) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(4) xor fb(5);
  Lo(3)(3) <= Li(2)(3) xor fb(1) xor fb(2) xor fb(4)
                       xor fb(5) xor fb(6);
  Lo(3)(4) <= Li(2)(4) xor fb(5) xor fb(6) xor fb(7);
  Lo(3)(5) <= Li(2)(5) xor fb(0) xor fb(6) xor fb(7);
  Lo(3)(6) <= Li(2)(6) xor fb(0) xor fb(1) xor fb(7);
  Lo(3)(7) <= Li(2)(7) xor fb(1) xor fb(2);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 3 with coef 81
  Lo(2)(0) <= Li(1)(0) xor fb(0) xor fb(2) xor fb(4)
                       xor fb(6) xor fb(7);
  Lo(2)(1) <= Li(1)(1) xor fb(1) xor fb(3) xor fb(5)
                       xor fb(7);
  Lo(2)(2) <= Li(1)(2) xor fb(7);
  Lo(2)(3) <= Li(1)(3) xor fb(2) xor fb(4) xor fb(6)
                       xor fb(7);
  Lo(2)(4) <= Li(1)(4) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(4) xor fb(5) xor fb(6);
  Lo(2)(5) <= Li(1)(5) xor fb(1) xor fb(3) xor fb(4)
                       xor fb(5) xor fb(6) xor fb(7);
  Lo(2)(6) <= Li(1)(6) xor fb(0) xor fb(2) xor fb(4)
                       xor fb(5) xor fb(6) xor fb(7);
  Lo(2)(7) <= Li(1)(7) xor fb(1) xor fb(3) xor fb(5)
                       xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 2 with coef 44
  Lo(1)(0) <= Li(0)(0) xor fb(3) xor fb(5) xor fb(6)
                       xor fb(7);
  Lo(1)(1) <= Li(0)(1) xor fb(4) xor fb(6) xor fb(7);
  Lo(1)(2) <= Li(0)(2) xor fb(0) xor fb(3) xor fb(6);
  Lo(1)(3) <= Li(0)(3) xor fb(0) xor fb(1) xor fb(3)
                       xor fb(4) xor fb(5) xor fb(6);
  Lo(1)(4) <= Li(0)(4) xor fb(1) xor fb(2) xor fb(3)
                       xor fb(4);
  Lo(1)(5) <= Li(0)(5) xor fb(0) xor fb(2) xor fb(3)
                       xor fb(4) xor fb(5);
  Lo(1)(6) <= Li(0)(6) xor fb(1) xor fb(3) xor fb(4)
                       xor fb(5) xor fb(6);
  Lo(1)(7) <= Li(0)(7) xor fb(2) xor fb(4) xor fb(5)
                       xor fb(6) xor fb(7);
  --}}}


  ------------------------------------------------------------------------------
  --{{{ For element 1 with coef 79
  Lo(0)(0) <= '0' xor fb(0) xor fb(2) xor fb(5);
  Lo(0)(1) <= '0' xor fb(0) xor fb(1) xor fb(3)
                  xor fb(6);
  Lo(0)(2) <= '0' xor fb(0) xor fb(1) xor fb(4)
                  xor fb(5) xor fb(7);
  Lo(0)(3) <= '0' xor fb(0) xor fb(1) xor fb(6);
  Lo(0)(4) <= '0' xor fb(1) xor fb(5) xor fb(7);
  Lo(0)(5) <= '0' xor fb(2) xor fb(6);
  Lo(0)(6) <= '0' xor fb(0) xor fb(3) xor fb(7);
  Lo(0)(7) <= '0' xor fb(1) xor fb(4);
  --}}}


end architecture;
--}}}

