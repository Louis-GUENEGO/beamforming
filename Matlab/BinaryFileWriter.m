classdef BinaryFileWriter < matlab.System
	properties (Nontunable)
		Filename   = ''
		DataType = 'double'
	end
	
	properties(Access=private)
		% Saved value of the file identifier
		pFID = -1,
	end
	
	methods
		% Constructor for the System object
		function obj = BinaryFileWriter(varargin)
			setProperties(obj, nargin, varargin{:});
		end
	end
	
	% Overridden implementation methods
	methods(Access = protected)
		% initialize the object
		function setupImpl(obj)
			% Populate obj.pFID
			getWorkingFID(obj,'w')
			
		end
		
		% reset the state of the object
		function resetImpl(obj)
			% go to beginning of the file
			fseek(obj.pFID, 0, 'bof');
		end
		
		% execute the core functionality
		function stepImpl(obj, u)
			castedU = cast(u,obj.DataType);
			if(isreal(u))
				fwrite(obj.pFID, castedU(:).', obj.DataType);
			else
				% If input is complex, interleave real and imag parts as
				% separate adjacent channels
				ri = zeros(2*numel(castedU),1);
				ri = cast(ri,obj.DataType);
				ri(1:2:end) = real(castedU(:));
				ri(2:2:end) = imag(castedU(:));
				fwrite(obj.pFID, ri(:).', obj.DataType);
			end
		end
		
		% release the object and its resources
		function releaseImpl(obj)
			fclose(obj.pFID);
			obj.pFID = -1;
		end
		
		function loadObjectImpl(obj,s,wasLocked)
			% Call base class method
			loadObjectImpl@matlab.System(obj,s,wasLocked);
			
			% Re-load state if saved version was locked
			if wasLocked
				% All the following were set at setup
				% Set obj.pFID - needs obj.Filename (restored above)
				obj.pFID = -1; % Superfluous - already set to -1 by default
				getWorkingFID(obj,'a');
				% Go to saved position
				fseek(obj.pFID, s.SavedPosition, 'bof');
			end
		end
		
		function s = saveObjectImpl(obj)
			% Default implementation saves all public properties
			s = saveObjectImpl@matlab.System(obj);
			
			if isLocked(obj)
				% All the fields in s are properties set at setup
				s.SavedPosition = ftell(obj.pFID);
			end
		end
		
		
	end
	
	methods(Access = private)
		
		function getWorkingFID(obj, permission)
			if(obj.pFID < 0)
				[obj.pFID, err] = fopen(obj.Filename, permission);
				if ~isempty(err)
					error(['FileWriter:Error', err]);
				end
			end
		end
		
	end
end


