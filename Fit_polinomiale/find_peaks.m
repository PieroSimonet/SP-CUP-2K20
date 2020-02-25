%% Input

% t             - vettore dei tempi                             [double[]]
% y             - vettore dei valori misurati                   [double[]]
% degree        - grado fit polinomiale                         [int]
% gap           - percentuale per non identificare un picco     [double]
% num           - numero di campioni da prendere                [int]

%% Output

% anomaly       - vettore delle anomalie                [boolean[]]
% v_forest      - valore per la foresta                 [double[]]
% v_calc        - valore calcolato successivo           [double[]]
% varp_forest   - variazione percentuale media foresta  [double[]]

%% Function

function [anomaly, v_forest, v_calc, varp_forest] = find_peaks(t, y, degree, gap, num)
    
    % anomaly_v -> vettore di supporto contenente il vettore di anomalie
    persistent anomaly_v;
    
    % controllo che il vettore non sia troppo corto
    % degree+2 -> necessario per il polyfit (es. per due punti passa una sola retta)
    % [ SE METTIAMO degree+1 PER UN SET DI PUNTI ABBIAMO ERRORE "INFINITO" PERCHè NON HA GRADI DI LIBERTà SUPPLEMENTARI ]
    % +1 -> necessario per capire che punto valutare
    if length(t)<degree+3
        y_fin = y(:,length(t));
        [rows, columns] = size(y_fin); 
        anomaly_v = [anomaly_v false];
        anomaly = anomaly_v;
        v_forest = zeros(rows, columns);
        v_calc = y_fin;
        varp_forest = zeros(rows+1, columns);
        return
    end

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
    [anomaly_p, v_forest, v_calc, varp_forest] = next_value(time, value, pol, S, gap);
    
    anomaly_v = [anomaly_v anomaly_p];
    anomaly = anomaly_v;

end