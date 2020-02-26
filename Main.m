addpath('./Fit_polinomiale/');

close all;

run InizializeNameOfFiles.m;

i = 1;

OptimizeParameter();

while HaveNextFrame(file1)
    msg = GetDataFromCurrentFrame(file1, batteryVoltage, false);
    
    data{1}(i) = msg{i}.Voltage;
    data{2}(i) = msg{i}.Current;
    
    time(i) = i;

   % peakDetected_V = FindPieakWrapper(time,data{1}, degree, gap, num);
    %when_V = find(peakDetected-V);
%     if ~(isempty(when_V))
%        disp('Anomalie in\n');
%        disp(num2str(when_V,'\n'));
%     end

    % IsolationForest();
    KalmanFilter();
    AnomalyDetection();
    
    

    RealTimePrint(data,time,1);

    i = i+1;
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    OptimizeParameter();
end

clear all