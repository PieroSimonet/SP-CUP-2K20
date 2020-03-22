%% Input

% variation         - differences between predicted and measured values     [double[]]
% var2              - average squared variance of sensors                   [double[]]

%% Output

% var2              - update of input

%% Function
function var2 = calc_var(variation, var2)
    
    % n - computed element [int]
    n = var2(1);
    
    % Average deletion
    var2_tmp = n*var2(2:end);
    
    % Update variables and new averages
    n = n+1;
    var2 = [n; (var2_tmp + variation.^2)./n];
    
end