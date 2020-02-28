function [anomaly, v_forest, v_calc, varp_forest] = FindPeakWrapper(time,data,datatipe)
%Fit summary
    % 1) fit polinomiale con polyfit e ricostruzione del punto con polyval (poly_fit, next_value)
    % 2) decisione sul picco percentuale fra i gap impostato, la precs�sione
    %    del fit e la varazione percentuale media delle misure (range_peak, calc_valp_forest)
    % 3) valutazione della presenza del picco (range_peak)

% Variabili output
    % anomaly       - vettore delle anomalie                [boolean[]]
    % v_forest      - valore per la foresta                 [double[]]
    % v_calc        - valore calcolato successivo           [double[]]
    % varp_forest   - variazione percentuale media foresta  [double[]]       

    % [anomaly, v_forest, v_calc, varp_forest] 

    persistent seenArgument;
    persistent returningArray;
    if isempty(seenArgument)
        seenArgument{1} = datatipe;
        returningArray{1} = [];
    end

    isSeenArgument = false;
    SeenArgumentIndex = -1;

    for index = 1 : length(seenArgument)
        if seenArgument{index} == datatipe
            isSeenArgument = true;
            SeenArgumentIndex = index;
        end
    end

    if not(isSeenArgument)
        SeenArgumentIndex = length(seenArgument) + 1;
        seenArgument{SeenArgumentIndex} = datatipe;
        returningArray{SeenArgumentIndex} = [];
    end

    degree = 2;
    gap = 0.5; 
    num = 20;

    [anomaly_tmp, v_forest, v_calc, varp_forest] = find_peaks(time, data, degree, gap, num);
    
    returningArray{SeenArgumentIndex} = [returningArray{SeenArgumentIndex} anomaly_tmp];

    anomaly = returningArray{SeenArgumentIndex};

end

