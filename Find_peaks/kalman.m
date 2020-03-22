%% Input

% t_kalman          - vector of time used by Kalman evaluation              [double[]]
% y_kalman          - sensor measurament vector used by Kalman evaluation   [double[]]
% Pn_1              - covariance matrix of previous process                 [double[]]
% Rn                - precision matrix of sensors                           [double[]]
% Q                 - covariance matrix of measures                         [double[]]
% data_type         - general description of evaluated sensors              [cell{}]
%                     {i,1} type of sensor evaluated                        [String]
%                     {i,2} dimension of values of corresponding sensor     [int]

%% Output

% y_next_k          - predicted values vector by Kalman evaluation          [double[]]
% Pn_2              - covariance variation of process                       [double[]]

%% Function
function [y_next_k, Pn_2] = kalman(t_kalman, y_kalman, Pn_1, Rn, Q, data_type)
    
    % Average measurament times
    T_m = sum(t_kalman)/length(t_kalman);
    
    [rows_data,~] = size(data_type);
    F = [];
    F_tmp = [];
    
    % Creation of state transition matrix
    for i=1:rows_data
        for j=1:rows_data
            if j<i
                F_tmp = [F_tmp zeros(data_type{i,2},data_type{j,2})];
            else
                F_tmp = [F_tmp (T_m^(j-i)/factorial(j-i)).*eye(data_type{i,2},data_type{j,2})];
            end
        end
        F = [F ; F_tmp];
        F_tmp = [];
    end
    
    % Kalman gain
    Kn = Pn_1/(Pn_1 + Rn);
    
    % State update equation
    y_now = y_kalman(:,1) + Kn*(y_kalman(:,2)-y_kalman(:,1));
    
    % Covariance of process update
    Pn = (eye(size(Kn)) - Kn)*Pn_1*((eye(size(Kn)) - Kn)') + Kn*Rn*Kn';
    
    % State extrapolation
    y_next_k = F*y_now;
    
    % Covariance of process extrapolation
    Pn_2 = F*Pn*(F') + Q;
    
end