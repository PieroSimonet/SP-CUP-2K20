function [hadNext] = HaveNextFrame(fileName)
%GETNEXTFRAME update the index that see next frame in time
%   Detailed explanation goes here

    hadNext = false;

    persistent oldLength;
    if isempty(oldLength)
        oldLength = -1;
    end

    % Forse c'e' di meglio ma per ora va bene così
    msg = GetDataFromCurrentFrame(fileName,'/mavros/battery',true);

    nowLength = length(msg);

    if oldLength <= nowLength
        hadNext = true;
        oldLength = nowLength;
    end

end

