% Converts Values to single CITI value type
%   This script is part of the citicell (tm) Library
%   Last update by: Wesley Allen (wnallen@gmail.com)
%                   10 Aug, 2007
%
% A complex number and a CITI value type are passed.  The correspond CITI
% values are returned.
%
% Use: [valA,valB] = citicell_toValType(complexVal,valType)
%           complexVal = complex number to convert (can be matrix)
%           valType = CITI value type as string
%               valType         valA        valB
%               MAGANGLE        Magnitude   Angle (deg)
%

function [valA,valB] = citicell_toValType(complexVal,valType)

% MAGANGLE conversion
if strcmp(valType,'MAGANGLE')
    valA = abs(complexVal);
    valB = angle(complexVal) .* 180 ./ pi;
    return;
end

valA = [];
valB = [];
fprintf('*** ERROR! valType ''%s'' not known. HALTING. ***\n',valType);