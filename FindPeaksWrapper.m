%% TO DO

% type - type of data [String]
% kalman_ok - (1,:) [update, start, end, common cycles] linear
%           - (2,:) [update, start, end, common cycles] angular

% out [already_analysed, data_type]
function [already_analysed, anomaly_out, first_index_out, variation, y_calc, data_type, kalman_ok] = FindPeaksWrapper(t, y, type, degree, num, gap, gap_kalman, kalman_ok)
    %% General variables
    [rows_input, columns_input] = size(y);
    
    % dataType - {i,1} type of data evaluated
    %          - {i,2} number of dimension
    
    persistent dataType;
    
    % variabile di supporto nel caso in cui sia necessario Kalman
    % persistent data_Type;
    
    persistent varp;
    persistent var2;
    persistent Pn_2;
    persistent Rn;
    persistent n_cycle_kalman;
    persistent anomaly;
    
    %% Variabili supplementari per kalman
    persistent k_index;
    persistent kalman;
    %
    persistent n_cycle_kalman_specific;
    % descrizione nel foglietto
    
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
        k_index = zeros(2,3);
    end
    
    %% Initialization and update specifica variables for group Kalman evaluation
    if kalman_ok(1,1)
        kalman_ok(1,1) = false;
        kalman{1} = {};
        n_cycle_kalman_specific(1,:) = [0,0];
    end
    
    if kalman_ok(2,1)
        kalman_ok(2,1) = false;
        kalman{2} = {};
        n_cycle_kalman_specific(2,:) = [0, 0];
    end
    
    if isempty(kalman)   
        kalman{2} = {};
        n_cycle_kalman_specific(2) = 0;
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
    
    %% Index of rilevant elements
    id_kalman = ["space", "velocity", "acceleration";
                 "angle", "angularVelocity", "angulaAcceleration"]; %------
    k_index(id_kalman==type) = index;
    
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

    %% Initialization Kalman
    % wait - (1) linear
    %      - (2) angular
    wait = [false, false];
    
    if kalman_ok(1,3)-kalman_ok(1,2)>0   
        id_kalman_l = id_kalman(1, kalman_ok(1,3)-kalman_ok(1,2));
    else
        id_kalman_l = "";
    end
    
    if kalman_ok(2,3)-kalman_ok(2,2)>0
        id_kalman_a = id_kalman(2, kalman_ok(2,3)-kalman_ok(2,2));
    else
        id_kalman_a = "";
    end
    
    if sum(id_kalman_l==type)
        kalman{1}{1}{id_kalman_l==type} = t;
        kalman{1}{2}{id_kalman_l==type} = y;
        n_cycle_kalman_specific(1,2) = n_cycle_kalman_specific(1,2) +1;
        wait(1) = true;
    end
    
    if sum(id_kalman_a==type)
        kalman{2}{1}{id_kalman_a==type} = t;
        kalman{2}{2}{id_kalman_a==type} = y;
        n_cycle_kalman_specific(2,2) = n_cycle_kalman_specific(2,2) +1;
        wait(2) = true;
    end
    
    %% Fill data_type and peaks search
    % General evaluation
    data_type{1,1} = dataType{index,1};
    data_type{1,2} = dataType{index,2};
    varp_tmp{1} = varp{index};
    var2_tmp{1} = var2{index};
    Pn_2_tmp{1} = Pn_2{index};
    Rn_tmp{1} = Rn{index};

    y_calc_tmp{1} = [];
    variation_tmp = y_calc_tmp;
    anomaly_out = y_calc_tmp;

    for i=length(anomaly{index})+1:(columns_input-wait*kalman_ok(:,end))
        t_type{1} = t(1:i);
        y_type{1} = y(:,1:i);
        [anomaly_tmp, y_calc_tmp1, variation_tmp1, varp_tmp, var2_tmp, Pn_2_tmp, n_cycle_kalman(index)] = find_peaks(t_type, y_type, data_type, degree, num, gap, gap_kalman, varp_tmp, var2_tmp, Pn_2_tmp, Rn_tmp, n_cycle_kalman(index));
        y_calc_tmp{1} = [y_calc_tmp{1} y_calc_tmp1{1}];
        variation_tmp{1} = [variation_tmp{1} variation_tmp1{1}];
        anomaly_out{1} = [anomaly_out{1} anomaly_tmp{1}];
    end

    first_index_out = length(anomaly{index})+1;
    anomaly{index} = [anomaly{index} anomaly_out{1}];
    varp{index} = varp_tmp{1};
    var2{index} = var2_tmp{1};
    Pn_2{index} = Pn_2_tmp{1};
    
    
    %% Kalman multi elements
    
    k_length = [length(id_kalman_l); length(id_kalman_l)];
    tmp = n_cycle_kalman_specific(:,2)==k_length;
    l_or_a = find(tmp);
    
    if sum(tmp)
        
        data_type{tmp'*k_length,2} = [];
        varp_tmp{tmp'*k_length} = [];
        var2_tmp = varp_tmp;
        Pn_2_tmp = varp_tmp;
        Rn_tmp = varp_tmp;
        t_type = varp_tmp;
        y_type = varp_tmp;
        
        y_calc = var2_tmp;
        variation = y_calc;
        anomaly_out = y_calc;
        
        for i=1:(tmp'*k_length)
            data_type{i,1} = dataType{k_index(l_or_a,i+kalman_ok(l_or_a,2)),1};
            data_type{i,2} = dataType{k_index(l_or_a,i+kalman_ok(l_or_a,2)),2};
            varp_tmp{i} = varp{k_index(l_or_a,i+kalman_ok(l_or_a,2))};
            var2_tmp{i} = var2{k_index(l_or_a,i+kalman_ok(l_or_a,2))};
            Pn_2_tmp{i} = Pn_2{k_index(l_or_a,i+kalman_ok(l_or_a,2))};
            Rn_tmp{i} = Rn{k_index(l_or_a,i+kalman_ok(l_or_a,2))};
        end
        
        for i=length(anomaly{index})+1:columns_input
            for j=1:(tmp'*k_length)
                t_type{j} = kalman{l_or_a}{1}{j}(1:i);
                y_type{j} = kalman{l_or_a}{2}{j}(:,1:i);
            end
            [anomaly_tmp, y_calc_tmp2, variation_tmp2, varp_tmp, var2_tmp, Pn_2_tmp, n_cycle_kalman_specific(1,l_or_a)] = find_peaks(t_type, y_type, data_type, degree, num, gap, gap_kalman, varp_tmp, var2_tmp, Pn_2_tmp, Rn_tmp, n_cycle_kalman_specific(1,l_or_a));
            for j=1:(tmp'*k_length)
                y_calc{j} = [y_calc{j} y_calc_tmp2{j}];
                variation{j} = [variation{j} variation_tmp2{j}];
                anomaly_out{j} = [anomaly_out{j} anomaly_tmp{j}];
            end
        end
        
        for i=1:(tmp'*k_length)
            anomaly{k_index(l_or_a,i+kalman_ok(l_or_a,2))} = [anomaly{k_index(l_or_a,i+kalman_ok(l_or_a,2))} anomaly_out{i}];
        end
        
    end
    
    %% Gestione output
    
    if sum(tmp)
        elem_tmp = find(k_index==index);
        anomaly_out{elem_tmp(2)} = anomaly{index}(first_index_out:end);
        y_calc{elem_tmp(2)} = [y_calc_tmp{1} y_calc{elem_tmp(2)}];
        variation{elem_tmp(2)} = [variation_tmp{1} variation{elem_tmp(2)}];
        
    else
        y_calc = y_calc_tmp;
        variation = variation_tmp;
    end
end