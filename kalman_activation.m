%% Input

% data - main structure where all the data are located [cell[]]
%      - data{i,1}: measures
%        data{i,2}: time vector
%        data{i,3}: data_type

%% Output

% kalman_ok - 1st element: activation Kalman filter for "sva_l" [Boolean[]]
%           - 2nd element: activation Kalman filter for "sva_a"

%% Function
function kalman_ok = kalman_activation(data)
    
    % min - minimum allowable ratio (%)
    %       (es. 0.99 - numerator 1% lower than the denominator)
    min = 0;
    
    % max - maximum allowable ratio (%)
    %       (es. 1.01 - numerator 1% higher than the denominator)
    max = 0; 
    
    
    % index of elements in data
    % static values - performance improvement
    s_index = 0;
    vl_index = 0;
    al_index = 0;
    
    a_index = 0;
    va_index = 0;
    aa_index = 0;
    
    s_T = (data{s_index,2}(end)- data{s_index,2}(end))/length(data{s_index,2});
    vl_T = (data{vl_index,2}(end)- data{vl_index,2}(end))/length(data{vl_index,2});
    al_T = (data{al_index,2}(end)- data{al_index,2}(end))/length(data{al_index,2});
    
    a_T = (data{a_index,2}(end)- data{a_index,2}(end))/length(data{a_index,2});
    va_T = (data{va_index,2}(end)- data{va_index,2}(end))/length(data{va_index,2});
    aa_T = (data{aa_index,2}(end)- data{aa_index,2}(end))/length(data{aa_index,2});
    
    ratio = [s_T/vl_T , a_T/va_T; s_T/al_T , a_T/aa_T; vl_T/al_T , va_T/aa_T];
    
    upper = ratio > max;
    lower = ratio < min;
    
    check = sum(upper+lower);
    
    % small changes between difference sampling periods
    % -> in small quantity of data, there isn't difference between start
    %    time and vector end time
    kalman_ok = check==0;

end