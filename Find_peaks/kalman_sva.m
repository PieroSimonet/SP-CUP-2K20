%% Input

% T - variation of time between two past measures                   [double[]]
% Y - values of space, velocity and acceleration (past, past-past)  [double[]]
% Pn_1 - covariance matrix of past evaluation                       [double[]]
% Rn - covariance matrix of measurament errors                      [double[]]
% Q - variance^2 of noise of measures (past)                        [doubel[]]

%% Output

% y_next_k  - next value (predicted by Kalman)      [double[]]
% Pn_2      - covariance matrix of next evaluation  [double[]]

%% Function
function [y_next_k, Pn_2] = kalman_sva(T, Y, Pn_1, Rn, Q)
    
    [rows, ~] = size(Pn_1);
    rows = rows/3;
    
    one = ones(1,3*rows);
    
    % average of different values of measurament time
    T_m = sum(T)/length(T);
    
    deltaT = T_m*ones(1,2*rows);
    deltaT_2 = T_m^2*ones(1,rows);
    
    %  state transition matrix
    F = diag(one) + diag(deltaT, rows) + diag(deltaT_2, 2*rows);
    
    % Kalman gain
    Kn = Pn_1/(Pn_1 + Rn);
    
    % state update equation
    y_now = Y(:,1) + Kn*(Y(:,2)-Y(:,1));
    
    % covariance update
    Pn = (eye(size(Kn)) - Kn)*Pn_1*((eye(size(Kn)) - Kn)') + Kn*Rn*Kn';
    
    % state extrapolation
    y_next_k = F*y_now;
    
    % covariance extrapolation
    Pn_2 = F*Pn*(F') + Q;
    
end