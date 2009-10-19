% Splits S-Params of citicell (tm)
%   This script is part of the citicell (tm) Library
%   Last update by: Wesley Allen (wnallen@gmail.com)
%                   10 Aug, 2007
%
% Translates a citicell to Transfer Parameters, splits it into two
% components equal to the original when put in series, and translates these
% components back into S-Parameter citicells.
%
% Assumes:
%           S[1,1] = data block 1
%           S[1,2] = data block 2
%           S[2,1] = data block 3
%           S[2,2] = data block 4
%
% Use: [citicellOutA,citicellOutB] = citicell_split(citicellIn,sizeA)
%           citicellOutA = citicell to output front of split
%           citicellOutB = citicell to output back of split
%           citicellIn = citicell that is to be split
%           sizeA = portion of citicellIn to be split to citicellOutA (0-1)
%

function [citicellOutA,citicellOutB] = citicell_split(citicellIn,sizeA)


if (sizeA <= 0) || (sizeA >=1)
    fprintf('*** ERROR! sizeA must be between 0 and 1 (exclusively).  HALTED. ***\n');
    return;
end

% Set the output variables to be the same as the input variable
citicellOutA = citicellIn;
citicellOutB = citicellIn;

% Get complex value of parameters
S11 = citicell_toComplex(citicellIn{1}{1}{3}(:,1),citicellIn{1}{1}{3}(:,2),citicellIn{1}{1}{2});
S12 = citicell_toComplex(citicellIn{1}{2}{3}(:,1),citicellIn{1}{2}{3}(:,2),citicellIn{1}{2}{2});
S21 = citicell_toComplex(citicellIn{1}{3}{3}(:,1),citicellIn{1}{3}{3}(:,2),citicellIn{1}{3}{2});
S22 = citicell_toComplex(citicellIn{1}{4}{3}(:,1),citicellIn{1}{4}{3}(:,2),citicellIn{1}{4}{2});

% Convert to T-Parameters
T11 = -(S11.*S22 - S12.*S21)./S21;
T12 = S11./S21;
T21 = -S22./S21;
T22 = 1./S21;

% Split T-Parameters
for tIndex = 1:length(T11)
    T = [T11(tIndex),T12(tIndex);T21(tIndex),T22(tIndex)];

    TA = T^(sizeA);
    T11A(tIndex) = TA(1,1);
    T12A(tIndex) = TA(1,2);
    T21A(tIndex) = TA(2,1);
    T22A(tIndex) = TA(2,2);
    
    TB = T^(1-sizeA);
    T11B(tIndex) = TB(1,1);
    T12B(tIndex) = TB(1,2);
    T21B(tIndex) = TB(2,1);
    T22B(tIndex) = TB(2,2);
end

% Convert back to S-Parameters
S11A = T12A./T22A;
S12A = (T11A.*T22A-T12A.*T21A)./T22A;
S21A = 1./T22A;
S22A = -T21A./T22A;

S11B = T12B./T22B;
S12B = (T11B.*T22B-T12B.*T21B)./T22B;
S21B = 1./T22B;
S22B = -T21B./T22B;

% Store into citicell output variables
[citicellOutA{1}{1}{3}(:,1),citicellOutA{1}{1}{3}(:,2)] = ...
    citicell_toValType(S11A,citicellOutA{1}{1}{2});
[citicellOutA{1}{2}{3}(:,1),citicellOutA{1}{2}{3}(:,2)] = ...
    citicell_toValType(S12A,citicellOutA{1}{2}{2});
[citicellOutA{1}{3}{3}(:,1),citicellOutA{1}{3}{3}(:,2)] = ...
    citicell_toValType(S21A,citicellOutA{1}{3}{2});
[citicellOutA{1}{4}{3}(:,1),citicellOutA{1}{4}{3}(:,2)] = ...
    citicell_toValType(S22A,citicellOutA{1}{4}{2});

[citicellOutB{1}{1}{3}(:,1),citicellOutB{1}{1}{3}(:,2)] = ...
    citicell_toValType(S11B,citicellOutB{1}{1}{2});
[citicellOutB{1}{2}{3}(:,1),citicellOutB{1}{2}{3}(:,2)] = ...
    citicell_toValType(S12B,citicellOutB{1}{2}{2});
[citicellOutB{1}{3}{3}(:,1),citicellOutB{1}{3}{3}(:,2)] = ...
    citicell_toValType(S21B,citicellOutB{1}{3}{2});
[citicellOutB{1}{4}{3}(:,1),citicellOutB{1}{4}{3}(:,2)] = ...
    citicell_toValType(S22B,citicellOutB{1}{4}{2});