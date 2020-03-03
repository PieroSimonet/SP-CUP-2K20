%% Input

% t             - time                                                  [double[]]
% y             - measures                                              [double[]]
% degree        - max degree during poly fit evaluation                 [int]
% num           - number of elements evaluating during polyfit          [int]
% gap           - maximum permissible percentage error                  [double]
% varp_error    - percentage change of error compared to prediction     [double[]]
% var2_error    - avarage squared variation of error                    [double[]]
%               - composed by noise and imprecision of polyval

%% Output

% anomaly       - presence of anomaly in v_next                 [boolean]
% v_next        - next value (predicted)                        [double[]]
% error         - difference between prediction and measure     [double[]]
% varp_error    - ...
% var2_error    - ...

%% Function
function [anomaly, y_next, error, varp_error, var2_error] = find_peaks_general(t, y, degree, num, gap, varp_error, var2_error)
    
    % not enought elements for polyfit
    if length(t)<degree+3
        anomaly = false;
        y_next = y(:,end);
        error = zeros(size(y_next));
        return
    end
    
    start = max(length(t)-num, 1);
    % Vector for polyfit creation and next point evaluation
    t_poly = t(start:end);
    y_poly = y(:,start:end);
    
    % sigma - precision of polyval evaluation [double[]]
    [y_next, error, sigma, ~] = poly_fit(t_poly, y_poly, degree);
    
    [anomaly, varp_error, var2_error] = peak_presence_general(error, y_next, gap, sigma, varp_error, var2_error);
    
end