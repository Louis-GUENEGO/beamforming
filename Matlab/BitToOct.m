classdef BitToOct < matlab.System
    % Pre-computed constants
    properties(Access = private)
        PaddingValue = 0;
    end
    
    properties(Access = private, Hidden)
        PaddingNbr = 0;
        PaddingVector = [];
    end
    
    
    methods(Access = public)
        function obj = BitToOct(varargin)
            setProperties(obj, nargin, varargin{:});
        end
    end
    
    methods(Access = protected)
        % initialize the object
        function setupImpl(obj,u)
            obj.PaddingNbr = ceil(length(u)/8)*8 - length(u);
            obj.PaddingVector = obj.PaddingValue * ones(obj.PaddingNbr,1);
        end
        
        % execute the core functionality
        function y = stepImpl(obj,b)
            padded_b = [b(:); obj.PaddingVector];
            y = uint8(bi2de(reshape(padded_b,8,[]).','left-msb'));
        end 
    end
end
