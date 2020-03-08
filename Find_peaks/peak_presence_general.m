%% Input

% error         - difference between prediction and measure             [double[]]
% v_next        - next value (predicted)                                [double[]]
% gap           - maximum permissible percentage error                  [double]
% sigma         - precision of polyval evaluation                       [double[]]
% varp_error    - percentage change of error compared to prediction     [double[]]
% var2_error    - avarage squared variation of error                    [double[]]
%               - composed by noise and imprecision of polyval

%% Output

% anomaly       - presence of anomaly in v_next     [boolean]
% varp_error    - ...
% var2_error    - ...

%% Function
function [anomaly, varp_error, var2_error] = peak_presence_general(error, v_next, gap, sigma, varp_error, var2_error)
    
    v_next_z = v_next==0;
    % v_next with zero replaced with 1(Without Zero) (necesary for division)
    v_next_wz = v_next + v_next_z;
    
    % percentual error of polyval
    Sigma = abs(sigma./v_next_wz);
    
    [varp_error, varp_error_short, var2_error] = calc_var_varp( error, v_next_wz, varp_error, var2_error);
    
    % for a good average
    if varp_error(1)<3
        varp_error_short = zeros(size(varp_error_short));
    end
    
    % delta - max percentage change [double[]]
    delta = max([gap*ones(size(error)), varp_error_short, Sigma], [], 2);
    
    error_p = error./v_next_wz;
    
    % |percentage error|>delta
    upper = error_p>delta;
    lower = error_p<-delta;
    
    check = sum(upper+lower);
    
    anomaly = check>0;
end