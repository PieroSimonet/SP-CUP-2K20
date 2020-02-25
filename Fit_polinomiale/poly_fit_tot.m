%% Input

% vect      - vettore dei valori (length(vect) <= num)	[double[]]
% t_n       - vettore dei tempi (length(vect) <= num)   [double[]]
% degree    - grado fit polinomiale                     [int]
% value     - valore miurato nell'ultimo istante        [double[]]
% time      - ultimo istante                            [double]

%% Output

% v_forest	- valore per la foresta (errore)        [double[]]
% v_calc    - valore calcolato dal fit polinomiale  [double[]]
% sigma     - vettore precisione previsione polyfit [double[]]

%% Function

% calcolo sia polyfit sia polyvalue
function [v_forest, v_calc, sigma] = poly_fit_tot(vect, t_n, degree, value, time)
    
    % rows -> numero di dimensioni
    [rows, ~] = size(vect);
    
    % Inizializzazione vettori
    v_forest = zeros(rows,1);
    sigma = zeros(rows,1);
    
    % polyfit per ogni dimensione
    for i=1:rows
        
        % coefficienti polyfit per ogni dimensione
        % pol -> vettore coefficienti grado
        % S -> struttura precisione polyfit per previsione
        [pol, S] = polyfit(t_n,vect(i,:),degree);
        
        % polyval per ogni dimensione
        [v_next, SQM] = polyval(pol,time,S);
        
        v_forest(i,1) = v_next-value(i,1);
        sigma(i) = SQM;
        
    end
    
    v_calc = v_forest + value;
    
end