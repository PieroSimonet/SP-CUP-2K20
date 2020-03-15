%% TO DO

function [varp_error, varp_error_short, var2_error] = calc_var_varp(error, v_next_wz, varp_error, var2_error)
    
    % n - computed element [int]
    n = varp_error(1);
    % average deletion
    varp_error_short = n*varp_error(2:end);
    var2_error = n*var2_error;
    
    % update and average
    n = n+1;
    varp_error_short = (((varp_error_short + abs(error))./abs(v_next_wz)))./n;
    var2_error = (var2_error + error.^2)./n;
    
    varp_error(1) = n;
    varp_error(2:end) = varp_error_short;
    
end