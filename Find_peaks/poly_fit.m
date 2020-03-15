%% TO DO

function [y_next, variation, m] = poly_fit(t_analyse, y_analyse, start, rows, degree)
    
    n_sensor = length(y_analyse);
    t{n_sensor} = [];
    value = t;
    
    y_next = t;
    for i=1:n_sensor
        y_next{i} = zeros(rows(i),1);
        t{i} = t_analyse{i}(start:end-1);
        value{i} = y_analyse{i}(:,start:end-1);
    end
    
    variation = y_next;
    
    m = y_next{end};
    
    for i=1:n_sensor
        for j=1:rows(i)
            [pol, S] = polyfit(t{i}, value{i}(j,:), degree);
        
            if i==n_sensor
                m(j) = polyval(pol(1:end-1), t_analyse{i}(end));
            end
            next = polyval(pol, t_analyse{i}(end),S);
       
            variation{i}(j) = next-y_analyse{i}(j,end);
        end
        y_next{i} = y_analyse{i}(:,end) + variation{i};
    end
end