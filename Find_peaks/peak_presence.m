%% Input
%               
% variation     - differences between predicted and measured values         [cell[double[]]]
% y_next        - predicted values vectors                                  [cell[double[]]]
% y_last        - last measured values vectors                              [cell[double[]]]
% gap           - minimum percentage variation to report an anomaly         [double]
% n_sensors     - number of sensors to analyse                              [int]
% varargin      - {1} varp of each sensors
%                 {2} var2 of each sensors
% varp          - percentage sensors variation                              [cell[double[]]]
% var2          - variance of sensors                                       [cell[double[]]]
%% Output

% anomaly		- anomalies of analysed sensors                             [cell[Boolean[]]]
% varargout     - {1} updated varp                                          [...]
%               - {2} updated var2                                          [...]

%% Function
function [anomaly, varargout] = peak_presence(variation, y_next, y_last, gap, n_sensors, varargin)
    
    % Initialization of outout vectors
    anomaly{n_sensors} = [];
    varp = anomaly;
    var2 = anomaly;
    
    % While using Kalman evaluation varp and var2 are not used and updated
    if ~isempty(varargin)
        varargout{2} = {};
    end
    
    for i=1:n_sensors
        
        % the percentage variation is referred to minimum absolute value due
        % to prevent miscalculation caused by peaks presence
        y_need = min(abs(y_next{i}), abs(y_last{i}));
        
        y_need_z = y_need==0;
        % y_need_wz - values without zeros to prevent error during division
            y_need_wz = y_need_z + y_need;
        
        less_1 = abs(y_need)<1; %--------------------------------------------
        variation_p = less_1.*variation{i} + (1-less_1).*(variation{i}./y_need_wz);
        
        if isempty(varargin)
            check = sum((abs(variation_p))>gap)>0;
        else
            % Update variables
            [varp{i}, varp_short, var2{i}] = calc_var_varp(variation{i}, y_next{i}, varargin{1}{i}, varargin{2}{i});
            if varp{i}(1)<3
                varp_short = zeros(size(varp_short));
            end
            
            % varp_short - varp without first element
            %              (number of elements evaluated until now)
            % delta - maximum effettive percentage change to not report an
            %         anomaly
                delta = max([gap*ones(size(varp_short)), varp_short], [], 2);
                
            % check - temporary variables of the presence of the peak    
            check = sum((abs(variation_p))>delta)>0;
        end
        
        anomaly{i} = check;
    end
    
    % Update output variables
    if ~isempty(varargin)
        varargout{1} = varp;
        varargout{2} = var2;
    else
        varargout{1} = 0;
        varargout{2} = 0;
    end
end