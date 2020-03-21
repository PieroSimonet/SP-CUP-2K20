if exist('tmp','var')
    for i=1:tmp-1
        clf(figure (i));
    end
else
    close all
end

clear all
addpath('./Find_peaks')

%% Varibili sistema
% n_var - numero di variabili da inserire nella ricerca
    n_var = 3;

% rows - numero di dimensioni di ogni vettore
    rows(3) = 0;

    value = 1;%abs(round(3*rand));
    if value==0
        value = 1;
    end
    for i=1:3
        rows(i) = value;
    end

% Inserimento nome e dimensione in data_type
    if n_var>=1
        data_type{1,1} = "angle";
        data_type{1,2} = rows(1);
    end

    if n_var>=2
        data_type{2,1} = "angularVelocity";
        data_type{2,2} = rows(2);
    end

    if n_var==3
        data_type{3,1} = "angularAcceleration";
        data_type{3,2} = rows(3);
    end
    
%% Variabili ricerca picchi
% degree -> grado polyfit (sopra al 3 genera warning)
    degree = 1;
% gap -> massima percentuale di variazione accettabile
    gap = 0.5;
% num -> numero di elementi da inserire nel polyfit
    num = 10;
% gap_sva -> massima pendenza retta di regressione per identificare il
    gap_kalman = 0.3;

% kalman_ok
    kalman_ok = zeros(2,4);

%% Creazione vettori di test

% Tempo e valori iniziali
    F = 10;             % Frequenza di campionamento
    T = 1/F;            % Tempo fra un campione e l'altro
    N = 100;            % numero di campioni
    t_sup = (0:N-1)/F;  % vettore dei tempi

    t{3} = [];
    for i=1:3
        t{i} = t_sup;
    end

    s0 = 5*randn(rows(1),1);    % spazio iniziale
    v0 = 5*randn(rows(2),1);  % velocità iniziale
    a0 = 5*randn(rows(3),1);  % accelerazione iniziale

%% Noise
    sigmas = 0.1;
    sigmav = 0.1;
    sigmaa = 0.1;

    n{3} = [];
    n{1} = sigmas*randn(rows(1),N);
    n{2} = sigmav*randn(rows(2),N);
    n{3} = sigmaa*randn(rows(3),N);

%% Esempi test
% Spazio costante
    %y{3} = zeros(rows(3),N) + n{3};
    %y{2} = zeros(rows(2),N) + n{2};
    %y{1} = s0 + n{1};

% Velocità costante
    %y{3} = zeros(rows(3),N) + n{3};
    %y{2} = v0 + n{2};
    %y{1} = v0*t{1}+ n{3};
    
% Accelerazione costante;
    %y{3} = a0 + n{3};
    %y{2} = a0*t{2} + n{2};
    %y{1} = s0 + v0*t{1} + 0.5*a0*t{1}.^2 + n{1};
    
% Accelerazione variabile
    y{3} = a0*t{3}+ n{3};
    y{2} = v0 + 0.5*a0*t{2}.^2 + n{2};
    y{1} = s0 + v0*t{1} + (1/6)*a0*t{1}.^2+ n{1};
   
%% Valore di amplificazione (picchi)
% amps_peak -> ampiezza picchi anomali
    amp_peaks = 1.5;

%% Ricerca anomalia - inizializzazioni vettori
% vettori dei valori e dei tempi
    y1{n_var} = [];
    t1{n_var} = [];

% when - elementi in cui e' presente l'anomalia manuale
    when{n_var} = [];
% see - vettore contenente tutti i valori elaborati
    see = {};
% data - simulazione vettore in input
    data{n_var,3} = {};

%% Ricerca anomalia
for i=1:N
    % Inserimento come se fossero sequenziali
    for k=1:n_var
        y1{k} = [y1{k} y{k}(:,i)];
        t1{k} = [t1{k} t{k}(i)];
        data{k,1} = y1{k};
        data{k,2} = t1{k};
        data{k,3} = data_type{k,1};
    end
  
    % Aggiunta anomalie
    if randn(1,1)>1.5
        sensor = round((n_var-1)*rand+1);
        y1{sensor}(:,i) = (y1{sensor}(:,i)).*(amp_peaks+0.1.*randn(size(y1{sensor}(:,i))));
        when{sensor} = [when{sensor} i];
    end

    kalman_ok = multi_kalman_ok(data, num, kalman_ok);
    
    % Per ogni variabile
    for k=1:n_var
        
        % Calcoli e acquisizione valori 
        [already_analysed, anomaly, index_out, variation, y_calc, data_type_out, kalman_ok] = FindPeaksWrapper(t1{k}, y1{k}, data_type{k,1}, degree, num, gap, gap_kalman, kalman_ok);

        if ~already_analysed
            degree = 2;
            [rows_data, ~] = size(data_type_out);
            % Per ogni elemento in output dalla funzione di ricerca picchi
            for j=1:rows_data
                see = update(see, anomaly{j}, variation{j}, y_calc{j}, data_type_out{j}(1));
            end
            tmp = plot_all(see, when, y1, data_type, y, rows);
        end
    end
end

%% Plot

function tmp = plot_all(see, when,y1, data_type, y, rows)
    % on - attivazione plot (disattivare per vedere prestazioni generali)
        on = true;

    if on
        % tmp - variabile di supporto per  i grafici
            tmp = 1;

        [rows_see, ~] = size(see);
        for k = 1:rows_see
            for j=1:rows(k)
                % Visualizzazione previsioni
                figure (tmp)
                plot(see{k,3}(j,:),'-b'); % blu predetto
                hold on
                plot(y1{k}(j,:),'-k') % nero misurato
                title(data_type{k,1})
                plot(when{k}, y{k}(j,when{k}), '+g') % punti anomalia
                plot(find(see{k,1}), see{k,3}(j,find(see{k,1})), '+r') % punti anomalia
                tmp = tmp+1;

                % Visualizzazione errori
                %figure (a)
                %plot(see{k,2}(j,:))
                %title(data_type{k,1})
                %tmp = tmp+1;
            end
        end
    end
end

% update - funzione di supporto per la visualizzazione dei dati
function see_new = update(see, anomaly, variation, y_calc, data_type)
    
    [rows, ~] = size(see);
    
    index = 0;
    for i= 1:rows
       if data_type == see{i,4} 
            index = i;
       end
    end
    
    if index==0
        index = rows+1;
        see{index,1} = anomaly;
        see{index,2} = variation;
        see{index,3} = y_calc;
        see{index,4} = data_type;
    else
        see{index,1} = [see{index,1} anomaly];
        see{index,2} = [see{index,2} variation];
        see{index,3} = [see{index,3} y_calc];
    end
    
    see_new = see;
    
end