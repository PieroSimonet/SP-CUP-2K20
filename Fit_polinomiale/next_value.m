%% Input

% time          - ultimo istante                                [double]
% value         - valore rilevati nell'ultimo istante           [double[]]
% pol           - coefficienti grado                            [double[]]
% S             - vettore errori polyfit                        [double[]]
% gap           - percentuale per non identificare un picco     [double]

%% Output

% anomaly       - presenza dell'anomalia                [boolean]
% v_forest      - valore per la foresta (errore)        [double[]]
% v_calc        - valore calcolato dal fit polinomiale  [double[]]
% varp_forest   - variazione percentuale media foresta  [double[]]

%% Function

function [anomaly, v_forest, v_calc, varp_forest] = next_value(time, value, pol, S, gap)
    
    % rows -> numero di dimensioni
    [rows, ~] = size(value);
    
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
    
    [anomaly, varp_forest] = range_peak(v_forest, v_calc, gap, sigma);
    
    
end