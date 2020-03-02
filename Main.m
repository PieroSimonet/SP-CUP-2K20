addpath('./Find_peaks/');

close all;
clear all;

run InizializeNameOfFiles.m;

i = 1;

OptimizeParameter();

while HaveNextFrame(file1)
    msg = GetDataFromCurrentFrame(file1, batteryVoltage, false);
    
    data{1}(i) = msg{i}.Voltage;
    % data{2}(i) = msg{i}.Current;
    
    time(i) = i;
    
    degree = 2;
    num = 20;
    gap = 0.5;
    gap_sva = 0.1;
    
    [already_analyzed, anomaly, v_forest, ~] = FindPeaksWrapper(time, data{1}, "batteryVoltage", degree, num, gap, gap_sva);
    
    if not(already_analyzed)
        data{2} = anomaly;
        [ ~, an, ps, ~, s] = IsolationForest( 90, 20, 0.7, "batteryVoltage" , v_forest);
        data{3} = s * 10; % Scalo il vettore s per vedere un po com'è la situazione
        
        AnomalyDetection(anomaly,s,[]);
    
        RealTimePrint(data,time,1);
    end

    i = i+1;
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    OptimizeParameter();
end

