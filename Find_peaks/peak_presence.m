%% Input

% varargin          - {1} var2 of each sensors
% var2              - average squared variance of sensors                   [cell{double[]}]

%% Output

% anomaly           - anomalies identified by Kalman evaluation             [cell{Boolean[]}]
% varargout         - {1} updated var2

%% Function
function [anomaly, varargout] = peak_presence(variation, y_next, y_last, gap, n_sensors, varargin)
    
    anomaly{n_sensors} = [];
    var2 = anomaly;
    
    for i=1:n_sensors
        
        % The percentage variation is referred to minimum absolute value due
        % to prevent miscalculation caused by peaks presence
        y_need = min(abs(y_next{i}), abs(y_last{i}));
        
        y_need_z = y_need==0;
        % y_next_wz - predicted values vector (without zero elements)       [double[]]
        y_need_wz = y_need_z + y_need;
        
        less_1 = y_need<1;
        
        gap = gap.*(1-less_1) + less_1.*(1./y_need_wz);
        variation_p = abs(variation{i}./y_need_wz);
        
        if ~isempty(varargin)
            % Update variables
            var2{i} = calc_var(variation{i}, varargin{1}{i});
        end
        
        anomaly{i} = sum((abs(variation_p))>gap)>0;
    end
    
    % Update output variables
    if isempty(varargin)
        varargout{1} = 0;
    else
        varargout{1} = var2;
    end
end