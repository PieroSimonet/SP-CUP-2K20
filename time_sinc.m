%% Input

% time1 - main time vector                                          [double[]]
% time2 - secondary time vector                                     [double[]]
% elem1 - index of one element of time1 (0<elem1<length(time1)+1)   [int]

%% Output

% elem2 - index of the element (or the nearest) of time2 >= time1(elem1)    [int]

%% Function
% binary search
% if the exact value can't be find, the function returns the nearest higher value
function elem2 = time_sinc(time1, time2, elem1)
    
    % search - time to search in time2 array
    search = time1(elem1);
    sx = 1;
    dx = length(time2);
    
    while(sx~=dx-1)
        
        elem2 = ceil((dx+sx)/2);
        
        if time2(elem2) == search
            return
        else
            if time2(elem2) >= search
                dx = elem2;
            else
                sx = elem2;
            end
        end
    end
    
    if sx==dx-1
        elem2 = dx;
    end
end