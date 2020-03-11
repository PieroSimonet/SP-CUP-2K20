%% Input
% t         - time vector                                               [double[]]
% y         - vector of values of data_type element                     [double[]]
% data_type - type of data                                              [String]
%           - particular cases : "sva_l" (space-velocity-acceleration)
%                                "sva_a" (angle-angular velocity-
%                                         angular acceleration)
% degree    - max degree during poly fit evaluation                     [int]
% num       - number of elements evaluating during polyfit              [int]
% gap       - maximum permissible percentage error                      [double]
% gap_sva   - max variation to identify a constant element              [double]
 
%% Output
 
% already_analysed  - true if all values of the corresponding data_type are         [Boolean]
%                     already analysed
% anomaly           - vector of anomalies of the data_type's last entered elements  [Boolean[]]
%                   - or if the last element of t is anomaly
% start             - corresponding sample number of the first elements of anomaly  [int]
% error             - error of not evaluated elements (y_measured-y_predicted)      [double[]]
% y_next            - prediction of not evaluated elements                          [double[]]
 
%% Function
function [already_analysed, anomaly, start, error, y_next] = FindPeaksWrapper(t, y, data_type, degree, num, gap, gap_sva)
    
    persistent dataType;
    persistent anomalyArray;
    
    % var - 1st column: varp_error of data_type elements
    %       2nd column: var2_error of data_type elements
    persistent var;
    
    % matrix - 1st columns: Pn_2 of sva_l and sva_a elements
    %          2nd columns: Rn of sva_l and sva_a elements
    persistent matrix;
    
    if isempty(dataType)
        dataType{1} = data_type;    % type of data
        anomalyArray{1,1} = 0;      % number of elements analysed
        anomalyArray{1,2} = [];     % anomaly vector of data_type
        [rows, ~] = size(y);
        var{1,1} = zeros(rows+1,1); % varp_error
        var{1,2} = zeros(rows,1);   % var2_error
        if (data_type == "sva_l")||(data_type == "sva_a")
            % Pn_2 and Rn
            matrix{1,1} = 10*eye(rows); % Pn_2
            matrix{1,2} = eye(rows);    % Rn --------------------------------------------------------------------
        end
    end
    
    already_analysed = false;
    index = 0;
    
    for i=1:length(dataType)
        if dataType{i} == data_type
            index = i;
        end
    end
    
    % new data_type element
    if index == 0
        index = length(dataType)+1;
        dataType{index} = data_type;
        anomalyArray{index,1} = 0;
        anomalyArray{index,2} = [];
        [rows, ~] = size(y);
        var{index,1} = zeros(rows+1,1); % varp_error
        var{index,2} = zeros(rows,1); % var2_error
        
        % check if is sva_l or sva_a
        if (data_type == "sva_l")||(data_type == "sva_a")
            matrix{index,1} = 10*eye(rows); % Pn_2
            matrix{index,2} = eye(rows); % Rn --------------------------------------------------------------------
        end
    end
    
    % if is already analysed return to Main
    if anomalyArray{index,1} >= length(t)
        already_analysed = true;
        % return if last element of t is anomaly
        anomaly = anomalyArray{index,2}(length(t));
        start = 0;
        [rows, ~] = size(y);
        error = zeros(rows,1);
        y_next = y(:,end);
        return
    end
    
    % initialization (increase efficiency)
    [rows, ~] = size(y);
    columns = length(t)-anomalyArray{index,1};
    error = zeros(rows,columns);
    y_next = zeros(rows,columns);
    
    if (dataType{index} == "sva_l")||(dataType{index} == "sva_a")
        anomaly = zeros(3, columns);
    else
        anomaly = zeros(1, columns);
    end
    
    % Update variables and calc of y_next, error and anomaly
    for i= (anomalyArray{index,1}+1):length(t)
        
        if (dataType{index} == "sva_l")||(dataType{index} == "sva_a")
            % find peaks with Kalman filter (specific calc cases)
            [anomaly_tmp, y_next_tmp, error_tmp, var{index,1}, var{index,2}, matrix{index,1}] = find_peaks_sva(t(:,1:i), y(:,1:i), degree, num, gap, var{index,1}, var{index,2}, gap_sva, matrix{index,1}, matrix{index,2});
        else
            % find peaks without Kalman filter (no specific model)
            [anomaly_tmp, y_next_tmp, error_tmp, var{index,1}, var{index,2}] = find_peaks_general(t(:,1:i), y(:,1:i), degree, num, gap, var{index,1}, var{index,2});
        end
        
        anomaly(i-anomalyArray{index,1}) = anomaly_tmp;
        error(:,i-anomalyArray{index,1}) = error_tmp;
        y_next(:,i-anomalyArray{index,1}) = y_next_tmp;
    end
    
    anomalyArray{index,2} = [anomalyArray{index,2} anomaly];
    start = anomalyArray{index,1};
    
    % update number of verified elements
    anomalyArray{index,1} = length(t);
 
end