%% Input

% t                 - time vector of sensors                                [cell{double[]}]
% y                 - sensors measurement vectors                           [cell{double[]}]
% data_type         - general description of evaluated sensors              [cell{}]
%                     {i,1} type of sensor evaluated                        [String]
%                     {i,2} dimension of values of corresponding sensor     [int]
% degree            - maximum degree for polyfit evaluation                 [int]
% num               - maximum number of elements used in polyfit            [int]
%                     evaluation
% gap               - minimum percentage variation to report an anomaly     [double]
% gap_k             - maximum coefficient of linear regression to           [double]
%                     determine constant behaviour
% varp              - average percentage sensors variation                  [cell{int double[]}]
% var2              - variance of sensors                                   [cell{double[]}]
% Pn_1              - covariance matrix of previous process                 [cell{double[]}]
% Rn                - precision matrix of sensors                           [cell{double[]}]
% n_cycle_k         - number of consecutive cycle of Kalman evaluation      [int]

%% Output

% anomaly           - anomalies in the last captured data set               [cell{Boolean[]}]
% y_calc            - output vector of the predicted values                 [cell{double[]}]
% variation         - differences between predicted and measured values     [cell{double[]}]
% varp              - update of input
% var2              - update of input
% Pn_2              - update of input
% n_cycle_k         - update of input

%% Function
function [anomaly, y_calc, variation, varp, var2, Pn_2, n_cycle_k] = find_peaks(t, y, data_type, degree, num, gap, gap_k, varp, var2, Pn_1, Rn, n_cycle_k)
    %% Initialization and sensors check
    
    % Support variables
    [n_sensors, ~] = size(data_type);
    analyse = ones(1,n_sensors);
    
    % columns - number of measures of sensors to analyse                    [int[]]
    columns = zeros(1,n_sensors);
    % rows - number of dimension of sensors to analyse                      [int[]]
    rows = columns;  
    
    anomaly{n_sensors} = [];
    y_calc = anomaly;
    variation = anomaly;
    Pn_2 = anomaly;
    
    % Check for enough elements for each sensor
    for i=1:n_sensors
        [rows_i, columns_i] = size(y{i});
        if columns_i < degree+3
            % Sensors not to be analysed
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
    
    % analyse - index of elements to analyse                                [int[]]
    analyse = find(analyse);
    % n_sensors - number of sensors to analyse                              [int]
    n_sensors = length(analyse);
    
    % No new elements to analyse
    if isempty(analyse)
        return
    end
    
    rows = rows(analyse);
    columns = columns(analyse);
    
    % start - starting index in original vector from which take data        [int]
    start = max(columns-num, 1);
    
    % t_analyse - time vector only of sensor to analyse                     [cell{double[]}]
    t_analyse{length(analyse)} = [];
    % y_analyse - measured values only of sensor to analyse                 [cell{double[]}]
    y_analyse = t_analyse;
    % y_last - last measured values vectors                                 [cell{double[]}]
    y_last = t_analyse;
    
    for i=1:length(analyse)
        t_analyse{i} = t{analyse(i)};
        y_analyse{i} = y{analyse(i)};
        y_last{i} = y_analyse{i}(:,end);
    end
    
    % y_next_p - predicted values vectors with polyfit evaluation           [cell{double[]}]
    % variation_p - differences between predicted and measured values       [cell{double[]}]
    %               of polyfit evaluation
    % m - coefficient of linear regression referred to the last sensor      [double[]]
    [y_next_p, variation_p, m] = poly_fit(t_analyse, y_analyse, start, rows, degree, n_sensors);
    
    % check_k - check if the last sensor has near-constant behavior         [Boolean[]]
    check_k = sum(abs(m)>gap_k);
    
    if check_k == 0
        
        n_cycle_k = n_cycle_k + 1;
        % t_kalman - vector of time used by Kalman evaluation               [double[]]
        t_kalman(n_sensors) = 0;
        % y_kalman - sensor measurament vector used by Kalman evaluation    [double[]]
        y_kalman = zeros(sum(rows),2);
        
        % Support variable to match different dimension elements
        j = 1;
        for i=1:n_sensors
            t_kalman(i) = t_analyse{i}(:,end)-t_analyse{i}(:,end-1);
            y_kalman(j:j+rows(i)-1,:) = y_analyse{i}(:,end-2:end-1);
            j = j+rows(i);
        end
        
        % Q - covariance matrix of measures                                 [double[]]
        Q = diagonalizer(var2);
        
        % Kalman evaluation
        % y_next_tmp - predicted values vector by Kalman evaluation         [double[]]
        % Pn_2_tmp - update of Pn_1 input element                           [double[]]
        [y_next_tmp, Pn_2_tmp] = kalman(t_kalman, y_kalman, diagonalizer(Pn_1), diagonalizer(Rn), Q, data_type);
        
        % Division in cell elements
        % y_next_k - predicted values vector by Kalman evaluation           [cell{double[]}]
        y_next_k{n_sensors} = [];
        % variation_k - differences between predicted and measured values   [cell{double[]}]
        %               of Kalman evaluation
        variation_k = y_next_k;
        % Pn_2 - covariance variation of process                            [cell{double[]}]
        Pn_2 = y_next_k;
        
        j = 1;
        for i=1:n_sensors
            y_next_k{i} = y_next_tmp(j:j+rows(i)-1);
            variation_k{i} = y_next_k{i} - y_analyse{i}(:,end);
            Pn_2{i} = Pn_2_tmp(j:j+rows(i)-1,j:j+rows(i)-1);
            j = j+rows(i);
        end
        
        % anomaly_k - anomalies identified by Kalman evaluation             [cell{Boolean[]}]
        [anomaly_k, ~, ~] = peak_presence(variation_k, y_next_k, y_last, gap, n_sensors);
        
    else
        % No near constant behaviour
        % Reset variables
        n_cycle_k = 0;
        Pn_2{length(Pn_1)} = [];
        for i=1:length(Pn_1)
            Pn_2{i} = 2*eye(size(Pn_1{i}));
        end
    end
    
    % anomaly_p - anomalies identified by polyfit evaluation                [cell{Boolean[]}]
    % varp_tmp - update of input
    % var2_tmp - update of input
    [anomaly_p, varp_tmp, var2_tmp] = peak_presence(variation_p, y_next_p, y_last, gap, n_sensors, varp, var2);    
    
    % Update variables and comparison of the results
    for i=1:n_sensors
        varp{analyse(i)} = varp_tmp{i};
        var2{analyse(i)} = var2_tmp{i};
        
        if n_cycle_k>3
            % Good Kalman evaluation
            anomaly{analyse(i)} = anomaly_p{i} | anomaly_k{i};
            % which - which evaluation is the most efficient                [Boolean[]]
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