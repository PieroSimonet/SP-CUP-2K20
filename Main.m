CicleIsNotDone = true;
old= -1;
i = 1;

OptimizeParameter();
while CicleIsNotDone
    msg = GetDataFromCurrentFrame('2020-01-17-11-32-12.bag','/mavros/battery');
    
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