%% Input

% variation         - differences between predicted and measured values     [double[]]
% y_next_wz         - predicted values vector (without zero elements)       [double[]] 
% varp              - average percentage sensor variation                   [int double[]]
% var2              - variance of sensor                                    [double[]]

%% Output

% varp              - update of input
% varp_short        - varp without first element                            [double[]]
% var2              - update of input

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