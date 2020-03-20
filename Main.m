addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;

%% Inizializzazione variabili sistema

[numForest, numElementForest, degree, num, gap, gap_k, ~] = OptimizeParameter();
bagFile = bagManager(file3);
anomaly = AnomalyDetection();
kalman_ok = zeros(2,4);

%% Vettori per i test

see = {};
test = 0;
j = 1;

%% Main

% Esistenza dati successivi
while not(bagFile.LastTimeDone())    
    % Estrazione dati
        % data - {i,1}: valori misurati
        %        {i,2}: vettore dei tempi
        %        {i,3}: tipologia dato
        data = bagFile.getData();
        
        kalman_ok = multi_kalman_ok(data, num, kalman_ok);
        
    % Controllo tutti i sensori
        % se in bagFile ci sono piu' sensori da controllare che quelli
        % principali sostituire n_sensor con il numero di sensori principali e
        % RICORDARSI DI INSERIRE QUELLI PRINCIPALI IN CIMA
        [n_sensor, ~] = size(data);
    
    for i=1:n_sensor
        %% Picchi e dati per IsolationForest
            % Picchi
            [already_analyzed, anomaly_out, index_out, variation, y_calc, data_type, kalman_ok] = FindPeaksWrapper(data{i,2}, data{i,1}, data{i,3}(1), degree, num, gap, gap_k, kalman_ok);
            %n_analysed(j,i) = length(anomaly_out{1}) - already_analyzed;
        
        if not(already_analyzed)
            
            [rows_data, ~] = size(data_type);
            
            for k=1:rows_data
            % Foresta
                [ ~, forest_anomaly, position_anomaly, ~, s] = IsolationForest( numForest, numElementForest, 0.7, data_type{k,1}, (variation{k})');
            
            % Aggiornamento riscontro picchi
                anomaly = anomaly.update(anomaly_out{k}, index_out(k), forest_anomaly, position_anomaly, data_type{k,1});
            
            % variabili aggiuntive per test -> implementarla per kalman piu' grosso
                %see = update(see, anomaly_out{1}, s, y_calc{1}, variation, data{i,3}(1));
            end
            
        end
    end
    
    j = j+1;
    
    %% ANALISI ALBERI DI CHECK
    if ~isempty(anomaly.peaks)        
    end
    
    if ~isempty(anomaly.forest)        
    end
    
    % reset picchi
    %anomaly = anomaly.reset();
    
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    [numForest, numElementForest, degree, num, gap, gap_k, diffTime] = OptimizeParameter();
    
    % output funzione di ottimizzazione parametri
    new_values(j-1,:) = [numForest, numElementForest, degree, num, gap, gap_k, diffTime];
    
    bagFile = bagFile.updateTime(diffTime);
    
end

% numero elementi analizzati ad ogni ciclo per ogni sensore
n_analysed
% valore sensori
new_values

%% Plot e controlli

[rows, ~] = size(see);

for i=1:rows
    
    [rows2, ~] = size(see{i,3});
    
    figure
    plot(see{i,1})
    title(see{i,5})
    
    for j=1:rows2
        figure
        plot(see{i,3}(j,:), '-b'); % blu predetto
        hold on
        plot(data{i,1}(j,:), '-r'); % rosso misurato
        title(see{i,5})
    end
    
end

function see_new = update(see, peak_anomaly, s, y_calc, v_forest, data_type)
    
    [rows, ~] = size(see);
    
    index = 0;
    for i= 1:rows
       if data_type == see{i,5} 
            index = i;
       end
    end
    
    if index==0
        index = rows+1;
        see{index,1} = peak_anomaly;
        see{index,2} = s;
        see{index,3} = y_calc;
        see{index,4} = v_forest;
        see{index,5} = data_type;
    else
        see{index,1} = [see{index,1} peak_anomaly];
        see{index,2} = s;
        see{index,3} = [see{index,3} y_calc];
        see{index,4} = [see{index,4} v_forest];
    end
    
    see_new = see;
    
end
