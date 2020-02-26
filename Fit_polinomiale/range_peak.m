%% Input

% error     - variazione dal valore calcolato (errore)                  [double[]]
% v_calc    - valore calcolato dal fit polinomiale                      [double[]]
% gap       - percentuale per non identificare un picco                 [double]
% sigma     - errore polyfit (v_calc+-sigma -> 50% valori successivi)   [double[]]

%% Output

% anomaly       - presenza dell'anomalia                [boolean]
% varp_error    - variazione percentuale media errore   [double[]]

%% Function

function [anomaly, varp_error] = range_peak(error, v_calc, gap, sigma)
    
    % Adattamento soglia in base alla precisione e al valore
    
    % se v_calc � minore di 1 -> perc = v_forest
    less_1 = v_calc<1;
    not_less_1 = 1-less_1;
    
    % se v_calc � maggiore di 100 -> perc = v_forest
    more_100 = v_calc>100;
    
    outside = less_1+more_100; % <- potrebbe non essere necessario
    inside = 1-outside; % <- potrebbe non essere necessario
    
    % v_calc_z -> quando v_calc � zero
    v_calc_z = v_calc==0;
    
    % v_calc_utile -> tiene i valori diversi da zero, quelli uguali li pone a 1
    v_calc_utile = v_calc+v_calc_z;
    % serve per evitare divisioni per zero
    
    % Sigma -> errore relativo previsione
    Sigma = (sigma.*less_1)+(sigma.*not_less_1)./v_calc_utile;
    
    % Ricalcolo varianza foresta
    [varp_error, varp_variation1] = calc_varp_error(error, v_calc_utile);
    
    % finch� sono presenti pochi casi var_forest viene tenuta a 0
    % serve ad evitare che in caso di errori iniziali la varianza della
    % foresta, ancora molto imprecisa, infici sul risultato
    if varp_error(1,:)<10
       varp_variation1 = zeros(size(varp_variation1)); 
    end
    
    % Calcolo massima variazione
    % Sigma -> precisione polyfit
    % gap.*ones(size(v_forest)) -> percentuale errore rispetto al segnale da noi impostato
    % var_forest1 -> varianza media foresta
    var = max([Sigma, gap.*ones(size(error)), varp_variation1], [], 2);
    
    % Percentuale di variazione rispetto al valore sitimato
    perc = error.*outside + (error.*inside)./v_calc_utile;
    
    % upper -> vettore contentete i superiori
    upper = perc > var;
    
    % lower -> vettore contenete gli inferiori
    lower = perc < -var;
    
    % check -> numero di elementi >|gap*value|
    check = sum(upper+lower);
    
    if check>0
        anomaly = true;
    else
        anomaly = false;
    end
    
end