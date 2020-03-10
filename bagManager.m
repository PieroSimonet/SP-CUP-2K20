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
            obj.VoltageIndex = 0;
            obj.OdomIndex = 0;
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
            
            % voltage
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', "/mavros/battery");
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            %% extrapolation voltage
            if obj.VoltageIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(1,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(i) = message{i}.Voltage;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "voltage";
                
                % new row for the next element to load
                obj.MainIndex = obj.MainIndex + 1;
                haveUpdate = true;
            end
            % update numer of elements
            if haveUpdate
                obj.VoltageIndex = length(message);
            end

            %% extrapolation position
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/local_position/odom');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            if obj.OdomIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Pose.Pose.Position.X;
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Pose.Pose.Position.Y;
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Pose.Pose.Position.Z;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Pos";
                
                % new row for the next element to load
                obj.MainIndex = obj.MainIndex + 1;
                haveUpdate = true;                
            end
            if haveUpdate
                obj.OdomIndex = length(message);
            end
            
            %% End of extrapolation
            obj.MainIndex = 1;
            
        end

    end
end

