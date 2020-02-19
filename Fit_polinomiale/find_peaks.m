%% Input

% t             - vettore dei tempi                             [double[]]
% y             - vettore dei valori misurati                   [double[]]
% degree        - grado fit polinomiale                         [int]
% gap           - percentuale per non identificare un picco     [double]
% num           - numero di campioni da prendere                [int]
% varp_forest   - variazione percentuale media foresta          [double[]]

%% Output

% anomaly       - presenza dell'anomalia                [boolean]
% v_forest      - valore per la foresta                 [double[]]
% v_calc        - valore calcolato successivo           [double[]]
% varp_forest   - variazione percentuale media foresta  [double[]]

%% Function

function [anomaly, v_forest, v_calc, varp_forest] = find_peaks(t, y, degree, gap, num, varp_forest)
    
    % start -> inizio dei vettori per mantere un numero di valori pari a num
    start = max(length(t)-num,1);

    % Ridimensionamento vettori
    t_n = t(start:end-1);
    time = t(end);
    
    vect = y(:,start:end-1);
    value = y(:,end);
    
    % Fit
    [pol, S] = poly_fit(vect, t_n, degree);
    % Anomalia e vettori per isolation forest
    [anomaly, v_forest, v_calc, varp_forest] = next_value(time, value, pol, S, gap, varp_forest);

end