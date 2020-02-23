function [anomaly] = FindPieakWrapper(time,data, degree, gap, num)
%Fit summary
    % 1) fit polinomiale con polyfit e ricostruzione del punto con polyval (poly_fit, next_value)
    % 2) decisione sul picco percentuale fra i gap impostato, la precsìsione
    %    del fit e la varazione percentuale media delle misure (range_peak, calc_valp_forest)
    % 3) valutazione della presenza del picco (range_peak)

% Variabili output
    % anomaly       - vettore delle anomalie                [boolean[]]
    % v_forest      - valore per la foresta                 [double[]]
    % v_calc        - valore calcolato successivo           [double[]]
    % varp_forest   - variazione percentuale media foresta  [double[]]       

    % [anomaly, v_forest, v_calc, varp_forest] 
    [anomaly, ~, ~, ~]= find_peaks(time, data, degree, gap, num);

end

