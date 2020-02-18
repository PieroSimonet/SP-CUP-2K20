run InizializeNameOfFiles.m;

i = 1;

OptimizeParameter();

while HaveNextFrame(file1)
    msg = GetDataFromCurrentFrame(file1, batteryVoltage, false);
    
    data{1}(i) = msg{i}.Voltage;
    data{2}(i) = msg{i}.Current;
    
    time(i) = i;

    Fit();
    % IsolationForest();
    KarmanFilter();
    AnomalyDetection();
    
    RealTimePrint(data,time,1);

    i = i+1;
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    OptimizeParameter();
end

clear all