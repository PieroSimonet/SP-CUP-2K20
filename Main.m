CicleIsNotDone = true;
old= 0;
oldtime = clock;
while CicleIsNotDone
    msg = GetDataFromCurrentFrame('IMU&camera_Initial data set for abnormalities training_2 Dec 2019.bag','/mavros/imu/temperature_baro');
    now = length(msg);
    if now == old
        CicleIsNotDone = false;
    end
    old = now;
end
nowTime = clock;

old
nowTime - oldtime

clear all