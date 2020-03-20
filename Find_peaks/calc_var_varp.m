%% Input

% variation     - differences between predicted and measured values         [cell[double[]]]
% y_next_wz     - predicted values vector (without zero elements)           [double[]]
% varp          - percentage sensors variation                              [cell[double[]]]
% var2          - variance of sensors                                       [cell[double[]]]

%% Output

% varp          - percentage sensors variation                              [cell[double[]]]
% varp_short    - varp without first element (number of elements analized)  [double[]]
% var2          - variance of sensors                                       [cell[double[]]]

%% Function
function [varp, varp_short, var2] = calc_var_varp(variation, y_next_wz, varp, var2)
    
    % n - computed element [int]
    n = varp(1);
    % Average deletion
    varp_short = n*varp(2:end);
    var2 = n*var2;
    
    % Update variables and new averages
    n = n+1;
    varp_short = (((varp_short + abs(variation))./abs(y_next_wz)))./n;
    var2 = (var2 + variation.^2)./n;
    
    varp(1) = n;
    varp(2:end) = varp_short;
    
end