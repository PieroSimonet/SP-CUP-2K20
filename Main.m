CicleIsNotDone = true;
old= -1;
i = 1;

while CicleIsNotDone
    msg = GetDataFromCurrentFrame('2020-01-17-11-32-12.bag','/mavros/battery');
    
    data(i) = msg{i}.Voltage;
    time(i) = i;
    
    RealTimePrint(data,time);
    
    now = length(msg);
    if now == old
        CicleIsNotDone = false;
    end
    old = now;
    i = i+1;
end

clear all