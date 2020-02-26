function boh = tmp(input, argument)
%myFun - Description
%
% Syntax: boh = tmp(input)
%
% Long description
    persistent seenArgument;
    persistent returningArray;
    if isempty(seenArgument)
        seenArgument{1} = argument;
        returningArray{1} = [];
    end

    isSeenArgument = false;
    SeenArgumentIndex = -1;

    for index = 1 : length(seenArgument)
        if seenArgument{index} == argument
            isSeenArgument = true;
            SeenArgumentIndex = index;
        end
    end

    if not(isSeenArgument)
        SeenArgumentIndex = length(seenArgument) + 1;
        seenArgument{SeenArgumentIndex} = argument;
        returningArray{SeenArgumentIndex} = [];
    end

    returningArray{SeenArgumentIndex} = [returningArray{SeenArgumentIndex} input];

    boh = returningArray{SeenArgumentIndex};

end