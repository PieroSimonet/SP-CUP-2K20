% https://it.mathworks.com/help/ros/ug/work-with-rosbag-logfiles.html
% 
%  BagSelection This class represents a view of messages within a rosbag
%     The BagSelection object is an index of the messages in a rosbag.
%     You can use it to select messages based on specific criteria,
%     extract message data from a rosbag, or create a timeseries of the
%     message properties.
%  
%     To create an initial BagSelection object, use the robotics.ros.Bag.parse
%     method and a rosbag file.
%  
%     The BagSelection object properties provide information about
%     the messages in the rosbag, such as the topic names and timestamps.
%  
%     The BagSelection's select method creates a subset of the index
%     in the original object, and returns it as a new robotics.ros.BagSelection
%     object. The selection method runs quickly, with low memory overhead,
%     because it operates on the index, not on the messages and data in
%     the rosbag.
%  
%     BAGSEL = robotics.ros.BagSelection('FILEPATH', MESSAGELIST, TOPICTYPEMAP,
%     TOPICDEFINITIONMAP) creates a rosbag selection representing the N
%     messages listed in MESSAGELIST (Nx4 table). The rosbag file is located at
%     FILEPATH. TOPICTYPEMAP represents a map from topic name to message
%     type, while TOPICDEFINITIONMAP stores a map from topic name to message
%     definition. The call returns a new selection object BAGSEL.
%  
%  
%     BagSelection properties:
%        FilePath         - (Read-Only) Absolute path to rosbag file
%        StartTime        - (Read-Only) Timestamp of first message in this selection
%        EndTime          - (Read-Only) Timestamp of last message in this selection
%        NumMessages      - (Read-Only) Number of messages in this selection
%        AvailableTopics  - (Read-Only) Table of topics in this selection
%        AvailableFrames  - (Read-only) List of all available coordinate frames
%        MessageList      - (Read-Only) The list of messages in this selection
%  
%     BagSelection methods:
%        readMessages     - Deserialize and return message data
%        select           - Select a subset of messages based on given criteria
%        timeseries       - Return a timeseries object for message properties
%        getTransform     - Return transformation between two coordinate frames
%        canTransform     - Verify if transformation is available
%  
%  
%     Example:
%        % Open a rosbag and retrieve information about its contents
%        filePath = 'path/to/logfile.bag';
%  
%        % The parsing returns a selection of all messages
%        bagMsgs = robotics.ros.Bag.parse(filePath)
%  
%        % Select a subset of the messages by time and topic
%        bagMsgs2 = select(bagMsgs, 'Time', ...
%            [bagMsgs.StartTime bagMsgs.StartTime + 1], 'Topic', '/odom')
%  
%        % Retrieve the messages in the selection as cell array
%        msgs = readMessages(bagMsgs2)
%  
%        % Return message properties as time series
%        ts = timeseries(bagMsgs, 'Pose.Pose.Position.X', ...
%            'Twist.Twist.Angular.Y')
%% INIZIO CODICE
% elaborazione Bag,Topics e messaggi

percorso='Data/IMU&camera Drone Synchronized training dataset_normal behabiour_no abnormalities.bag';
percorso2='Data/IMU&camera_Initial data set for abnormalities training_2 Dec 2019.bag';
%bag=rosbag(percorso);
bag=rosbag(percorso2);
%Trovo tutti i sensori e quanti dati hanno raccolto

sensori=bag.AvailableTopics;
sensori=sensori.Properties.RowNames;
%% Inizio controlli
diagnostica(bag,sensori);
batteria(bag,sensori);
temperatura(bag,sensori);
bussola(bag,sensori);
tempo(bag,sensori);
gps(bag,sensori);
LocalPos(bag,sensori);
GPSfix(bag,sensori);
velocitaGPS(bag,sensori);
nSat(bag,sensori);
altezza(bag,sensori);
StaticPressure(bag,sensori);
IMUdata(bag,sensori);
LocPosOdom(bag,sensori);
diffPress(bag,sensori);
RawImu(bag,sensori);
FCUcompass(bag,sensori);
Velocity(bag,sensori);
state(bag,sensori);
%%-----------------------FUNZIONI------------------------------- 
%% analisi batteria
function batteria(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/battery')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    V=zeros(1,l);
    I=zeros(1,l);
    stato=zeros(1,l);
    salute=zeros(1,l);
    for i=1:l
        V(i)=messaggi{i}.Voltage;
        I(i)=messaggi{i}.Current;
        stato(i)=messaggi{i}.PowerSupplyStatus;
        salute(i)=messaggi{i}.PowerSupplyHealth;
    end
    figure(1)
    subplot(2,2,1)
    plot(t,V)
    yyaxis('right')
    plot(t,I,'r')
    axis tight
    title('FCU battery status report')
    legend('Tensione','Corrente')
    xlabel('Tempo')
    
%                 POWERSUPPLYSTATUSUNKNOWN: 0
%                POWERSUPPLYSTATUSCHARGING: 1
%             POWERSUPPLYSTATUSDISCHARGING: 2
%             POWERSUPPLYSTATUSNOTCHARGING: 3
%                    POWERSUPPLYSTATUSFULL: 4

    subplot(2,2,2)
    plot(t,stato)
    axis tight
    title('Stato')
    xlabel('Tempo')

%                 POWERSUPPLYHEALTHUNKNOWN: 0
%                    POWERSUPPLYHEALTHGOOD: 1
%                POWERSUPPLYHEALTHOVERHEAT: 2
%                    POWERSUPPLYHEALTHDEAD: 3
%             POWERSUPPLYHEALTHOVERVOLTAGE: 4
%           POWERSUPPLYHEALTHUNSPECFAILURE: 5
%                    POWERSUPPLYHEALTHCOLD: 6
%     POWERSUPPLYHEALTHWATCHDOGTIMEREXPIRE: 7
%       POWERSUPPLYHEALTHSAFETYTIMEREXPIRE: 8

    subplot(2,2,3)
    plot(t,salute)
    axis tight
    title('Salute')
    xlabel('Tempo')
end
%% analisi temperatura
function temperatura(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/temperature_baro')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    Temp=zeros(1,l);
    for i=1:l
        Temp(i)=messaggi{i}.Temperature_;
    end
    figure(2)
    plot(t,Temp)
    axis tight
    title('Temperature reported by FCU (usually from barometer)')
    ylabel('Temperatura')
    xlabel('Tempo')
end
%% compass_hdg
function bussola(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/compass_hdg')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    Temp=zeros(1,l);
    for i=1:l
        Temp(i)=messaggi{i}.Data;
    end
    figure(3)
    plot(t,Temp)
    axis tight
    title('Compass heading in degrees')
    ylabel('Gradi')
    xlabel('Tempo')
end
%% Time Reference
function tempo(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/time_reference')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    Temp=zeros(1,l);
    for i=1:l
        Temp(i)=messaggi{i}.TimeRef.Sec;
    end
    Temp=Temp-Temp(1);
    figure(4)
    plot(Temp)
    axis tight
    title('Time reference computed from SYSTEM TIME')
    xlabel('Campione')
    ylabel('Tempo')
end
%% /mavros/global_position/global' DA CORREGGERE ORIGIN
function gps(bag,sensori)    
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/global')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    T=t-t(1);
    l=length(messaggi);
    latitudine=zeros(1,l);
    longitudine=zeros(1,l);
    altitudine=zeros(1,l);
    stato=zeros(1,l);
    servizio=zeros(1,l);
    for i=1:l
        latitudine(i)=messaggi{i}.Latitude;
        longitudine(i)=messaggi{i}.Longitude;
        altitudine(i)=messaggi{i}.Altitude;
        stato(i)=messaggi{i}.Status.Status;
        servizio(i)=messaggi{i}.Status.Service;
    end

    figure(5)
    subplot(2,2,1)
    plot3(latitudine,longitudine,altitudine)
    axis tight
    title('GPS Fix')
    ylabel('latitudine')
    xlabel('longitudine')
    zlabel('altitudine')
    
    hold on
    %VISUALIZZO HOME POSITION SE PRESENTE
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/home_position/home')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    latitudine=zeros(1,l);
    longitudine=zeros(1,l);
    altitudine=zeros(1,l);
     for i=1:l
        latitudine(i)=messaggi{i}.Geo.Latitude;
        longitudine(i)=messaggi{i}.Geo.Longitude;
        altitudine(i)=messaggi{i}.Geo.Altitude;
     end
    plot3(latitudine,longitudine,altitudine,'ro')
    %Origin PROBLEMA DI DIMENSIONI??
%     k=0;
%     for i=1:length(sensori)
%         if strcmp(sensori{i},'/mavros/global_position/gp_origin')
%             k=i;
%         end
%     end
%     if k==0 
%         return;
%     end
%     msg = select(bag, 'Topic',sensori(k));
%     messaggi=readMessages(msg,'DataFormat','struct');
%     latitudineO=messaggi{1}.Position.Latitude;
%     longitudineO=messaggi{1}.Position.Longitude;
%     altitudineO=messaggi{1}.Position.Altitude;
%     plot3(latitudineO,longitudineO,altitudineO,'ro')
    hold off

    %      STATUSNOFIX: -1
    %      STATUSFIX: 0
    %      STATUSSBASFIX: 1
    %      STATUSGBASFIX: 2

    subplot(2,2,2)
    plot(T,stato)
    axis tight
    title('Stato')
    xlabel('Tempo')

    %     SERVICEGPS: 1
    %     SERVICEGLONASS: 2
    %     SERVICECOMPASS: 4
    %     SERVICEGALILEO: 8

    subplot(2,2,3)
    plot(T,servizio)
    axis tight
    title('Servizio')
    xlabel('Tempo')
    end
%% Posizione Locale
function LocalPos(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/local')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    x=zeros(1,l);
    y=zeros(1,l);
    z=zeros(1,l);
    for i=1:l
        x(i)=messaggi{i}.Pose.Pose.Position.X;
        y(i)=messaggi{i}.Pose.Pose.Position.Y;
        z(i)=messaggi{i}.Pose.Pose.Position.Z;
    end

    figure(6)
    plot3(x,y,z)
    axis tight
    title('Local coords of position and orientation in meters')
    ylabel('x')
    xlabel('y')
    zlabel('z')
end
%% GPS FIX by debice
function GPSfix(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/raw/fix')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    latitudine=zeros(1,l);
    longitudine=zeros(1,l);
    altitudine=zeros(1,l);
    stato=zeros(1,l);
    servizio=zeros(1,l);
    for i=1:l
        latitudine(i)=messaggi{i}.Latitude;
        longitudine(i)=messaggi{i}.Longitude;
        altitudine(i)=messaggi{i}.Altitude;
        stato(i)=messaggi{i}.Status.Status;
        servizio(i)=messaggi{i}.Status.Service;
    end

    figure(7)
    subplot(2,2,1)
    plot3(latitudine,longitudine,altitudine)
    axis tight
    title('GPS position fix reported by the device')
    ylabel('latitudine')
    xlabel('longitudine')
    zlabel('altitudine')
    hold on
     k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/home_position/home')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    latitudine=zeros(1,l);
    longitudine=zeros(1,l);
    altitudine=zeros(1,l);
     for i=1:l
        latitudine(i)=messaggi{i}.Geo.Latitude;
        longitudine(i)=messaggi{i}.Geo.Longitude;
        altitudine(i)=messaggi{i}.Geo.Altitude;
     end
    plot3(latitudine,longitudine,altitudine,'ro')
    hold off
%       STATUSNOFIX: -1
%          STATUSFIX: 0
%      STATUSSBASFIX: 1
%      STATUSGBASFIX: 2
  

    subplot(2,2,2)
    plot(t,stato)
    axis tight
    title('Stato')
    xlabel('Tempo')

    %     SERVICEGPS: 1
    %     SERVICEGLONASS: 2
    %     SERVICECOMPASS: 4
    %     SERVICEGALILEO: 8
    subplot(2,2,3)
    plot(t,servizio)
    axis tight
    title('Servizio')
    xlabel('Tempo')
end
%% Velocita GPS
function velocitaGPS(bag,sensori)
     k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/raw/gps_vel')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    xl=zeros(1,l);
    yl=zeros(1,l);
    zl=zeros(1,l);
    xa=zeros(1,l);
    ya=zeros(1,l);
    za=zeros(1,l);
    for i=1:l
        xl(i)=messaggi{i}.Twist.Linear.X;
        yl(i)=messaggi{i}.Twist.Linear.Y;
        zl(i)=messaggi{i}.Twist.Linear.Z;
        xa(i)=messaggi{i}.Twist.Angular.X;
        ya(i)=messaggi{i}.Twist.Angular.Y;
        za(i)=messaggi{i}.Twist.Angular.Z;
    end
    figure(8)
    subplot(2,1,1)
    plot3(xl,yl,zl)
    axis tight
    title('Velocity output from the GPS device Lineare')
    ylabel('Vy')
    xlabel('Vx')
    zlabel('Vz')
    
    subplot(2,1,2)
    plot3(xa,ya,za,'o')
    axis tight
    title('Velocity output from the GPS device Angolare')
    ylabel('Vy')
    xlabel('Vx')
    zlabel('Vz')
end
%% Numero Satelliti
function nSat(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/raw/satellites')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    nsat=zeros(1,l);
    for i=1:l
        nsat(i)=messaggi{i}.Data;
    end
    figure(9)
    plot(t,nsat,'ro','MarkerSize',4)
    axis tight
    title('Number of satellites seen by the drone')
    ylabel('Numero satelliti')
    xlabel('Tempo')
end
%% Altezza
function altezza(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/global_position/rel_alt')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    h=zeros(1,l);
    for i=1:l
        h(i)=messaggi{i}.Data;
    end
    figure(10)
    plot(t,h)
    axis tight
    title('Relative altitude')
    ylabel('Altezza')
    xlabel('Tempo')
end
%% Pressione Statica
function StaticPressure(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/static_pressure')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    pressione=zeros(1,l);
    varianza=zeros(1,l);
    for i=1:l
        pressione(i)=messaggi{i}.FluidPressure;
        varianza(i)=messaggi{i}.Variance;
    end
    figure(11)
    subplot(2,1,1)
    plot(t,pressione)
    axis tight
    title('Air pressure')
    ylabel('Pressione')
    xlabel('Tempo')
    subplot(2,1,2)
    plot(t,varianza)
    axis tight
    title('varianza')
    ylabel('Varianza')
    xlabel('Tempo')
end
%% IMU
function IMUdata(bag,sensori)
     k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/data')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    ox=zeros(1,l);%orientazione
    oy=zeros(1,l);
    oz=zeros(1,l);
    ow=zeros(1,l);
    ax=zeros(1,l);%angular velocity
    ay=zeros(1,l);
    az=zeros(1,l);
    lax=zeros(1,l);%linear velocity
    lay=zeros(1,l);
    laz=zeros(1,l);
    OC=messaggi{1}.OrientationCovariance(1);%orientation covariance
    AVC=messaggi{1}.AngularVelocityCovariance(1);%Angular vel covariance
    LAC=messaggi{1}.LinearAccelerationCovariance(1);%linear acc covariance
    for i=1:l
        ox(i)=messaggi{i}.Orientation.X;
        oy(i)=messaggi{i}.Orientation.Y;
        oz(i)=messaggi{i}.Orientation.Z;
        ow(i)=messaggi{i}.Orientation.W;
        ax(i)=messaggi{i}.AngularVelocity.X;
        ay(i)=messaggi{i}.AngularVelocity.Y;
        az(i)=messaggi{i}.AngularVelocity.Z;
        lax(i)=messaggi{i}.LinearAcceleration.X;
        lay(i)=messaggi{i}.LinearAcceleration.Y;
        laz(i)=messaggi{i}.LinearAcceleration.Z;  
    end
    figure(12)
    subplot(2,1,1)
    plot3(ax,ay,az,'o')
    axis tight
    title('Angular velocity IMU')
    ylabel('y')
    xlabel('x')
    zlabel('z')
    
    subplot(2,1,2)
    plot3(lax,lay,laz,'o')
    axis tight
    title('Linear Acceleration IMU')
    ylabel('y')
    xlabel('x')
    zlabel('z')
end
%% Local pos odom
function LocPosOdom(bag,sensori)
     k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/local_position/odom')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    position=zeros(1,3);
    orientation=zeros(l,4);
    twistlin=zeros(l,3);
    twistAng=zeros(l,3);
    for i=1:l
        position(i,1)=messaggi{i}.Pose.Pose.Position.X;
        position(i,2)=messaggi{i}.Pose.Pose.Position.Y;
        position(i,3)=messaggi{i}.Pose.Pose.Position.Z;
        orientation(i,1)=messaggi{i}.Pose.Pose.Orientation.X;
        orientation(i,2)=messaggi{i}.Pose.Pose.Orientation.Y;
        orientation(i,3)=messaggi{i}.Pose.Pose.Orientation.Z;
        orientation(i,4)=messaggi{i}.Pose.Pose.Orientation.W;
        twistlin(i,1)=messaggi{i}.Twist.Twist.Linear.X;
        twistlin(i,2)=messaggi{i}.Twist.Twist.Linear.Y;
        twistlin(i,3)=messaggi{i}.Twist.Twist.Linear.Z;
        twistAng(i,1)=messaggi{i}.Twist.Twist.Angular.X;
        twistAng(i,2)=messaggi{i}.Twist.Twist.Angular.Y;
        twistAng(i,3)=messaggi{i}.Twist.Twist.Angular.Z;
    end
    figure(13)
    subplot(2,2,2)
    plot3(orientation(:,1),orientation(:,2),orientation(:,3),'o')
    axis tight
    title('Mavros local positon odom orientation')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
    
    subplot(2,2,3)
    plot3(twistlin(:,1),twistlin(:,2),twistlin(:,3),'o')
    axis tight
    title('Mavros local positon odom Twist Linear')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
    
    subplot(2,2,4)
    plot3(twistAng(:,1),twistAng(:,2),twistAng(:,3),'o')
    axis tight
    title('Mavros local positon odom Twist Angular')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
end
%% Diagnostica
function diagnostica(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/diagnostics')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    MexCal='No intrinsic calibration found';
    counter=0;
    AnomaliaDet=0;
   %% Crea delle tabelle con tutti i messaggi (PER DEBUG)
%     
%     Livello=zeros(l,5);
%     Mex=cell(l,5);
%     Name=cell(l,5);
%     for i=1:l
%         midl=length(messaggi{i,1}.Status);
%         for k=1:midl
%         Livello(i,k)=messaggi{i}.Status(k).Level;
%         Mex(i,k)=cellstr(messaggi{i,1}.Status(k).Message);
%         Name(i,k)=cellstr(messaggi{i,1}.Status(k).Name);
%         end
%     end
%% 

 for i=1:l
        midl=length(messaggi{i,1}.Status);
        for k=1:midl                %La lunghezza di Status non è costante
        Livello=messaggi{i}.Status(k).Level;
        Mex=messaggi{i,1}.Status(k).Message;
        Name=messaggi{i,1}.Status(k).Name;
        if Livello~=0                       %0 = OKAY
           if strcmp(Mex,MexCal)
               counter=counter+1;
           else
               AnomaliaDet=AnomaliaDet+1;
               err=[Name,' ',Mex];
               disp(err);
           end
        else 
        end
        
        end
 end
 MexCal=[MexCal,': questo errore e stato rilevato ', num2str(counter),' volte \n riferito a pylon camera node: intrinsic calibration \n Anomalie trovate= ',num2str(AnomaliaDet)];
 sprintf(MexCal)
end
%% DiffPress
function diffPress(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/diff_pressure')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    FluidPress=zeros(1,l);
    var=zeros(1,l);
    for i=1:l
        FluidPress(i)=messaggi{i}.FluidPressure;
        var(i)=messaggi{i}.Variance;
    end
    figure(14)
    
    subplot(2,1,1)
    plot(t,FluidPress)
    axis tight
    title('Diff Pressure')
    ylabel('Pressione')
    xlabel('Tempo')
    
    subplot(2,1,2)
    plot(t,var)
    axis tight
    title('Varianza della pressione')
    ylabel('Varianza')
    xlabel('Tempo')
end
%% Raw IMU data without orientation
function RawImu(bag, sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/data_raw')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    ox=zeros(1,l);%orientazione
    oy=zeros(1,l);
    oz=zeros(1,l);
    ow=zeros(1,l);
    ax=zeros(1,l);%angular velocity
    ay=zeros(1,l);
    az=zeros(1,l);
    lax=zeros(1,l);%linear velocity
    lay=zeros(1,l);
    laz=zeros(1,l);
    OC=messaggi{1}.OrientationCovariance(1);%orientation covariance
    AVC=messaggi{1}.AngularVelocityCovariance(1);%Angular vel covariance
    LAC=messaggi{1}.LinearAccelerationCovariance(1);%linear acc covariance
    for i=1:l
        ox(i)=messaggi{i}.Orientation.X;
        oy(i)=messaggi{i}.Orientation.Y;
        oz(i)=messaggi{i}.Orientation.Z;
        ow(i)=messaggi{i}.Orientation.W;
        ax(i)=messaggi{i}.AngularVelocity.X;
        ay(i)=messaggi{i}.AngularVelocity.Y;
        az(i)=messaggi{i}.AngularVelocity.Z;
        lax(i)=messaggi{i}.LinearAcceleration.X;
        lay(i)=messaggi{i}.LinearAcceleration.Y;
        laz(i)=messaggi{i}.LinearAcceleration.Z;  
    end
    figure(15)
    subplot(2,1,1)
    plot3(ax,ay,az,'o')
    axis tight
    title('Raw IMU data without orientation Angular velocity')
    ylabel('y')
    xlabel('x')
    zlabel('z')
    
    subplot(2,1,2)
    plot3(lax,lay,laz,'o')
    axis tight
    title('Raw IMU data without orientation Linear Acceleration')
    ylabel('y')
    xlabel('x')
    zlabel('z')
end
%% FCU compass data
function FCUcompass(bag,sensori)
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/imu/mag')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    mx=zeros(1,l);%orientazione
    my=zeros(1,l);
    mz=zeros(1,l);
    MC=messaggi{1}.MagneticFieldCovariance(1);%Magnetic Field covariance
    for i=1:l
        mx(i)=messaggi{i}.MagneticField.X;
        my(i)=messaggi{i}.MagneticField.Y;
        mz(i)=messaggi{i}.MagneticField.Z; 
    end
    figure(16)
    plot3(mx,my,mz,'o')
    axis tight
    title('Magnetic field orientation')
    ylabel('y')
    xlabel('x')
    zlabel('z')
end
%% Velocity
function Velocity(bag,sensori)
     k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/local_position/velocity_body')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    twistlin=zeros(l,3);
    twistAng=zeros(l,3);
    for i=1:l    
        twistlin(i,1)=messaggi{i}.Twist.Linear.X;
        twistlin(i,2)=messaggi{i}.Twist.Linear.Y;
        twistlin(i,3)=messaggi{i}.Twist.Linear.Z;
        twistAng(i,1)=messaggi{i}.Twist.Angular.X;
        twistAng(i,2)=messaggi{i}.Twist.Angular.Y;
        twistAng(i,3)=messaggi{i}.Twist.Angular.Z;
    end
    figure(17)
    subplot(2,2,1)
    plot3(twistlin(:,1),twistlin(:,2),twistlin(:,3),'o')
    axis tight
    title('Drone velocity BODY Twist Linear')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
    
    subplot(2,2,2)
    plot3(twistAng(:,1),twistAng(:,2),twistAng(:,3),'o')
    axis tight
    title('Drone velocity BODY Twist Angular')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
%Velocità locale
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/local_position/velocity_local')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    l=length(messaggi);
    twistlin=zeros(l,3);
    twistAng=zeros(l,3);
    for i=1:l    
        twistlin(i,1)=messaggi{i}.Twist.Linear.X;
        twistlin(i,2)=messaggi{i}.Twist.Linear.Y;
        twistlin(i,3)=messaggi{i}.Twist.Linear.Z;
        twistAng(i,1)=messaggi{i}.Twist.Angular.X;
        twistAng(i,2)=messaggi{i}.Twist.Angular.Y;
        twistAng(i,3)=messaggi{i}.Twist.Angular.Z;
    end
    subplot(2,2,3)
    plot3(twistlin(:,1),twistlin(:,2),twistlin(:,3),'o')
    axis tight
    title('Drone velocity LOCAL Twist Linear')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
    
    subplot(2,2,4)
    plot3(twistAng(:,1),twistAng(:,2),twistAng(:,3),'o')
    axis tight
    title('Drone velocity LOCAL Twist Angular')
    ylabel('Y')
    xlabel('X')
    zlabel('Z')
end
%% State
function state(bag,sensori)
    %State=3 System is Grounded and on standby. It can be launched at any
    %time
    %State=4 System is Active and might be alredy airborne. Motors are
    %engaged
    k=0;
    for i=1:length(sensori)
        if strcmp(sensori{i},'/mavros/state')
            k=i;
        end
    end
    if k==0 
        return;
    end
    msg = select(bag, 'Topic',sensori(k));
    messaggi=readMessages(msg,'DataFormat','struct');
    t=msg.MessageList.Time;
    t=t-t(1);
    l=length(messaggi);
    Connected=zeros(1,l);
    Armed=zeros(1,l);
    Guided=zeros(1,l);
    manualInput=zeros(1,l);
    SysStatus=zeros(1,l);
    
    for i=1:l
        Connected(i)=messaggi{i}.Connected;
        Armed(i)=messaggi{i}.Armed;
        Guided(i)=messaggi{i}.Guided;
        manualInput(i)=messaggi{i}.ManualInput;
        SysStatus(i)=messaggi{i}.SystemStatus;
    end
    figure(18)
    subplot(2,3,1)
    plot(t,Connected)
    axis tight
    title('Connected')
    ylabel('Connected')
    xlabel('Tempo')
    
    subplot(2,3,2)
    plot(t,Armed)
    axis tight
    title('Armed')
    ylabel('Armed')
    xlabel('Tempo')
    %hand Control to an external controller
    subplot(2,3,3)
    plot(t,Guided)
    axis tight
    title('Guided')
    ylabel('Guided')
    xlabel('Tempo')
    
    
    subplot(2,3,4)
    plot(t,manualInput)
    axis tight
    title('Manual Input')
    ylabel('Manual Input')
    xlabel('Tempo')
    
    subplot(2,3,5)
    plot(t,SysStatus)
    axis tight
    title('Sys Status')
    ylabel('Sys Status')
    xlabel('Tempo')
end