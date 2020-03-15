%% TO DO

% out [already_analysed, data_type]
function [already_analysed, anomaly_out, first_index_out, variation, y_calc, data_type] = FindPeaksWrapper(t, y, type, degree, num, gap, gap_kalman)
    
    % general variables
    [rows_input, columns_input] = size(y);
    
    % dataType - {i,1} type of data evaluated
    %          - {i,2} number of dimension
    
    persistent dataType;    
    persistent varp;
    persistent var2;
    persistent Pn_2;
    persistent Rn;
    persistent n_cycle_kalman;
    persistent anomaly;

    %% Initialization system variables
    if isempty(dataType)
        dataType{1,1} = type;
        dataType{1,2} = rows_input;
        varp{1} = zeros(rows_input+1,1);
        var2{1} = zeros(rows_input,1);
        Pn_2{1} = eye(rows_input); %---------------------------------------
        Rn{1} = eye(rows_input); %-----------------------------------------
        n_cycle_kalman(1) = 0;
        anomaly{1} = [];
    end
    
    %% Search
    index = 0;
    
    [rows_data, ~] = size(dataType);
    
    for i=1:rows_data
        if dataType{i,1} == type
            index = i;
            break
        end
    end
    
    %% New element
    if index == 0
        index = rows_data+1;
        dataType{index,1} = type;
        dataType{index,2} = rows_input;
        varp{index} = zeros(rows_input+1,1);
        var2{index} = zeros(rows_input,1);
        Pn_2{index} = eye(rows_input); %-----------------------------------
        Rn{index} = eye(rows_input); %-------------------------------------
        n_cycle_kalman(index) = 0;
        anomaly{index} = [];
    end
    
    %% Already analysed
    already_analysed = false;
    
    if length(anomaly{index})>= columns_input %----------------------------
        already_analysed = true;
        anomaly_out{1} = anomaly{index}(columns_input);
        first_index_out = columns_input;
        variation = 0;
        y_calc = 0;
        data_type{1,1} = dataType{index,1};
        data_type{1,2} = dataType{index,2};
        return
    end
    
    %% Fill data_type and peaks search
    data_type{1,1} = dataType{index,1};
    data_type{1,2} = dataType{index,2};
    varp_tmp{1} = varp{index};
    var2_tmp{1} = var2{index};
    Pn_2_tmp{1} = Pn_2{index};
    Rn_tmp{1} = Rn{index};
        
    y_calc{1} = [];
    variation = y_calc;
    anomaly_out = y_calc;
        
    for i=length(anomaly{index})+1:columns_input
        t_type{1} = t(1:i);
    	y_type{1} = y(:,1:i);
        [anomaly_tmp, y_calc_tmp, variation_tmp, varp_tmp, var2_tmp, Pn_2_tmp, n_cycle_kalman(index)] = find_peaks(t_type, y_type, data_type, degree, num, gap, gap_kalman, varp_tmp, var2_tmp, Pn_2_tmp, Rn_tmp, n_cycle_kalman(index));
        y_calc{1} = [y_calc{1} y_calc_tmp{1}];
        variation{1} = [variation{1} variation_tmp{1}];
        anomaly_out{1} = [anomaly_out{1} anomaly_tmp{1}];
    end
        
    first_index_out = length(anomaly{index})+1;
    anomaly{index} = [anomaly{index} anomaly_out{1}];
    varp{index} = varp_tmp{1};
    var2{index} = var2_tmp{1};
    Pn_2{index} = Pn_2_tmp{1};
    
end