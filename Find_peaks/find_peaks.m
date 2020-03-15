%% TO DO
% t         - {i} time vector of data_type {i,1} sensor
% y         - {i} values of data_type{i,1} sensor
% data_type - {i,1} type of data evaluated
%           - {i,2} number of dimension
% degree    - int
% nume      - int
% varp      - {i} varp of data_type{i,1} sensor
% var2      - {i} var2 of data_type{i,1} sensor
% Pn_1      - {i} Pn_1 of data_type{i,1} sensor

function [anomaly, y_calc, variation, varp, var2, Pn_2, n_cycle_kalman] = find_peaks(t, y, data_type, degree, num, gap, gap_kalman, varp, var2, Pn_1, Rn, n_cycle_kalman)
    
    % general number of sensors
    [n_sensors_g, ~] = size(data_type);
    analyse = ones(1,n_sensors_g);
    columns = zeros(1,n_sensors_g);
    rows = columns;  
    
    anomaly{n_sensors_g} = [];
    y_calc = anomaly;
    variation = anomaly;
    Pn_2 = anomaly;
    
    for i=1:n_sensors_g
        [rows_i, columns_i] = size(y{i});
        if columns_i < degree+3
            anomaly{i} = false;
            y_calc{i} = y{i}(:,end);
            variation{i} = zeros(size(y{i}(:,end)));
            Pn_2{i} = Pn_1{i};
            analyse(i) = false;
        else
            rows(i) = rows_i;
            columns(i) = columns_i;
        end
    end
    
    analyse = find(analyse);
    n_sensors = length(analyse);
    
    if isempty(analyse)
        return
    end
    
    rows = rows(analyse);
    columns = columns(analyse);
    
    
    start = max(columns-num, 1);
    
    t_analyse{length(analyse)} = [];
    y_analyse = t_analyse;
    y_last = t_analyse;
    
    for i=1:length(analyse)
        t_analyse{i} = t{analyse(i)};
        y_analyse{i} = y{analyse(i)};
        y_last{i} = y_analyse{i}(:,end);
    end
    
    % y_next_p - next value (evaluated with polyfit)
    % variation_p - difference between measure e y_next_p
    % sigma - precision of polyval evaluation
    % m - coefficient of linear regression
    [y_next_p, variation_p, m] = poly_fit(t_analyse, y_analyse, start, rows, degree);
    % kalman activation
    check_k = sum(abs(m)>gap_kalman);
    
    if check_k == 0
        n_cycle_kalman = n_cycle_kalman + 1;
        
        t_kalman(n_sensors) = 0;
        y_kalman = zeros(sum(rows),2);
        j = 1;
        for i=1:n_sensors
            t_kalman(i) = t_analyse{i}(:,end)-t_analyse{i}(:,end-1);
            y_kalman(j:j+rows(i)-1,:) = y_analyse{i}(:,end-2:end-1);
            j = j+rows(i);
        end
        Q = diagonalizer(var2);
        
        [y_next_tmp, Pn_2_tmp] = kalman(t_kalman, y_kalman, diagonalizer(Pn_1), diagonalizer(Rn), Q, data_type);
        
        y_next_k{n_sensors} = [];
        variation_k = y_next_k;
        Pn_2 = y_next_k;
        j = 1;
        
        for i=1:n_sensors
            y_next_k{i} = y_next_tmp(j:j+rows(i)-1);
            variation_k{i} = y_next_k{i} - y_analyse{i}(:,end);
            Pn_2{i} = Pn_2_tmp(j:j+rows(i)-1,j:j+rows(i)-1);
            j = j+rows(i);
        end
        
        [anomaly_k, ~, ~] = peak_presence(variation_k, y_next_k, y_last, gap, n_sensors);
        
    else
        n_cycle_kalman = 0;
        Pn_2{length(Pn_1)} = [];
        for i=1:length(Pn_1)
            Pn_2{i} = eye(size(Pn_1{i}));%---------------------------------
        end
    end
    
    [anomaly_p, varp_tmp, var2_tmp] = peak_presence(variation_p, y_next_p, y_last, gap, n_sensors, varp, var2);    
    
    for i=1:n_sensors
            
        varp{analyse(i)} = varp_tmp{i};
        var2{analyse(i)} = var2_tmp{i};
        
        if n_cycle_kalman>3
            anomaly{analyse(i)} = anomaly_p{i} | anomaly_k{i};
            which = (abs(variation_p{i})<abs(variation_k{i}));
            variation{analyse(i)} = which.*variation_p{i}+(1-which).*variation_k{i};
            y_calc{analyse(i)} = which.*y_next_p{i}+(1-which).*y_next_k{i};
        else
            anomaly{analyse(i)} = anomaly_p{i};
            y_calc{analyse(i)} = y_next_p{i};
            variation{analyse(i)} = variation_p{i};
        end
    end
end


function out = diagonalizer(data)
    
    if isempty(data)
        out = [];
        return
    end
    
    n_elem = [0, 0];
    
    for i = 1:length(data)
        [rows, columns] = size(data{i});
        if rows==1 || columns == 1
            n_elem = n_elem + max(rows,columns)*ones(1,2);
        else
        n_elem = n_elem + size(data{i});
        end
    end
    
    out = zeros(n_elem);
    i = 1;
    j = 1;
    for k=1:length(data)
        [rows,columns] = size(data{k});
        if rows==1 || columns == 1
            index = max(rows,columns);
            out(i:i+index-1,j:j+index-1) = diag(data{k});
            i = i+index;
            j = j+index;
        else
        	out(i:i+rows-1,j:j+columns-1) = data{k};
            i = i+rows;
            j = j+columns;
        end
    end
end