%% Input

% t             - contains in each row the value of time of space,velocity  [double[]]
%                 and acceleration
% y             - contains space, velocity and acceleration in column       [double[]]
% degree        - max degree during poly fit evaluation                     [int]
% num           - number of elements evaluating during polyfit              [int]
% gap           - max permissible percentage error                          [double]
% varp_error    - percentage change of error compared to prediction         [double[]]
% var2_error    - avarage squared variation of error composed by noise      [double[]]
%                 and imprecision of polyval
% gap_sva       - max variation to identify a constant                      [double]
% Pn_1          - covariance matrix of past evaluation                      [double[]]
% Rn            - covariance matrix of measurament errors                   [double[]]

%% Output

% anomaly       - presence of anomaly in v_next             [boolean]
% y_next        - next value (predicted)                    [double[]]
% error         - difference between prediction and measure [double[]]
% varp_error    - ...
% var2_error    - ...
% Pn_2          - covariance matrix of next evaluation      [double[]]


%% Function
function [anomaly, y_next, error, varp_error, var2_error, Pn_2] = find_peaks_sva(t, y, degree, num, gap, varp_error, var2_error, gap_sva, Pn_1, Rn)


    [rows, ~] = size(y);
    rows = rows/3;
    
    % not enought elements for polyfit
    if length(t)<degree+3
        anomaly = [false; false; false];
        y_next = y(:,end);
        error = zeros(size(y_next));
        Pn_2 = Pn_1;
        return
    end
    
    start = max(length(t)-num, 1);
    % Vector for polyfit creation and next point evaluation
    t_poly = t(start:end);
    y_poly = y(:,start:end);
    
    % sigma - precision of polyval evaluation [double[]]
    [y_next, error, sigma, m] = poly_fit(t_poly, y_poly, degree);
    
    upper = m(2*rows+1:end)>gap_sva;
    lower = m(2*rows+1:end)<-gap_sva;
    check = sum(upper+lower);
    
    persistent  n_cycle;
    
    if isempty(n_cycle)
       n_cycle = 0; 
    end
    
    if check==0
        n_cycle = n_cycle + 1;
        
        T = t(:,end-1)-t(:,end-2);
        Y = y(:,end-2:end-1);
        % variance^2 of noise of measures (past)
        Q = diag(var2_error);
        
        [y_next_k, Pn_2] = kalman_sva( T, Y, Pn_1, Rn, Q);
        error_k = y_next_k - y(:,end);
        
        anomaly_k = peak_presence_sva(error_k, y_next_k, gap);
    else
        Pn_2 = ones(size(Pn_1));
        n_cycle = 0;
    end
    
    % update varp_error and var2_error with the new point
    error_s = error(1:rows);
    error_v = error(rows+1:2*rows);
    error_a = error(2*rows+1:3*rows);
    
    y_next_s = y_next(1:rows);
    y_next_v = y_next(rows+1:2*rows);
    y_next_a = y_next(2*rows+1:3*rows);
    
    sigma_s = sigma(1:rows);
    sigma_v = sigma(rows+1:2*rows);
    sigma_a = sigma(2*rows+1:3*rows);
    
    varp_error_s = [varp_error(1); varp_error(2:rows+1)];
    varp_error_v = [varp_error(1); varp_error(rows+2:2*rows+1)];
    varp_error_a = [varp_error(1); varp_error(2*rows+2:3*rows+1)];
    
    var2_error_s = var2_error(1:rows);
    var2_error_v = var2_error(rows+1:2*rows);
    var2_error_a = var2_error(2*rows+1:3*rows);
    
    [anomaly_s, varp_error_s, var2_error_s] = peak_presence_general(error_s, y_next_s, gap, sigma_s, varp_error_s, var2_error_s);
    [anomaly_v, varp_error_v, var2_error_v] = peak_presence_general(error_v, y_next_v, gap, sigma_v, varp_error_v, var2_error_v);
    [anomaly_a, varp_error_a, var2_error_a] = peak_presence_general(error_a, y_next_a, gap, sigma_a, varp_error_a, var2_error_a);
    
    varp_error = [varp_error_s; varp_error_v(2:end); varp_error_a(2:end)];
    var2_error = [var2_error_s; var2_error_v; var2_error_a];
    
    anomaly = [anomaly_s; anomaly_v; anomaly_a];
    
    if n_cycle>3
        anomaly = anomaly | anomaly_k;
        error = min(error, error_k);
        
        if error==error_k
            y_next = y_next_k;
        end
    end
end