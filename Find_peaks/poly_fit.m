%% Input

% t_analyse     - reduced time vector                                       [cell[]]
% y_analyse     - reduced sensors measurement vectors                       [cell[double[]]] 
% start         - starting index in the original vector from which to       [int[]]
%                 take data
% rows          - number of dimension of each sensor analysed               [int[]]
% degree        - maximum degree for polyfit evaluation                     [int]
% n_sensors     - number of sensors to analyse                              [int]


%% Output

% y_next        - predicted values vectors                                  [cell[double[]]]
% variation     - differences between predicted and measured values         [cell[double[]]]
% m             - coefficient of linear regression referred to the          [double[]]
%                 last sensor

%% Function
function [y_next, variation, m] = poly_fit(t_analyse, y_analyse, start, rows, degree, n_sensor)
    
    % General variables
    t{n_sensor} = [];
    value = t;
    y_next = t;
    
    % Vector reduction for polyfit evaluation
    for i=1:n_sensor
        y_next{i} = zeros(rows(i),1);
        t{i} = t_analyse{i}(start(i):end-1);
        value{i} = y_analyse{i}(:,start(i):end-1);
    end
    
    variation = y_next;
    m = y_next{end};
    
    % Polyfit evaluation for each sensors
    for i=1:n_sensor
        for j=1:rows(i)
            [pol, S] = polyfit(t{i}, value{i}(j,:), degree);
            
            if i==n_sensor
                % Coefficient of linear regression of last sensor
                m(j) = polyval(pol(1:end-1), t_analyse{i}(end));
            end
            
            next = polyval(pol, t_analyse{i}(end),S);
            variation{i}(j) = next-y_analyse{i}(j,end);
        end
        y_next{i} = y_analyse{i}(:,end) + variation{i};
    end
end