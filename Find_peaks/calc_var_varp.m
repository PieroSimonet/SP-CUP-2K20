%% Input

% error         - difference between prediction and measure             [double[]]
% v_next_wz     - v_next with zero replaced with 1(Without Zero)        [double[]]
% varp_error    - percentage change of error compared to prediction     [double[]]
% var2_error    - avarage squared variation of error                    [double[]]
%               - composed by noise and imprecision of polyval

%% Output

% varp_error        - ...
% varp_error_short  - varp_error without the first element (n)      [double[]]
% var2_error        - ...

%% Function
function [varp_error, varp_error_short, var2_error] = calc_var_varp(error, v_next_wz, varp_error, var2_error)
    
    % n - computated element [int]
    n = varp_error(1);
    % average deletion
    varp_error_short = n*varp_error(2:end);
    var2_error = n*var2_error;
    
    % update and average
    n = n+1;
    varp_error_short = ((varp_error_short + abs(error))./abs(v_next_wz))./n;
    var2_error = (var2_error + error.^2)./n;
    
    varp_error(1) = n;
    varp_error(2:end) = varp_error_short;
    
end