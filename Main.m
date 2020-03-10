addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;

% inizializzazione variabili
i = 1;
[numForest, ~] = OptimizeParameter( 70 );
bagFile = bagManager(file1);
% vettore di visualizzazione
see{4} = [];
test = 0;

while not(bagFile.LastTimeDone())

    % data - {i,1}: valori misurati
    %        {i,2}: vettore dei tempi
    %        {i,3}: tipologia dato
    
    data = bagFile.getData();
    
    degree = 2;
    num = 20;
    gap = 0.2;
    gap_sva = 0.1;
    
    [already_analyzed, anomaly, v_forest, y_calc] = FindPeaksWrapper(data{1,2}, data{1,1}, data{1,3}(1), degree, num, gap, gap_sva);
    
    if already_analyzed
        test = test+1;
    end
    if not(already_analyzed)
        see{1} = anomaly;
        see{3} = [see{3} y_calc];
        see{4} = [see{4} v_forest];
        
        [ ~, an, ps, ~, s] = IsolationForest( numForest, 20, 0.7, data{1,3}(1) , v_forest');
        see{2} = s;
        
        AnomalyDetection(anomaly,s,[]);
        
        
       %  RealTimePrint(data,time,1);
    end

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