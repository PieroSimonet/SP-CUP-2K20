percorso='Data/IMU&camera Drone Synchronized training dataset_normal behabiour_no abnormalities.bag';
percorso2='Data/IMU&camera_Initial data set for abnormalities training_2 Dec 2019.bag';
bag=rosbag(percorso);
%bag=rosbag(percorso2);
%Trovo tutti i sensori e quanti dati hanno raccolto

sensori=bag.AvailableTopics;
sensori=sensori.Properties.RowNames;
    
   %% Topic: /pylon_camera_node/image_raw
bSel_img_raw= select(bag,'Topic','/pylon_camera_node/image_raw'); 
msgStruct_img_raw = readMessages(bSel_img_raw,'DataFormat','struct');

figure;
for i = 1:length(msgStruct_img_raw)
    msg_image = rosmessage('sensor_msgs/Image');
    msg_image.Data = msgStruct_img_raw{i,1}.Data;
    msg_image.Height = msgStruct_img_raw{i,1}.Height;
    msg_image.Width = msgStruct_img_raw{i,1}.Width;
    msg_image.Step = msgStruct_img_raw{i,1}.Step;
    msg_image.Encoding = msgStruct_img_raw{i,1}.Encoding;
    imageFormatted = readImage(msg_image);
    %imshow(imrotate(imageFormatted, 180));
    filename=[num2str(i) '.jpeg'];
    imwrite(imrotate(imageFormatted, 180),filename);   
end
    