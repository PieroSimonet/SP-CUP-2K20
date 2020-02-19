%% Input

% varp_forest   - variazione percentuale media foresta              [double[]]
% v_forest      - valore per la foresta (errore)                    [double[]]
% v_calc_utile  - valore calcolato dal fit polinomiale (senza zeri) [double[]]

%% Output

% out           - vettore variazione percentuale foresta aggionata                      [double[]]
% varp_forest1	- variazione percentuale foresta aggionata (senza n_elementi_computati) [double[]]

function [out, varp_forest1] = calc_varp_forest(varp_forest, v_forest, v_calc_utile)
    
    % varp_forest   -> [n_elementi_computati varp_forest1]
    % varp_forest1  -> vettore contenente le variazioni medie per ogni dimensione
    
    [rows, columns] = size(v_forest);
    
    % Somme variazioni precedenti
    varp_forest(2:rows+1,:) = varp_forest(1,:).*varp_forest(2:rows+1,:);
    
    % Computazione dell'ultima variazione
    varp_forest(1,:) = varp_forest(1,:)+1; 
    varp_forest(2:rows+1,:) = (varp_forest(2:rows+1,:) + abs(v_forest))./abs(v_calc_utile);
    
    % Creazione della percentuale media
    varp_forest(2:rows+1,:) = varp_forest(2:rows+1,:)./varp_forest(1,:);
    
    out = varp_forest;
    varp_forest1 = varp_forest(2:rows+1,:);
    
end