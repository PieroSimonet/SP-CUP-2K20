%% Input

% data              - data to analyse (each row a sensor)                   [cell{}]
%                     {i,1} measured values
%                     {i,2} time vector
%                     {i,3} type of sensor
% num               - maximum number of elements used in polyfit            [int]
%                     evaluation
% kalman_ok         - data matrix that activates multi-Kalman evaluation    [cell{}]
%                     (1,:) [update, start_k, finish_k, common_elem]        [Boolean int[]]
%                           linear elements
%                     (2,:) [update, start_k, finish_k, common_elem]        [Boolean int[]]
%                           angular elements

%% Output
% kalman_ok         - update of input

%% Function
function kalman_ok = multi_kalman_ok(data, num, kalman_ok)
    
    % last_length - vector of previous id_kalman elements
    persistent last_length;  
    
    % id_kalman - name of specific sensors for Kalman's multi-input         [String[]]
    %             analysis
    %             (1,:) linear sensors
    %             (2,:) angular sensors
    id_kalman = ["p_gps", "v_gps", "LinearAcceleration";
                 "angle", "AngularVelocity", "angularAcceleration"];%---------------------------
    
    % n_elem_permitted - number of element permitted to report data synchronization [int]
    n_elem_permitted = 2;
    
    [rows_id, columns_id] = size(id_kalman);
    
    % Initialization variables
    if isempty(last_length)
        last_length = zeros(rows_id, columns_id);
    end
    
    % k_index - index of id_kalman sensors                                  [int[]]
    k_index = zeros(rows_id, columns_id);
    % T_index - last measurement of id_kalman sensors                       [double[]]
    T_index = k_index;
    % l_index - length of time vector of id_kalman sensors                  [int[]]
    l_index = k_index;
    % F_index - average sampling rate of id_kalman sensors [double[]]
    F_index = k_index;
    % check_nk - true if a id_kalman element can be associated to its       [Boolean[]]
    %           next one
    check_nk = k_index;
    % common_elem - number of common cycles between sensors for             [int[]]
    %               multi-Kalman evaluation
    common_elem = zeros(rows_id, 1);
    
    % rows_data - number of distinct sensors in memory                      [int]
    [rows_data, ~] = size(data);    
    
    % Data acquisistion and eleaboration
    for i=1:rows_data
        tmp = id_kalman==data{i,3};
        if sum(sum(tmp))
            k_index(tmp) = i;
            T_index(tmp) = data{i,2}(:,end);
            l_index(tmp) = length(data{i,2})-last_length(tmp);
            last_length(tmp) = length(data{i,2});
        
            % Avoid division by zero
            if data{i,2}(:,end)== 0 && data{i,2}(:,1)==0
                kalman_ok = zeros(size(kalman_ok));
                return
            end
            F_index(tmp) = length(data{i,2})/(data{i,2}(:,end)-data{i,2}(:,1));
        else
            % No match
            k_index(tmp) = i;
            T_index(tmp) = 0;
            l_index(tmp) = 0;
            last_length(tmp) = 0;
            F_index(tmp) = 0;
        end
    end
    
    for j=1:2 
        for i=1:length(k_index(j,:))-1
            if k_index(j,i)~=0 && k_index(j,i+1)~=0
                % Two contiguous element exist
                if min(F_index(j,i),F_index(j,i+1))==0
                    test1 = abs(T_index(j,i)-T_index(j,i+1))<=abs(n_elem_permitted/min(F_index(j,i),F_index(j,i+1)));
                else
                    test1 = false;
                end
                test2 = abs(F_index(j,i)-F_index(j,i+1))<= min(F_index(j,i),F_index(j,i+1))/num;
                check_nk(j,i) = (test1&&test2)||check_nk(j,i);
                check_nk(j,i+1) = (test1&&test2);
                
                common_elem(j) = min([l_index(j,i), l_index(j,i+1)]);
            end
        end
    end
    
    for j=1:2
        % start_k - id_kalman starting sensor index for multi-Kalman        [int]
        %           evaluation
        start_k = find(check_nk(j,:),1);
        % finish_k - id_kalman end sensor index for multi-Kalman evaluation [int]
        finish_k = find(check_nk(j,:),1,'last');
        
        % Update kalman_ok
        if ~isempty(start_k) && ~isempty(finish_k)
            if sum(kalman_ok(j,2:3) == [start_k, finish_k])>2
                kalman_ok(j,:) = [1, start_k, finish_k, common_elem(j)];
            else
                kalman_ok(j,:) = [0, start_k, finish_k, common_elem(j)];
            end
        else
            kalman_ok(j,:) = zeros(size(kalman_ok(j,:)));
        end
    end 
        
end