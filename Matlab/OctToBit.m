classdef OctToBit < matlab.System
    methods(Access = protected)
        % execute the core functionality
        function b = stepImpl(~,u)
            b = zeros(8*numel(u),1);
            b(:) = de2bi(uint8(u(:)),8,'left-msb').';
        end
    end
end
