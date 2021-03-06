function [newNumForest, numElementForest, degree, num, gap, gap_sva, time] = OptimizeParameter()
%OPTIMIZEPARAMETER Summary of this function goes here
%   Detailed explanation goes here
    [~, minute, second] = getDifferenceInTime();
    time = second + minute * 60;

    newNumForest = updateNumForest(time);
    degree = updateDegree(time);
    numElementForest = updateElementForest(time);
    num = degree + 5;
    gap = updateGap(time); 
    gap_sva = updateGapSva(time);

end

function newNumForest = updateNumForest(diffTime)
    persistent numForest;
    if isempty(numForest)
        numForest = 90;
    end
    if diffTime > 3
        numForest = numForest - 5;
    elseif diffTime < 0.70
        numForest = numForest + 15;
    end

    if numForest < 60
        numForest = 60;
    end

    if numForest > 120
        numForest = 120;
    end

    newNumForest = numForest;
end

function newGap = updateGap(diffTime)
    persistent Gap;
    if isempty(Gap)
        Gap = 0.1;
    end
    if diffTime > 3
        Gap = Gap + 0.5;
    elseif diffTime < 0.35
        Gap = Gap  - 0.5;
    end

    if Gap < 0.1
        Gap = 0.1;
    end

    if Gap > 0.7
        Gap = 0.7;
    end

    newGap = Gap;
end


function newGapSva = updateGapSva(diffTime)
    persistent gapSva;
    if isempty(gapSva)
        gapSva = 0.2;
    end
    if diffTime > 3
        gapSva = gapSva - 0.05;
    elseif diffTime < 0.70
        gapSva = gapSva + 0.05;
    end
    
    % upperand lower bound
    if gapSva < 0.05
        gapSva = 0.05;
    else
        if gapSva>0.3
            gapSva = 0.3;
        end
    end
    newGapSva = gapSva;
end

function numElementForest = updateElementForest(diffTime)
    persistent elementForest;
    if isempty(elementForest)
        elementForest = 40;
    end
    if diffTime > 3
        elementForest = elementForest - 5;
    elseif diffTime < 0.70
        elementForest = elementForest + 15;        
    end

    if elementForest < 30
        elementForest = 30;
    end

    if elementForest > 60
        elementForest = 60;
    end

    numElementForest = elementForest;
end

function newDegree = updateDegree(diffTime)
    persistent degree;
    if isempty(degree)
        degree = 3;
    end
    if diffTime > 3
        degree = degree - 1;
    elseif diffTime < 0.70
        degree = degree + 1;
    end

    if degree < 2
        degree = 1;
    else
        if degree > 3
            degree = 3;
        end
    end

    newDegree = degree;
end

%degree = 2; % 1 - 4
%num = 5; %degree + 3 - 20
%gap = 0.2; % prox 0
%gap_sva = 0.1; %  prox 0 


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
