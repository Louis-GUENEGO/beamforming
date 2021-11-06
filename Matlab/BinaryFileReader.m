classdef BinaryFileReader < matlab.System
    % Public, but non-tunable properties
    properties (Nontunable)
        Filename = '',
        SamplesPerFrame = 1,
        DataType='double',
    end
    
    properties (Logical, Nontunable)
        % IsDataComplex Data is complex
        % If the data stored in the file is complex, set this property to
        % true. Otherwise, set it to false. The default is false.
        IsDataComplex = false;
        
    end
    properties
        PlayCount = 1
    end
    
    properties (Access = protected)
        % pIsDone True if there are no more samples in the file
        pIsDone
    end
    
    
    
    % Pre-computed constants
    properties(Access = private)
        pFID = -1,
        pNumEofReached = 0
    end
    
    properties(Constant, Hidden)
        PadValue = 0
        
    end
    
    methods(Access = public)
        function obj = BinaryFileReader(varargin)
            setProperties(obj, nargin, varargin{:});
            obj.pIsDone = false;
        end
        
        function tf = isDone(obj)
            tf = obj.pIsDone;
        end
    end
    
    methods(Access = protected)
        
        
        % initialize the object
        function setupImpl(obj)
            % Populate obj.pFID
            getWorkingFID(obj)
            
            % Go to start of data
            goToStartOfData(obj)            
        end
        
        % execute the core functionality
        function y = stepImpl(obj)
            bs = obj.SamplesPerFrame;
            y = readBuffer(obj, bs);
        end
        
        function resetImpl(obj)
            goToStartOfData(obj);
            obj.pNumEofReached = 0;
            obj.pIsDone = false;
        end
        
        % release the object and its resources
        function releaseImpl(obj)
            fclose(obj.pFID);
            obj.pFID = -1;
            obj.pIsDone = false;
        end
        
        % indicate if we have reached the end of the file
        
        function loadObjectImpl(obj,s,wasLocked)
            % Call base class method
            loadObjectImpl@matlab.System(obj,s,wasLocked);
            
            % Re-load state if saved version was locked
            if wasLocked
                % All the following were set at setup
                
                % Set obj.pFID - needs obj.Filename (restored above)
                obj.pFID = -1; % Superfluous - already set to -1 by default
                getWorkingFID(obj);
                % Go to saved position
                fseek(obj.pFID, s.SavedPosition, 'bof');
                
                obj.pNumEofReached = s.pNumEofReached;
            end
            
        end
        
        function s = saveObjectImpl(obj)
            % Default implementation saves all public properties
            s = saveObjectImpl@matlab.System(obj);
            
            if isLocked(obj)
                % All the fields in s are properties set at setup
                s.SavedPosition = ftell(obj.pFID);
                s.pNumEofReached = obj.pNumEofReached;
            end
        end
    end
    
    methods(Access = private)
        
        function getWorkingFID(obj)
            if(obj.pFID < 0)
                [obj.pFID, err] = fopen(obj.Filename, 'r');
                if ~isempty(err)
                    error(['FileReader: ', err]);
                end
            end
            
        end
        
        function goToStartOfData(obj)
            fid = obj.pFID;
            frewind(fid);
        end
        
        
        function rawData = readBuffer(obj, numValues)
            bufferSize = obj.SamplesPerFrame;
            if obj.IsDataComplex
                rbs = 2*bufferSize;
                nv = numValues*2;
            else
                rbs = bufferSize;
                nv = numValues;
            end
            
            dt = obj.DataType;
            tmp = fread(obj.pFID, rbs, dt); % Lire une trame
            
            numValuesRead = numel(tmp);
            
            if(numValuesRead == rbs)&&(~feof(obj.pFID))
                rD = tmp;
            else
                % End of file - may also need to complete frame
                obj.pNumEofReached = obj.pNumEofReached + 1;
                if(obj.pNumEofReached < obj.PlayCount)
                    % Keep reading from start of file
                    goToStartOfData(obj)
                    moreData = readBuffer(obj, nv-numValuesRead);
                    rD = [tmp; moreData];
                else
                    % First pad with pad value, then reshape
                    padVector = repmat(obj.PadValue, ...
                        nv - numValuesRead, 1);
                    rD = [tmp; padVector];
                end
                
            end
            
            obj.pIsDone = logical(feof(obj.pFID));
            rD = cast(rD,dt);
            if obj.IsDataComplex
                rawData = complex(rD(1:2:end),rD(2:2:end));
            else
                rawData = rD;
            end
            
        end
        
    end
end
