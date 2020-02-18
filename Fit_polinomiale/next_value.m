%% Input

% time          - ultimo istante                                        [double]
% value         - valore rilevati nell'ultimo istante                   [double[]]
% pol           - coefficienti grado                                    [double[]]
% S             - vettore precisione                                    [double[]]
% gap           - intervallo per non identificare un picco [%]          [double]
% var_forest    - varianza degli errori fra polyfit e valore misurato   [double[]]

%% Output

% anomaly       - presenza dell'anomalia        [boolean]
% v_forest      - valore per la foresta         [double[]]
% v_calc        - valore calcolato successivo   [double[]]
% var_forest    - ...                           [double[]]

%% Function

function [anomaly, v_forest, v_calc, var_forest] = next_value(time, value, pol, S, gap, var_forest)
    
    % rows -> numero di dimensioni
    [rows, columns] = size(value);
    
    % Inizializzazione vettori
    v_forest = zeros(rows,1);
    sigma = zeros(rows,1);
    
    % polyval per ogni dimensione
    for i=1:rows
        
        [v_next, SQM] = polyval(pol(i,:),time,S(i,:));
        
        v_forest(i,1) = v_next-value(i,1);
        sigma(i) = SQM;
        
    end
    
    % Verifica presenza anomalia
    
    v_calc = v_forest + value;
    
    [anomaly, var_forest] = range_peak(v_forest, v_calc, gap, sigma, var_forest);
    
    
end