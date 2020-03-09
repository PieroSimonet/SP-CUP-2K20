addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;


i = 1;

[numForest, ~] = OptimizeParameter( 70 );

bagFile = bagManager(file2);

while not(bagFile.LastTimeDone())

    Data = bagFile.getData();
    
    degree = 2;
    num = 20;
    gap = 0.5;
    gap_sva = 0.1;
    
    [already_analyzed, anomaly, v_forest, ~] = FindPeaksWrapper(time, data{1}, "batteryVoltage", degree, num, gap, gap_sva);
    
    if not(already_analyzed)
        data{2} = anomaly;
        [ ~, an, ps, ~, s] = IsolationForest( numForest, 20, 0.7, "batteryVoltage" , v_forest);
        data{3} = s * 10; % Scalo il vettore s per vedere un po com'è la situazione
        
        AnomalyDetection(anomaly,s,[]);
    
       %  RealTimePrint(data,time,1);
    end

    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    [numForest, diffTime] = OptimizeParameter( numForest );
    bagFile = bagFile.updateTime(diffTime);
end

