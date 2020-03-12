addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;

%% Inizializzazione variabili sistema

[numForest, numElementForest, degree, num, gap, gap_sva, ~] = OptimizeParameter();

bagFile = bagManager(file3);
anomaly = AnomalyDetection();


%% Vettori per i test

see{4,2} = [];
test = 0;

%% Main

% Esistenza dati successivi
while not(bagFile.LastTimeDone())    
    %% Estrazione dati
    % data - {i,1}: valori misurati
    %        {i,2}: vettore dei tempi
    %        {i,3}: tipologia dato
    data = bagFile.getData();
    
    %% Verifica se � possibile poter attivare il kalman
    % kalman_ok = kalman_activation(data);
    
    %% Controllo tutti i sensori
    % se in bagFile ci sono pi� sensori da controllare che quelli
    % principali sostituire n_sensor con il numero di sensori principali e
    % RICORDARSI DI INSERIRE QUELLI PRINCIPALI IN CIMA
    [n_sensor, ~] = size(data);
    
    for i=1:n_sensor
        %% Picchi e dati per IsolationForest
        
        [already_analyzed, peak_anomaly, first_index_peak, v_forest, y_calc] = FindPeaksWrapper(data{i,2}, data{i,1}, data{i,3}(1), degree, num, gap, gap_sva);
        
        
        if not(already_analyzed)
            %% Foresta
            [ ~, forest_anomaly, position_anomaly, ~, s] = IsolationForest( numForest, 20, 0.7, data{i,3}(1), v_forest');
            
            %% Aggiornamento riscontro picchi
            anomaly = anomaly.update(peak_anomaly, first_index_peak, forest_anomaly, position_anomaly, data{i,3}(1));
            
            % variabili aggiuntive per test
            if data{i,3} == "voltage"
                see{1,1} = [see{1,1} peak_anomaly];
                see{2,1} = s;
                see{3,1} = [see{3,1} y_calc];
                see{4,1} = [see{4,1} v_forest];
            else
                see{1,2} = [see{1,2} peak_anomaly];
                see{2,2} = s;
                see{3,2} = [see{3,2} y_calc];
                see{4,2} = [see{4,2} v_forest];
            end
            
            
        end
        
    end
    
    %% ANALISI ALBERI DI CHECK
    if ~isempty(anomaly.peaks)        
    end
    
    if ~isempty(anomaly.forest)        
    end
    
    % reset picchi
    %anomaly = anomaly.reset();
    
    [numForest, numElementForest, degree, num, gap, gap_sva, diffTime] = OptimizeParameter();
    
    bagFile = bagFile.updateTime(diffTime);
    
end

% Plot
% presenza anomalie
%figure
%plot(see{1,2})

% previsioni
%figure
%plot(data{2,1}(1,:))
%hold on
%plot(see{3,2}(1,:))

%figure
%plot(data{2,1}(2,:))
%hold on
%plot(see{3,2}(2,:))

%figure
%plot(data{2,1}(3,:))
%hold on
%plot(see{3,2}(3,:))


% valori passati a IsolationForest
%figure
%plot(see{4,1})