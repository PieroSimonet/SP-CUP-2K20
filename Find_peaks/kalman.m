%% TO DO
function [y_next_k, Pn_2] = kalman(T, Y, Pn_1, Rn, Q, data_type)
    
    % average of different values of measurement time
    T_m = sum(T)/length(T);
    
    [rows_data,~] = size(data_type);
    F = [];
    F_tmp = [];
    
    % creation of state transition matrix
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
    
    % state update equation
    y_now = Y(:,1) + Kn*(Y(:,2)-Y(:,1));
    
    % covariance update
    Pn = (eye(size(Kn)) - Kn)*Pn_1*((eye(size(Kn)) - Kn)') + Kn*Rn*Kn';
    
    % state extrapolation
    y_next_k = F*y_now;
    
    % covariance extrapolation
    Pn_2 = F*Pn*(F') + Q;
    
end