addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;

%% Inizializzazione variabili sistema

[numForest, ~] = OptimizeParameter( 70 );
bagFile = bagManager(file1);
anomaly = AnomalyDetection();

% Variabili per FindPeaksWrapper
% DA INSERIRE IN OptimizerParameter

degree = 2;
num = 20;
gap = 0.2;
gap_sva = 0.1;

%% Vettori per i test

see{4} = [];
test = 0;

%% Main

% Esistenza dati successivi
while not(bagFile.LastTimeDone())    
    %% Estrazione dati
    % data - {i,1}: valori misurati
    %        {i,2}: vettore dei tempi
    %        {i,3}: tipologia dato
    data = bagFile.getData();
    
    %% Verifica se è possibile poter attivare il kalman
    % kalman_ok = kalman_activation(data);
    
    %% Controllo tutti i sensori
    % se in bagFile ci sono più sensori da controllare che quelli
    % principali sostituire n_sensor con il numero di sensori principali e
    % RICORDARSI DI INSERIRE QUELLI PRINCIPALI IN CIMA
    [n_sensor, ~] = size(data);
    
    for i=1:n_sensor
        %% Picchi e dati per IsolationForest
        [already_analyzed, peak_anomaly, first_index_peak, v_forest, y_calc] = FindPeaksWrapper(data{i,2}, data{i,1}, data{i,3}(1), degree, num, gap, gap_sva);
        
        if not(already_analyzed)
            % variabili aggiuntive per test
            see{1} = peak_anomaly;
            see{3} = [see{3} y_calc];
            see{4} = [see{4} v_forest];
            
            %% Foresta
            [ ~, forest_anomaly, position_anomaly, ~, s] = IsolationForest( numForest, 20, 0.7, data{i,3}(1) , v_forest);
            see{2} = s;
            
            %% Aggiornamento riscontro picchi
            anomaly = anomaly.update(peak_anomaly, first_index_peak, forest_anomaly, position_anomaly, data{i,3}(1));
            %  RealTimePrint(data,time,1);
        end
    end
    
    %% ANALISI ALBERI DI CHECK
    if ~isempty(anomaly.peaks)        
    end
    
    if ~isempty(anomaly.forest)        
    end
    
    % reset picchi
    anomaly = anomaly.reset();
    
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    [numForest, diffTime] = OptimizeParameter( numForest );
    
    bagFile = bagFile.updateTime(diffTime);
    
end

% Plot
% presenza anomalie
figure
plot(data{1,2}, see{1})
hold on
plot(see{2}>0.7)

% previsioni
figure
plot(data{1,2}, data{1,1})
hold on
plot(data{1,2}, see{3})

% valori passati a IsolationForest
figure
plot(data{1,2},see{4})