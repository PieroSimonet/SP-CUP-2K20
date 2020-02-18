%% Input

% var_forest    - varianza degli errori fra polyfit e valore misurato   [double]
% value         - valore rilevati nell'ultimo istante                   [double[]]
% gap           - intervallo per non identificare un picco [%]          [double]
% sigma         - precisione polyfit (varianza sitimatore)              [double]
% var_forest    - varianza degli errori fra polyfit e valore misurato   [double]
% v_next_tot    - valore successivo stimanto dal polyfit                [double[]]

%% Output

% anomaly       - presenza dell'anomalia    [boolean]
% var_forest    - ...                       [double]

%% Function

function [anomaly, var_forest] = range_peak(v_forest, value, gap, sigma, var_forest)
    
    % Adattamento soglia in base alla precisione e al valore
    
    % Ricalcolo varianza foresta
    [var_forest, var_forest1] = calc_var_forest(var_forest, v_forest);
    
    % Calcolo massima variazione
    % sigma -> previsione polyfit( generalmento 50% dei valori successivi sono interni)
    % gap.*ones(size(v_forest)) -> percentuale errore rispetto al segnale da noi impostato
    % var_forest1 -> varianza media foresta
    var = max([sigma, gap.*ones(size(v_forest)), var_forest1], [], 2);  %<- potrebbe avere senso
    
    % se value è minore di 1 -> perc = v_forest
    less_1 = value<1;
    not_less_1 = 1-less_1;
    
    % se value è maggiore di 10 -> perc = v_forest
    more_10 = value>10;
    not_more_10 = 1-less_1;
    
    outside = less_1+more_10;
    inside = not_less_1+not_more_10;
    
    % Percentuale di variazione rispetto al valore sitimato
    perc = v_forest.*outside + (v_forest./value).*inside;
    
    % upper -> vettore contentete i superiori
    upper = perc > var;
    
    % lower -> vettore contenete gli inferiori
    lower = perc < -var;
    
    % check -> numero di elementi >|gap*value|
    check = sum(upper + lower);
    
    if check>0
        anomaly = true;
    else
        anomaly = false;
    end
    
end

    %var = max(sigma, gap.*value);  %<- potrebbe avere senso
    %var = gap;                     %<- funziona bene se voglio vedere variazioni elevate
    %var = gap*value;               %<- funziona bene se voglio vedere variazioni elevate
    %var = sigma;                   %<- da libreria dice che contiene il 50% dei futuri valori <- non funziona molto bene
    % sigma-> precisione polyfit -> più è preciso, più dovrebbe avere senso il valore successio
                                %-> inversamente proporzionale a sigma