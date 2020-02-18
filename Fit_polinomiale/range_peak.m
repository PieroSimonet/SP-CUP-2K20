%% Input

% var_forest    - varianza degli errori fra polyfit e valore misurato   [double]
% v_calc        - valore calcolato dal fit polinomiale                  [double[]]
% gap           - intervallo per non identificare un picco [%]          [double]
% sigma         - precisione polyfit (varianza sitimatore)              [double]
% var_forest    - varianza degli errori fra polyfit e valore misurato   [double[]]
% v_next_tot    - valore successivo stimanto dal polyfit                [double[]]

%% Output

% anomaly       - presenza dell'anomalia    [boolean]
% var_forest    - ...                       [double[]]

%% Function

function [anomaly, var_forest] = range_peak(v_forest, v_calc, gap, sigma, var_forest)
    
    % Adattamento soglia in base alla precisione e al valore
    
    % Ricalcolo varianza foresta
    [var_forest, var_forest1] = calc_var_forest(var_forest, v_forest);
    
    % finchè sono presenti pochi casi var_forest viene tenuta a 0
    % serve ad evitare che in caso di errori iniziali la varianza della
    % foresta, ancora molto imprecisa, infici sul risultato
    if var_forest(1,:)<10
       var_forest1 = zeros(size(var_forest1)); 
    end
    
    % se value è minore di 1 -> perc = v_forest
    less_1 = v_calc<1;
    not_less_1 = 1-less_1;
    
    % se value è maggiore di 100 -> perc = v_forest
    more_100 = v_calc>100;
    not_more_100 = 1-less_1;
    
    outside = less_1+more_100; % <- potrebbe non essere necessario
    inside = not_less_1+not_more_100; % <- potrebbe non essere necessario
    
    % v_calc_z -> quando v_calc è zero
    v_calc_z = v_calc==0;
    % v_calc_nz -> quando v_calc!=0
    v_calc_nz = 1-v_calc_z;
    
    % v_calc_utile -> tiene i valori diversi da zero, quelli uguali li pone a 1
    v_calc_utile = v_calc+v_calc_nz;
    % serve per evitare divisioni per zero senza provocare errori
    
    % Sigma -> errore relativo previsione
    Sigma = (sigma.*less_1)+(sigma.*not_less_1)./v_calc_utile;
    
    % Calcolo massima variazione
    % Sigma -> precisione polyfit
    % gap.*ones(size(v_forest)) -> percentuale errore rispetto al segnale da noi impostato
    % var_forest1 -> varianza media foresta
    var = max([Sigma, gap.*ones(size(v_forest)), var_forest1], [], 2);
    
    % Percentuale di variazione rispetto al valore sitimato
    perc = v_forest.*outside + (v_forest./v_calc_utile).*inside;
    
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