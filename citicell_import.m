% Import CITI File to citicell (tm)
%   This script is part of the citicell (tm) Library
%   Last update by: Wesley Allen (wnallen@gmail.com)
%                   10 Aug, 2007
%
% Imports data from a CITI file.  Returns data into a citicell (tm)
% variable.
%
% Use: citicell = citicell_import(fileName,debug)
%               fileName = location of file to import
%               debug    = 1: print messages
%                          0: no message printing
%
%
% =========================
%  citicell (tm) structure
% =========================
%
% {1} Data Cell
%
%     {1}{block}{1} = data block names (string)
%               block = data block number
%
%     {1}{block}{2} = data block types (string)
%               block = data block number
%
%     {1}{block}{3}(index,param) = data block values (float)
%               block = data block number
%               index = datapoint index (within data block)
%               param = datapoint parameter number (ie. for complex values,
%                       c=1 real component and c=2 imaginary component)
%
%
% {2} Variables Cell
%
%     {2}{varno}{1} = variable names (string)
%               varno = variable number
%
%     {2}{varno}{2} = variable types (string)
%               varno = variable number
%
%     {2}{varno}{3}(index) = variable values (float)
%               varno = variable number
%               index = variable value index
%
%
% {3} Information Cell
%
%     {3}{1} = CITI file title/name (string)
%
%     {3}{2} = CITI file version (string)
%              (ie. 'A.01.00')
% 


function citicell = citicell_import(fileName,debug)

myFile = fopen(fileName,'r');
if debug, fprintf(['\nImporting CITI data from: %s\n'],fileName), end;

numBlocks = 0;          % Number of data blocks
curBlock = 0;           % Index for looping through data blocks
numPoints = 1;          % Number of data points
curPoint = 0;           % Index for looping through data points/variable values
numVars = 0;            % Number of variables
numVPoints = [];        % Number of variable points for each variable
curVar = 0;             % Index for looping through variables
citicell = {{},{},{}};  % The citicell

% Loop through file and parse each line
while 1
    
    thisLine = fgetl(myFile);           % Grab next line
    if ~ischar(thisLine), break, end;   % Break from loop if end of file

    % Get the CITI file version
    if strcmp(thisLine(1:find(thisLine==' ')),'CITIFILE ')
        citicell{3}{2} = thisLine(find(thisLine==' ')+1:end);
    end
    
    % Get the CITI file title
    if strcmp(thisLine(1:find(thisLine==' ')),'NAME ')
        citicell{3}{1} = thisLine(find(thisLine==' ')+1:end);
    end
        
    % Count the number of datapoints and get variable names and types
    if strcmp(thisLine(1:find(thisLine==' ')),'VAR ')
        numVars = numVars + 1;
        
        % Get variable name
        varLine = thisLine(find(thisLine==' ')+1:end);
        citicell{2}{numVars}{1} = varLine(1:find(varLine==' ')-1);
        
        % Get variable type
        varLine = varLine(find(varLine==' ')+1:end);
        citicell{2}{numVars}{2} = varLine(1:find(varLine==' ')-1);
        
        % Get number of variable points and update total number of datapoints
        varLine = varLine(find(varLine==' ')+1:end);
        numVPoints(numVars) = str2num(varLine);
        numPoints = numPoints * str2num(varLine);
    end

    % Count the number of data blocks and get their names and types
    if strcmp(thisLine(1:find(thisLine==' ')), 'DATA ')
        numBlocks = numBlocks + 1;
        
        % Get datablock name
        dataLine = thisLine(find(thisLine==' ')+1:end);
        citicell{1}{numBlocks}{1} = dataLine(1:find(dataLine==' ')-1);
        
        % Get datablock type
        dataLine = dataLine(find(dataLine==' ')+1:end);
        citicell{1}{numBlocks}{2} = dataLine(1:end);
    end
    
    % Get variable values by finding start of variable blocks
    if strcmp(thisLine, 'VAR_LIST_BEGIN')
        curVar = curVar + 1;
        if debug, fprintf(['Importing Variable Value List %i: %s\n'],curVar,citicell{2}{curVar}{1}), end;
        
        % Loop through all the values for this variable
        for curPoint = 1:numVPoints(curVar)
            thisLine = fgetl(myFile);           % Grab next variable value
            if strcmp(thisLine(1:end), 'VAR_LIST_END')   % If "VAR_LIST_END" appears before we read all expected values, something went wrong!
                fprintf('*** ERROR! Only %i values for variable %i: %s.  Expecting %i values. HALTING. ***\n',curPoint-1,curVar,citicell{2}{curVar}{1},numVPoints(curVar));
                return;
            end
            citicell{2}{curVar}{3}(curPoint) = str2num(thisLine);
        end
        
        thisLine = fgetl(myFile);       % Grab next line
        if ~strcmp(thisLine(1:end), 'VAR_LIST_END')   % If "VAR_LIST_END" isn't the next line, something went wrong!
            fprintf('*** ERROR! Variable %i: %s not ended after the expected %i values.  HALTING. ***\n',curVar,citicell{2}{curVar}{1},numVPoints(curVar));
            return;
        end
    end

    % Get datablock values by finding the start of datablocks
    if strcmp(thisLine(1:end), 'BEGIN')
        curBlock = curBlock + 1;
        if debug, fprintf(['Importing Data Block %i: %s\n'],curBlock,citicell{1}{curBlock}{1}), end;
        
        % Loop through all the data in the data block
        for curPoint = 1:numPoints
            thisLine = fgetl(myFile);           % Grab next datapoint
            if strcmp(thisLine(1:end), 'END')   % If "END" appears before we read all expected data, something went wrong!
                fprintf('*** ERROR! Only %i datapoints in datablock %i: %s.  Expecting %i datapoints. HALTING. ***\n',curPoint-1,curBlock,citicell{1}{curBlock}{1},numPoints);
                return;
            end
            
            % Parse out the CSV values in the data value line
            commas = strfind(thisLine,',');
            commas = [0 commas length(thisLine)+1];
            for curParam = 1:length(commas)-1
                citicell{1}{curBlock}{3}(curPoint,curParam) = str2num(thisLine(commas(curParam)+1:commas(curParam+1)-1));
            end
        end
        
        thisLine = fgetl(myFile);       % Grab next line
        if ~strcmp(thisLine(1:end), 'END')   % If "END" isn't the next line, something went wrong!
            fprintf('*** ERROR! Datablock %i: %s not ended after the expected %i datapoints.  HALTING. ***\n',curBlock,citicell{1}{curBlock}{1},numPoints);
            return;
        end

    end
end
fclose(myFile);    