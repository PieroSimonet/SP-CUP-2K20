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
    
    data{1}(i) = msgVoltage{i}.Voltage;

    dataPos{1}(i) = msgOdom{i,1}.Pose.Pose.Position.X;
    dataPos{2}(i) = msgOdom{i,1}.Pose.Pose.Position.Y;
    dataPos{3}(i) = msgOdom{i,1}.Pose.Pose.Position.Z;

    dataPos{4}(i) = msgImu{i,1}.LinearAcceleration.X;
    dataPos{5}(i) = msgImu{i,1}.LinearAcceleration.Y;
    dataPos{6}(i) = msgImu{i,1}.LinearAcceleration.Z;

    dataAng{1}(i) = msgOdom{i,1}.Twist.Twist.Linear.X;
    dataAng{2}(i) = msgOdom{i,1}.Twist.Twist.Linear.Y;
    dataAng{3}(i) = msgOdom{i,1}.Twist.Twist.Linear.Z;

    dataAng{4}(i) = msgImu{i,1}.AngularVelocity.X;
    dataAng{5}(i) = msgImu{i,1}.AngularVelocity.Y;
    dataAng{6}(i) = msgImu{i,1}.AngularVelocity.Z;
        
    time(i) = i;
    
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
    
        RealTimePrint(data,time,1);
    end

    i = i+1;
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    numForest = OptimizeParameter( numForest );
end

