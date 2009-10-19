% Converts Values to single Complex Number
%   This script is part of the citicell (tm) Library
%   Last update by: Wesley Allen (wnallen@gmail.com)
%                   10 Aug, 2007
%
% Two parameters of a number are passed along with its CITI value type.
% The parameters are converted to a single complex number and returned.
%
% Use: complexVal = citicell_toComplex(valA,valB,valType)
%           valA = first number parameter (can be matrix)
%           valB = second number parameter (can be matrix)
%           valType = CITI value type as string
%               valType         valA        valB
%               MAGANGLE        Magnitude   Angle (deg)
%

function complexVal = citicell_toComplex(valA,valB,valType)

% MAGANGLE conversion
if strcmp(valType,'MAGANGLE')
    valB = valB .* pi ./ 180;     % Degrees -> radian
    complexVal = valA .* cos(valB) + j.*(valA .* sin(valB));
    return;
end

complexVal = [];
fprintf('*** ERROR! valType ''%s'' not known. HALTING. ***\n',valType);