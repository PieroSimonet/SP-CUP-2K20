function [newNumForest] = OptimizeParameter(numForest)
%OPTIMIZEPARAMETER Summary of this function goes here
%   Detailed explanation goes here
    [hour,minute,second] = getDifferenceInTime();
    if isTooLong(hour,minute,second)
        disp(minute);
        disp(second);
        % newNumForest = round(numForest * 0.9); 
    else
        % newNumForest = numForest + 5;
    end

    newNumForest = numForest;
end

function [hour,minute,second] = getDifferenceInTime()
    persistent oldTime;
    if isempty(oldTime)
        oldTime = clock;
    end
    nowTime = clock;
    diff    = nowTime - oldTime;
    hour    = diff(4);
    minute  = diff(5);
    second  = diff(6);

    % MATLAB è lezzo
    if second < 0
        second = 60 + second;
        minute = minute - 1;
    end

    if minute < 0
        minute = 60 - minute;
        hour = hour - 1;
    end

    oldTime = clock;
end

function bool = isTooLong(hour,minute,second)
    bool = false;
    if second > 3
        bool = true;
    elseif minute > 0
        bool = true;
    elseif hour > 0
        bool = true;
    end
end
