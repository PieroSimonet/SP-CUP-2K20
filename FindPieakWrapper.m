function [anomaly] = FindPieakWrapper(time,data)
%FIT Summary of this function goes here
%   Detailed explanation goes here

    anomaly = false;

    if length(data) > 2
        degree = 2;
        gap = 0.5;
        
        num = 20;
        
        if length(data) < 20
            num = length(data)-1;
        end

        [rows, ~] = size(data);
        var_forest = [0; zeros(rows, 1)];

        % [anomaly, v_forest, v_calc, var_forest] 
        [anomaly, ~, ~, ~]= find_peaks(time, data, degree, gap, num, var_forest);
    end

end

