%% Input

% error         - variazione dal valore calcolato (errore)          [double[]]
% v_calc_utile  - valore calcolato dal fit polinomiale (senza zeri) [double[]]

%% Output

% varp_error_tot    - variazione percentuale media errore (variabile di supporto per test)  [double[]]
% varp_error1       - variazione percentuale errore aggionata (senza n_elementi_computati)  [double[]]

function [varp_error_tot, varp_error1] = calc_varp_error(error, v_calc_utile)
    
    [rows, columns] = size(error);

    % varp_error   -> [n_elementi_computati varp_error1]
    persistent varp_error
    
    if isempty(varp_error)
        varp_error = zeros(rows+1, columns);
    end
    
    % varp_error1  -> vettore contenente le variazioni medie per ogni dimensione
    
    % Somme variazioni precedenti
    varp_error(2:rows+1,:) = varp_error(1,:).*varp_error(2:rows+1,:);
    
    % Computazione dell'ultima variazione
    varp_error(1,:) = varp_error(1,:)+1; 
    varp_error(2:rows+1,:) = (varp_error(2:rows+1,:) + abs(error))./abs(v_calc_utile);
    
    % Creazione della percentuale media
    varp_error(2:rows+1,:) = varp_error(2:rows+1,:)./varp_error(1,:);
    
    varp_error_tot = varp_error;
    varp_error1 = varp_error(2:rows+1,:);
    
end