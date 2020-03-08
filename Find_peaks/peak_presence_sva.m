%% Input

% error         - difference between prediction and measure     [double[]]
% v_next        - next value (predicted)                        [double[]]
% gap           - maximum permissible percentage error          [double]

%% Output

% anomaly_k     - presence of anomaly in v_next     [boolean]

%% Function
function anomaly = peak_presence_sva(error, v_next, gap)
    
    [rows, columns] = size(error);
    rows = rows/3;
    
    v_next_z = v_next==0;
    % v_next with zero replaced with 1(Without Zero) (necesary for division)
    v_next_wz = v_next + v_next_z;
    
    % delta - max percentage change [double[]]
    delta = gap*ones(rows*3,columns);
    
    error_p = error./v_next_wz;
    
    % |percentage error|>delta
    upper = error_p>delta;
    lower = error_p<-delta;
    
    % sum - sum matrix to estrapolate anomaly from space, velocity and acceleration
    sum_m = [ones(1,rows), zeros(1,2*rows);
             zeros(1,rows), ones(1,rows), zeros(1,rows);
             zeros(1,2*rows), ones(1,rows)];
    
    check = sum_m*(upper+lower);
    
    anomaly = check>0;
end