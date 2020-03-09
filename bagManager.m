classdef bagManager
    %TIMEMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartTime
        EndTime
        CurrentTime
        BagFile
        Data
        MainIndex
        VoltageIndex
        OdomIndex
        LastTimeDone
    end
    
    methods
        function obj = bagManager(FilePath)
            %TIMEMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.BagFile = ros.Bag.parse(FilePath);
            obj.StartTime = obj.BagFile.StartTime;
            obj.EndTime = obj.BagFile.EndTime;
            obj.CurrentTime = obj.StartTime + 0.25;
            obj.MainIndex = 1;
            obj.VoltageIndex = 1;
            obj.OdomIndex = 1;
            obj.LastTimeDone = false;
            obj = obj.updateData();
        end
        
        function obj = updateTime(obj, deltaTime)

            % check if I've done read the entire table
            if obj.CurrentTime > obj.EndTime
                obj.LastTimeDone = true;
            end

            obj.CurrentTime = obj.CurrentTime + deltaTime;
            obj = obj.updateData();
        end

        function data = getData(obj)
            data = obj.Data;
        end

        function obj = updateData(obj)

            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', "/mavros/battery");
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            for tmpIndex = obj.VoltageIndex : length(message)
                obj.Data{obj.MainIndex,1} = message{tmpIndex}.Voltage;
                obj.Data{obj.MainIndex,2} = t(tmpIndex);
                obj.Data{obj.MainIndex,3} = "voltage";
                obj.MainIndex = obj.MainIndex + 1;
                haveUpdate = true;
            end
            if haveUpdate
                obj.VoltageIndex = length(message) + 1 ;
            end


            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/local_position/odom');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            for tmpIndex = obj.OdomIndex : length(message)
                obj.Data{obj.MainIndex,1} = message{tmpIndex,1}.Pose.Pose.Position.X;
                obj.Data{obj.MainIndex,2} = t(tmpIndex);
                obj.Data{obj.MainIndex,3} = "PosX";
                obj.MainIndex = obj.MainIndex + 1;
                obj.Data{obj.MainIndex,1} = message{tmpIndex,1}.Pose.Pose.Position.Y;
                obj.Data{obj.MainIndex,2} = t(tmpIndex);
                obj.Data{obj.MainIndex,3} = "PosY";
                obj.MainIndex = obj.MainIndex + 1;
                obj.Data{obj.MainIndex,1} = message{tmpIndex,1}.Pose.Pose.Position.Z;
                obj.Data{obj.MainIndex,2} = t(tmpIndex);
                obj.Data{obj.MainIndex,3} = "PosZ";
                obj.MainIndex = obj.MainIndex + 1;
                haveUpdate = true;
            end
            if haveUpdate
                obj.OdomIndex = length(message) + 1 ;
            end

        end

    end
end

