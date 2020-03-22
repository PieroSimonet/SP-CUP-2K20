%% Input

% t_analyse         - time vector only of sensor to analyse                 [cell{double[]}]
% y_analyse         - measured values only of sensor to analyse             [cell{double[]}]
% start             - starting index in original vector from which          [int]
%                     take data
% rows              - number of dimension of each sensor to analyse         [int[]]
% degree            - maximum degree for polyfit evaluation                 [int]
% n_sensors         - number of sensors to analyse                          [int]


%% Output


% y_next_p          - predicted values vectors with polyfit evaluation      [cell{double[]}]
% variation_p       - differences between predicted and measured values     [cell{double[]}]
%                     of polyfit evaluation
% m                 - coefficient of linear regression referred to the      [double]
%                     last sensor

%% Function
function [y_next_p, variation_p, m] = poly_fit(t_analyse, y_analyse, start, rows, degree, n_sensor)
    
    % t_p - reduced time vector                                             [cell{double[]}]
    t_p{n_sensor} = [];
    % value_p - reduced sensors measurement vectors                         [cell{double[]}]
    value_p = t_p;
    y_next_p = t_p;
    
    for i=1:n_sensor
        y_next_p{i} = zeros(rows(i),1);
        t_p{i} = t_analyse{i}(start(i):end-1);
        value_p{i} = y_analyse{i}(:,start(i):end-1);
    end
    
    variation_p = y_next_p;
    m = y_next_p{end};
    
    % Polyfit evaluation for each sensors
    for i=1:n_sensor
        for j=1:rows(i)
            [pol, S] = polyfit(t_p{i}, value_p{i}(j,:), degree);
            
            if i==n_sensor
                m(j) = polyval(pol(1:end-1), t_analyse{i}(end));
            end
            next = polyval(pol, t_analyse{i}(end),S);
            variation_p{i}(j) = next-y_analyse{i}(j,end);
        end
        
        y_next_p{i} = y_analyse{i}(:,end) + variation_p{i};
    end
end