%% Input

% t_poly    - time vector                              [double[]]
% y_poly    - measures (length(y_poly) = num)          [double[]]
% degree    - max degree during poly fit evaluation    [int]

%% Output

% v_next    - next value (predicted)                        [double[]]
% error     - difference between prediction and measure     [double[]]
% sigma     - precision of polyval evaluation               [double[]]
% m         - coefficient of linear regression              [double[]]

%% Function
function [v_next, error, sigma, m] = poly_fit(t_poly, y_poly, degree)
    
    [rows, ~] = size(y_poly);
    error = zeros(rows,1);
    sigma = zeros(rows,1);
    m = zeros(rows,1);
    
    t = t_poly(1:end-1);
    value = y_poly(:,1:end-1);
    
    for i=1:rows
       [pol, S] = polyfit(t, value(i,:), degree); 
       
       m(i) = polyval(pol(1:end-1), t_poly(end));
       [next, SQM] = polyval(pol, t_poly(end),S);
       
       error(i) = next-y_poly(i,end);
       sigma(i) = SQM;
       
    end
    
    v_next = y_poly(:,end) + error;
end