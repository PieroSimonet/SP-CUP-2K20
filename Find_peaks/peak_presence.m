%% Input

% varargin          - {1} varp of each sensors
%                     {2} var2 of each sensors
% varp              - average percentage sensors variation                  [cell{int double[]}]
% var2              - variance of sensors                                   [cell{double[]}]

%% Output

% anomaly           - anomalies identified by Kalman evaluation             [cell{Boolean[]}]
% varargout         - {1} updated varp
%                   - {2} updated var2

%% Function
function [anomaly, varargout] = peak_presence(variation, y_next, y_last, gap, n_sensors, varargin)
    
    anomaly{n_sensors} = [];
    varp = anomaly;
    var2 = anomaly;
    
    for i=1:n_sensors
        
        % The percentage variation is referred to minimum absolute value due
        % to prevent miscalculation caused by peaks presence
        y_need = min(abs(y_next{i}), abs(y_last{i}));
        
        y_need_z = y_need==0;
        % y_next_wz - predicted values vector (without zero elements)       [double[]]
        y_need_wz = y_need_z + y_need;
        
        less_1 = y_need<1;
        
        gap = gap.*(1-less_1) + less_1.*(0.5./y_need_wz);
        variation_p = abs(variation{i}./y_need_wz);
        
        if isempty(varargin)
            check = sum((abs(variation_p))>gap)>0;
        else
            % Update variables
            % varp_short - varp without first element                       [double[]]
            %              (number of elements analized)
            [varp{i}, varp_short, var2{i}] = calc_var_varp(variation{i}, y_need_wz, varargin{1}{i}, varargin{2}{i});
            if varp{i}(1)<3
                varp_short = zeros(size(varp_short));
            end
            
            % delta - minimum effettive percentage change to report an      [double]
            %         anomaly
            delta = max([gap, varp_short], [], 2);
                
            % check - temporary variables of peak presence                  [Boolean]
            check = sum((abs(variation_p))>delta)>0;
        end
        anomaly{i} = check;
    end
    
    % Update output variables
    if isempty(varargin)
        varargout{1} = 0;
        varargout{2} = 0;
        else
        varargout{1} = varp;
        varargout{2} = var2;
    end
end