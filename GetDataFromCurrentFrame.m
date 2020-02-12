function [message] = GetDataFromCurrentFrame(fileName,topic)
%GETCURRENTFRAME Get the current topic information from the rosbag file
%   More info here

    persistent frameNumber;
    if isempty(frameNumber)
        frameNumber = 1;
    end

    persistent oldFileName;
    persistent bagMsgs;
    if isempty(oldFileName)
        oldFileName = fileName;
        bagMsgs = ros.Bag.parse(fileName);
    end

    % reset parameter if filename is changed
    if oldFileName ~= fileName
        frameNumber = 0;
        oldFileName = fileName;
        bagMsgs = ros.Bag.parse(fileName);
    end

    deltaTime = 0.26;

    endTime = bagMsgs.StartTime + deltaTime * frameNumber;
    
    if endTime > bagMsgs.EndTime
        endTime = bagMsgs.EndTime;
    end
    
    bagMsgs2 = select(bagMsgs, 'Time', [bagMsgs.StartTime endTime], 'Topic', topic);
    message = readMessages(bagMsgs2);
    frameNumber = frameNumber + 1;
end

