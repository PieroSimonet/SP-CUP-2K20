%% lettura immagine

clear all;clc; close all;

bagMsgs = ros.Bag.parse("IMU&camera Drone Synchronized training dataset_normal behabiour_no abnormalities.bag");
bagMsgs2 = select(bagMsgs, 'Time', [bagMsgs.StartTime bagMsgs.EndTime], 'Topic', '/pylon_camera_node/image_raw');
msgs = readMessages(bagMsgs2);

% Pulisco l'allocazioni che non mi interessano più
clear bagMsgs bagMsgs2;


%% visualizzazione imagine

% edgeFIS = getFis();

for l = 1 : length(msgs)
    
    I = getImageGrayResized(msgs,l,0.5);
    
    BWs = getEdgeDetectFudge(I,0.5);
    % Metodo che richiede troppa potenza di calcolo
    % IEv = getEdgeDetectFuzzy(I,edgeFIS);
    
    figure(1)
    imshow(BWs);
    
    % figure
    % imshow(IEv);
        
    input('');
end
