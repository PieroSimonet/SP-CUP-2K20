%% Input

% v_forest      - valore per la foresta (errore)                    [double[]]
% v_calc_utile  - valore calcolato dal fit polinomiale (senza zeri) [double[]]

%% Output

% varp_forest_tot   - variazione percentuale media foresta (variabile di supporto per test)  [double[]]
% varp_forest1      - variazione percentuale foresta aggionata (senza n_elementi_computati) [double[]]

function [varp_forest_tot, varp_forest1] = calc_varp_forest(v_forest, v_calc_utile)
    
    [rows, columns] = size(v_forest);

    % varp_forest   -> [n_elementi_computati varp_forest1]
    persistent varp_forest
    
    if isempty(varp_forest)
        varp_forest = zeros(rows+1, columns);
    end
    
    % varp_forest1  -> vettore contenente le variazioni medie per ogni dimensione
    
    % Somme variazioni precedenti
    varp_forest(2:rows+1,:) = varp_forest(1,:).*varp_forest(2:rows+1,:);
    
    % Computazione dell'ultima variazione
    varp_forest(1,:) = varp_forest(1,:)+1; 
    varp_forest(2:rows+1,:) = (varp_forest(2:rows+1,:) + abs(v_forest))./abs(v_calc_utile);
    
    % Creazione della percentuale media
    varp_forest(2:rows+1,:) = varp_forest(2:rows+1,:)./varp_forest(1,:);
    
    varp_forest_tot = varp_forest;
    varp_forest1 = varp_forest(2:rows+1,:);
    
end