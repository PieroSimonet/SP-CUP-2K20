%% Input

% t                 - time vector of sensors                                [cell{double[]}]
% y                 - sensors measurement vectors                           [cell{double[]}]
% type              - type of sensor                                        [String]
% num               - maximum number of elements used in polyfit            [int]
%                     evaluation
% gap               - minimum percentage variation to report an anomaly     [double]
% gap_k             - maximum coefficient of linear regression to           [double]
%                     determine constant behaviour
% kalman_ok         - data matrix that activates multi-Kalman evaluation    [cell{}]
%                     (1,:) [update, start_k, finish_k, common_elem]        [Boolean int[]]
%                           linear elements
%                     (2,:) [update, start_k, finish_k, common_elem]        [Boolean int[]]
%                           angular elements


%% Output

% already_analysed	- no new elements to analyse                            [Boolean]
% anomaly_out       - anomalies in the last captured data set               [cell{Boolean[]}]
% index_out         - index of the first element in anomaly_out referred    [int]
%                     to all measured data
% variation         - differences between predicted and measured values     [cell{double[]}]
% y_calc            - output vector of the predicted values                 [cell{double[]}]
% data_type         - general description of evaluated sensors              [cell{}]
%                     {i,1} type of sensor evaluated                        [String]
%                     {i,2} dimension of values of corresponding sensor     [int]
% kalman_ok         - update of input

%                          | to see |                                                                                        | pos rot acc |-> all zeros
%% Function
function [already_analysed, anomaly_out, index_out, variation, y_calc, data_type, kalman_ok] = FindPeaksWrapper(t, y, type, degree, num, gap, gap_k, kalman_ok)
    
    %% General variables
    
    % rows_input - size of values measured by the type(input element)       [int]
    %              sensor
    % columns_input - number of measures of the type(input element) sensor  [int]
    [rows_input, columns_input] = size(y);
    
    % dataType - general memory of all sensor features                      [cell{}]
    %            {i,1} type of sensor evaluated                             [String]
    %            {i,2} dimension of values of corresponding sensor          [int]
    persistent dataType;
    
    % varp - average percentage sensors variation                           [cell{int double[]}]
    persistent varp;
    
    % var2 - variance of sensors                                            [cell{double[]}]
    persistent var2;
    
    % Pn_2 - covariance variation of process                                [cell{double[]}]
    persistent Pn_2;
    
    % Rn - precision matrix of sensors                                      [cell{double[]}]
    persistent Rn;
    
    % n_cycle_k	- number of consecutive cycle of Kalman evaluation          [int[]]
    persistent n_cycle_k;
    
    % anomaly - store of all anomalies of analysed sensors                  [cell{Boolean[]}]
    persistent anomaly;
    
    %% Variables for multi-Kalman evaluation
    
    % k_index - index of id_kalman sensors                                  [int[]]
    persistent k_index;
    
    % kalman - {1} elements for multi-Kalman evaluation of linear elements  [cell{}]
    %          {2} elements for multi-Kalman evaluation of angular elements [cell{}]
    %          {_}{1} time                                                  [cell{double[]}]
    %          {_}{2} measured values                                       [cell{double[]}]
    persistent kalman;
    
    % n_cycle_mk - useful values for multi-Kalman evaluation                [int[]]
    %              (1,:) linear elements - (2,:) angualr elements
    %              (:,1) number cycles of multi-Kalman evaluation           [int]
    %              (:,2) number of elements inserted into kalman(variables) [int]
    persistent n_cycle_mk;
    
    %% Initialization general variables
    
    if isempty(dataType)
        dataType{1,1} = type;
        dataType{1,2} = rows_input;
        varp{1} = zeros(rows_input+1,1);
        var2{1} = zeros(rows_input,1);
        Pn_2{1} = 2*eye(rows_input);
        Rn{1} = 0.1*eye(rows_input);
        n_cycle_k(1) = 0;
        anomaly{1} = [];
        k_index = zeros(2,3);
    end
    
    if isempty(kalman)   
        kalman{2} = {};
        n_cycle_mk = zeros(2);
    end
    
    %% Initialization and update of variables for multi-Kalman evaluation
    
    if kalman_ok(1,1)
        % Update variables to be inserted in kalman{1}
        kalman_ok(1,1) = false;
        kalman{1} = {};
        n_cycle_mk(1,:) = [0,0];
    end
    
    if kalman_ok(2,1)
        % Update variables to be inserted in kalman{2}
        kalman_ok(2,1) = false;
        kalman{2} = {};
        n_cycle_mk(2,:) = [0, 0];
    end
    
    %% Search
    
    % index - index of the type(intput element) sensor within the general   [int]
    %         memory 
    index = 0;
    
    % rows_data - number of distinct sensors in memory                      [int]
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
        Pn_2{index} = 2*eye(rows_input);
        Rn{index} = 0.1*eye(rows_input);
        n_cycle_k(index) = 0;
        anomaly{index} = [];
    end
    
    %% Index of elements for multi-Kalman evaluation
    
    % id_kalman - name of specific sensors for Kalman's multi-input         [String[]]
    %             analysis
    %             (1,:) linear sensors
    %             (2,:) angular sensors
    id_kalman = ["space", "velocity", "acceleration";
                 "angle", "angularVelocity", "angularAcceleration"]; %-------------------------------------
             
    
    k_index(id_kalman==type) = index;
    
    %% Already analysed
    
    already_analysed = false;
    
    if length(anomaly{index})>= columns_input
        % No new elements to analyse
        % Used also to return past evaluation
        already_analysed = true;
        anomaly_out{1} = anomaly{index}(columns_input);
        index_out = columns_input;
        variation = 0;
        y_calc = 0;
        data_type{1,1} = dataType{index,1};
        data_type{1,2} = dataType{index,2};
        return
    end

    %% Initialization multi-Kalman evaluation
    
    % wait - insertion in kalman(variables) of type(intput element) sensor  [Boolean[]]
    %        (1) the element is inserted in kalman{1} (linear element)
    %        (2) the element is inserted in kalman{2} (angular element)
    wait = [false, false];
    
    % Identifying sensors in id_kalman needed by multi-Kalman evaluation
    
    % id_kalman_l - id_kalman reduced by kalman_ok (linear elements)        [String[]]
    if kalman_ok(1,3)-kalman_ok(1,2)>0
        id_kalman_l = id_kalman(1, kalman_ok(1,2):kalman_ok(1,3));
    else
        id_kalman_l = "";
    end
    
    % id_kalman_a - id_kalman reduced by kalman_ok (angular elements)       [String[]]
    if kalman_ok(2,3)-kalman_ok(2,2)>0
        id_kalman_a = id_kalman(2, kalman_ok(2,2):kalman_ok(2,3));
    else
        id_kalman_a = "";
    end
    
    % Match in linear sensors
    if sum(id_kalman_l==type)
        % Update
        kalman{1}{1}{id_kalman_l==type} = t;
        kalman{1}{2}{id_kalman_l==type} = y;
        n_cycle_mk(1,2) = n_cycle_mk(1,2) +1;
        wait(1) = true;
    end
    
    % Match in angular sensors
    if sum(id_kalman_a==type)
        % Update
        kalman{2}{1}{id_kalman_a==type} = t;
        kalman{2}{2}{id_kalman_a==type} = y;
        n_cycle_mk(2,2) = n_cycle_mk(2,2) +1;
        wait(2) = true;
    end
    
    %% Peaks search of general elements or not common data
    
    % General evaluation
    % Inizialization of variables
    
    data_type_tmp{1,1} = dataType{index,1};
    data_type_tmp{1,2} = dataType{index,2};
    
    % ..._tmp - corresponding temporary variables
    varp_tmp{1} = varp{index};
    var2_tmp{1} = var2{index};
    Pn_2_tmp{1} = Pn_2{index};
    Rn_tmp{1} = Rn{index};

    y_calc_tmp{1} = [];
    variation_tmp = y_calc_tmp;
    anomaly_tmp = y_calc_tmp;
    
    % If there is no match between type and id_kalman_l or id_kalman_a,
    % it evaluates all the new data
    % Otherwise the cycle evaluates only non-common data
    for i=length(anomaly{index})+1:(columns_input-wait*kalman_ok(:,end))
        % Loading values one by one 
        t_s{1} = t(1:i);
        y_s{1} = y(:,1:i);

        % ..._fp - elements derived from the find peaks analysis on
        %          type(variable) sensor
        [anomaly_fp, y_calc_fp, variation_fp, varp_tmp, var2_tmp, Pn_2_tmp, n_cycle_k(index)] = find_peaks(t_s, y_s, data_type_tmp, degree, num, gap, gap_k, varp_tmp, var2_tmp, Pn_2_tmp, Rn_tmp, n_cycle_k(index));
        y_calc_tmp{1} = [y_calc_tmp{1} y_calc_fp{1}];
        variation_tmp{1} = [variation_tmp{1} variation_fp{1}];
        anomaly_tmp{1} = [anomaly_tmp{1} anomaly_fp{1}];
    end

    index_out_tmp = length(anomaly{index})+1;
    
    % Update general variables
    anomaly{index} = [anomaly{index} anomaly_tmp{1}];
    varp{index} = varp_tmp{1};
    var2{index} = var2_tmp{1};
    Pn_2{index} = Pn_2_tmp{1};
    
    
    %% Multi-Kalman evaluation
    
    % Clear the memory of temporary variables
    clearvars varp_tmp var2_tmp Pn_2_tmp Rn_tmp;
    
    % k_length - number of elements in kalman (variable) needed for         [int[]]
    %            multi_Kalman evaluation
    k_length = [length(id_kalman_l); length(id_kalman_a)];
    
    % kalman_fill - true if kalman is ready for multi_Kalman evaluation     [Boolean[]]
    kalman_fill = n_cycle_mk(:,2)==k_length;
    
    % l_or_a - type of elements ready for analysis (1 linear, 2 angular)    [int]
    l_or_a = find(kalman_fill);
    
    if sum(kalman_fill)
        % Acquired all the sensors needed by multi-Kalman evaluation
        
        % Initialization of cell{} element for multiple evaluation
        data_type{kalman_fill'*k_length,2} = [];
        varp_tmp{kalman_fill'*k_length} = [];
        var2_tmp = varp_tmp;
        Pn_2_tmp = varp_tmp;
        Rn_tmp = varp_tmp;
        t_mk = varp_tmp;
        y_mk = varp_tmp;
        
        y_calc = varp_tmp;
        variation = y_calc;
        anomaly_out = y_calc;
        
        % index_mk - k_index-to-global index transformation constant        [int]
        index_mk = kalman_ok(l_or_a,2)-1;
        
        % Transferring used variables from general variables
        for i=1:(kalman_fill'*k_length)
            data_type{i,1} = dataType{k_index(l_or_a,i+index_mk),1};
            data_type{i,2} = dataType{k_index(l_or_a,i+index_mk),2};
            varp_tmp{i} = varp{k_index(l_or_a,i+index_mk)};
            var2_tmp{i} = var2{k_index(l_or_a,i+index_mk)};
            Pn_2_tmp{i} = Pn_2{k_index(l_or_a,i+index_mk)};
            Rn_tmp{i} = Rn{k_index(l_or_a,i+index_mk)};
        end
        
        % Evaluation of common elements
        for i=length(anomaly{index})+1:columns_input
            % Loading values one by one
            for j=1:(kalman_fill'*k_length)
                t_mk{j} = kalman{l_or_a}{1}{j}(1:i);
                y_mk{j} = kalman{l_or_a}{2}{j}(:,1:i);
            end
            
            [anomaly_k, y_calc_k, variation_k, varp_tmp, var2_tmp, Pn_2_tmp, n_cycle_mk(l_or_a,1)] = find_peaks(t_mk, y_mk, data_type, degree, num, gap, gap_k, varp_tmp, var2_tmp, Pn_2_tmp, Rn_tmp, n_cycle_mk(l_or_a,1));
            
            % Update output elements
            for j=1:(kalman_fill'*k_length)
                y_calc{j} = [y_calc{j} y_calc_k{j}];
                variation{j} = [variation{j} variation_k{j}];
                anomaly_out{j} = [anomaly_out{j} anomaly_k{j}];
            end
        end
        
        index_out = zeros(1,kalman_fill'*k_length);
        
        for i=1:(kalman_fill'*k_length)
            index_out(i) = length(anomaly{k_index(l_or_a,i+index_mk)})+1;
            anomaly{k_index(l_or_a,i+index_mk)} = [anomaly{k_index(l_or_a,i+index_mk)} anomaly_out{i}];
        end
        
        % Reset of elements used
        n_cycle_mk(l_or_a,2) = 0;
        kalman{l_or_a} = {};
    end
    
    %% Output management
    
    if sum(kalman_fill)
        
        % Multi-Kalman evaluation
        % elem_tmp - position in output cell vectors of                     [int]
        %            type(input variable) sensor
        [~, elem_tmp] = find(k_index==index);
        elem_tmp = elem_tmp-kalman_ok(l_or_a,2)+1;
        
        % Input of data from the analysis of uncommon elements
        anomaly_out{elem_tmp} = anomaly{index}(index_out:end);
        index_out(elem_tmp) = index_out_tmp;
        y_calc{elem_tmp} = [y_calc_tmp{1} y_calc{elem_tmp}];
        variation{elem_tmp} = [variation_tmp{1} variation{elem_tmp}];
        
    else
        % Single sensor evaluation
        anomaly_out = anomaly_tmp;
        index_out = index_out_tmp;
        variation = variation_tmp;
        y_calc = y_calc_tmp;
        data_type = data_type_tmp;
        
        % No elements evaluated (all new values are in common for
        % multi-Kalman evaluation)
        if isempty(anomaly_out{1})
            already_analysed = true;
        end
    end
end