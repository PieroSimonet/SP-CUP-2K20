%% TO DO
function [anomaly, varargout] = peak_presence(variation, y_next, y_last, gap, n_sensors, varargin)
    
    % varargin ->  sigma, varp, var2
    % varargout -> varp, var2
    
    anomaly{n_sensors} = [];
    varp = anomaly;
    var2 = anomaly;
    if ~isempty(varargin)
        varargout{2} = {};
    end
    
    for i=1:n_sensors
        y_need = min(abs(y_next{i}), abs(y_last{i}));
        y_need_z = y_need==0;
        y_need_wz = y_need_z + y_need;
        less_1 = abs(y_need)<1;
        variation_p = less_1.*variation{i} + (1-less_1).*(variation{i}./y_need_wz);
        
        if isempty(varargin)
            check = sum((abs(variation_p))>gap)>0;
        else
            
            [varp{i}, varp_short, var2{i}] = calc_var_varp(variation{i}, y_next{i}, varargin{1}{i}, varargin{2}{i});
            if varp{i}(1)<3
                varp_short = zeros(size(varp_short));
            end

            delta = max([gap*ones(size(varp_short)), varp_short], [], 2);
            check = sum((abs(variation_p))>delta)>0;
        end
        
        anomaly{i} = check;
    end
    
    if ~isempty(varargin)
        varargout{1} = varp;
        varargout{2} = var2;
    else
        varargout{1} = 0;
        varargout{2} = 0;
    end
end