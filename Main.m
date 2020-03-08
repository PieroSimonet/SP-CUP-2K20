addpath('./Find_peaks/');
addpath('./Tree/');
addpath('./Tree/Utils/');

close all;
clear all;

run InizializeNameOfFiles.m;

i = 1;

numForest = OptimizeParameter( 70 );

file = file2;

while HaveNextFrame(file)

    msgVoltage = GetDataFromCurrentFrame(file, batteryVoltage, false);
    msgImu = GetDataFromCurrentFrame(file, imuData, false);
    % msgBody = GetDataFromCurrentFrame(file, velocityBody, false);
    % msgLoca = GetDataFromCurrentFrame(file, velocityLocal, false);
    msgOdom = GetDataFromCurrentFrame(file, odom, false);

    % Push data to trees
    [t1,t2,t3] = PushTrees(msgImu{i,1}, msgOdom{i,1},true);
    
    data{1}(i) = msg{i}.Voltage;
    data{2}(i) = msg{i}.Current;

    lol{1}(i) = msg{i}.Voltage;
    
    time(i) = i;
    
    RealTimePrint(data,time,1);
    RealTimePrint(lol,time,2);
    
    now = length(msg);
    if now == old
        CicleIsNotDone = false;
    end
    old = now;
    i = i+1;
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    OptimizeParameter();
end

old

clear all