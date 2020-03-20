%% Input
%               
% T             - time vector (difference between two last measures)        [double[]]
% Y             - sensors measurement vectors (only penultimate and third   [double[]]
%                 last measures)
% Pn_1          - covariance matrix of previous process                     [double[]]
% Rn            - precision matrix of sensors                               [double[]]
% Q             - covariance matrix of measures                             [double[]]
% data_type     - general description of evaluated sensors                  [cell[[String, int]]]
%                 {i,1} type of sensor evaluated
%                 {i,2} dimension of measured values of corresponding sensor

%% Output

% y_next_k      - predicted values vector by Kalman evaluation              [double[]]
% Pn_2          - covariance variation of process                           [cell[double[]]]

%% Function
function [y_next_k, Pn_2] = kalman(T, Y, Pn_1, Rn, Q, data_type)
    
    % Average measurament times
    T_m = sum(T)/length(T);
    
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
    y_now = Y(:,1) + Kn*(Y(:,2)-Y(:,1));
    
    % Covariance of process update
    Pn = (eye(size(Kn)) - Kn)*Pn_1*((eye(size(Kn)) - Kn)') + Kn*Rn*Kn';
    
    % State extrapolation
    y_next_k = F*y_now;
    
    % Covariance of process extrapolation
    Pn_2 = F*Pn*(F') + Q;
    
end