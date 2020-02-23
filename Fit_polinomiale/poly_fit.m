%% Input

% vect      - vettore dei valori (length(vect) <= num)      [double[]]
% t_n       - vettore dei tempi (length(vect) <= num)       [double[]]
% degree    - grado fit polinomiale                         [int]

%% Output

% pol   - coefficienti grado        [double[]]
% S     - vettore errori polyfit    [double[]]

%% Function

% calcolo solo del poliyfit, non è presente la ricostruzione del finale
function [pol, S] = poly_fit(vect, t_n, degree)
    
    % rows -> numero di dimensioni
    [rows, ~] = size(vect);
    
    pol = zeros(rows, degree+1);
    S = [];
    
    % polyfit per ogni dimensione
    for i=1:rows
        
        [p, Si] = polyfit(t_n,vect(i,:),degree);
        
       	pol(i,:) = p;
        S = [S; Si];
    end
    
end