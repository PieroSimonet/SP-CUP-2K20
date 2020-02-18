%% Input

% var_forest    - varianza degli errori fra polyfit e valore misurato   [double]
% v_forest      - valore per la foresta                                 [double[]]

%% Output

% out - vettore varianza foresta aggionata [n_elementi var_forest1[]]   [double[]]
% var_forest1 - varianza foresta aggionata                              [double[]]

function [out, var_forest1] = calc_var_forest(var_forest, v_forest)
    
    [rows, columns] = size(v_forest);
    
    var_forest(2:rows+1,:) = var_forest(1,:).*var_forest(2:rows+1,:);
    var_forest(1,:) = var_forest(1,:)+1; 
    
    var_forest(2:rows+1) = var_forest(2:rows+1) + abs(v_forest);
    
    var_forest(2:rows+1,:) = var_forest(2:rows+1,:)./var_forest(1,:);
    
    out = var_forest;
    var_forest1 = var_forest(2:rows+1,:);
    
end