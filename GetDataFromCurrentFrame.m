function [message] = GetDataFromCurrentFrame(fileName,topic, toUpdateFrameNumber)
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


    % can be optimized but this is not the time
    bagMsgs2 = select(bagMsgs, 'Time', [bagMsgs.StartTime bagMsgs.EndTime], 'Topic', topic);
    message = readMessages(bagMsgs2,'DataFormat','struct');

    if length(message) < frameNumber
        frameNumber = frameNumber - 1;
    end

    message = message(1:frameNumber);

    if toUpdateFrameNumber
        frameNumber = frameNumber + 1;
    end

end

