% Export citicell (tm) to CITI File
%   This script is part of the citicell (tm) Library
%   Last update by: Wesley Allen (wnallen@gmail.com)
%                   09 Aug, 2007
%
% Exports data from a citicell (tm) variable to a CITI file.
%
% Use: errorNum = citicell_export(fileName,citicell,debug)
%               fileName = location of file to export to
%               citicell = citicell (tm) variable
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


function errorNum = citicell_export(fileName,citicell,debug)

% Open up the requested file after checking to make sure it doesn't exist
% already.
myFile = fopen(fileName,'r');
if myFile ~= -1
    fprintf('*** ERROR! That file already exists!  Please delete it first. HALTING. ***\n');
    fclose(myFile);
    errorNum = 1;
    return;
end
myFile = fopen(fileName,'wt');

if debug, fprintf('\nExporting CITI data to: %s\n',fileName), end;

% Commented header
if debug, fprintf('Exporting header...\n'), end;
time = clock;
fprintf(myFile,'# Created %s %i:%i:%2.2f\n',date,time(4),time(5),time(6));
fprintf(myFile,'# Using citicell MATLAB Library\n\n');

% CITI file version
% Ex: CITIFILE A.01.00
fprintf(myFile,'CITIFILE %s\n',citicell{3}{2});

% CITI file name/title
% Ex: NAME blockName
fprintf(myFile,'NAME %s\n',citicell{3}{1});

% Variable declarations: loop through variables
% Ex: VAR freq MAG 1601
for curVar = 1:length(citicell{2})
    fprintf(myFile,'VAR %s %s %s\n',citicell{2}{curVar}{1}, ...
                                    citicell{2}{curVar}{2}, ...
                                    num2str(length(citicell{2}{curVar}{3})));
end

% Data block declarations: loop through each data block
% Ex: DATA S[1,1] MAGANGLE
for curBlock = 1:length(citicell{1})
    fprintf(myFile,'DATA %s %s\n',citicell{1}{curBlock}{1}, ...
                                  citicell{1}{curBlock}{2});
end

% Variable values: loop through variables and then variable values
if debug, fprintf('Exporting variable values...\n'), end;
for curVar = 1:length(citicell{2})
    if debug, fprintf('  %s...\n',citicell{2}{curVar}{1}), end;
    fprintf(myFile,'VAR_LIST_BEGIN\n');
    for curPoint = 1:length(citicell{2}{curVar}{3})
        fprintf(myFile,'%18e\n',citicell{2}{curVar}{3}(curPoint));
    end
    fprintf(myFile,'VAR_LIST_END\n');
end

% Data values: loop through data blocks and then data point values
if debug, fprintf('Exporting datablock values...\n'), end;
for curBlock = 1:length(citicell{1})
    if debug, fprintf('  %s...\n',citicell{1}{curBlock}{1}), end;
    fprintf(myFile,'BEGIN\n');
    for curPoint = 1:length(citicell{1}{curBlock}{3})
        for curParam = 1: length(citicell{1}{curBlock}{3}(curPoint,:))
            if curParam > 1
                fprintf(myFile,',');
            end
            fprintf(myFile,'%18e',citicell{1}{curBlock}{3}(curPoint,curParam));
        end
        fprintf(myFile,'\n');
    end
    fprintf(myFile,'END\n');
end

fclose(myFile);

if debug, fprintf('Done.\n\n'), end;
