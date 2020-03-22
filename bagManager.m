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
        VelocityIndex
        AngularVelocityIndex
        LinearAccelerationIndex
        TwistIndex
        StatusIndex
        CurrentIndex
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
            obj.VelocityIndex = 0;
            obj.AngularVelocityIndex = 0;
            obj.LinearAccelerationIndex = 0;
            obj.StatusIndex = 0;
            obj.TwistIndex = 0;
            obj.CurrentIndex = 0;
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
                obj.Data{obj.MainIndex + 1,1} = zeros(1,length(message));
                obj.Data{obj.MainIndex + 2,1} = zeros(1,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(i) = message{i}.Voltage;
                    obj.Data{obj.MainIndex + 1,1}(i) = message{i}.Current;
                    obj.Data{obj.MainIndex + 2,1}(i) = message{i}.Current * message{i}.Voltage;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "voltage";

                                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex + 1 ,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex +1 ,3} = "Current";

                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex + 2 ,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex + 2,3} = "Power";


                haveUpdate = true;
            end
            % update numer of elements
            if haveUpdate
                obj.VoltageIndex = length(message);
                obj.CurrentIndex = length(message);
            end
            
            % new row for the next element to load
            obj.MainIndex = obj.MainIndex + 2;


            %% extrapolation position
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/local_position/odom');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            if obj.OdomIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Pose.Pose.Position.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.Pose.Pose.Position.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.Pose.Pose.Position.Z;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Pos";                
                haveUpdate = true;        
                
                oldTime = 0;
                % calculate the velocity
                for i = 2:length(message)
                    tmpTime = obj.Data{obj.MainIndex,2}(i) - obj.Data{obj.MainIndex,2}(i-1);
                    obj.Data{obj.MainIndex + 1,1}(1,i - 1) = (obj.Data{obj.MainIndex,1}(1,i) - obj.Data{obj.MainIndex,1}(1,i-1))/tmpTime;
                    obj.Data{obj.MainIndex + 1,1}(2,i - 1) = (obj.Data{obj.MainIndex,1}(2,i) - obj.Data{obj.MainIndex,1}(2,i-1))/tmpTime;
                    obj.Data{obj.MainIndex + 1,1}(3,i - 1) = (obj.Data{obj.MainIndex,1}(3,i) - obj.Data{obj.MainIndex,1}(3,i-1))/tmpTime;
                    tmpTime = oldTime + tmpTime;
                    obj.Data{obj.MainIndex + 1 ,2}(i - 1) = tmpTime;
                end

                obj.Data{obj.MainIndex + 1,3} = "Vel";        

            end
            if haveUpdate
                obj.OdomIndex = length(message);
                obj.VelocityIndex = length(message) - 1 ;
            end
            
            % new row for the next element to load
            obj.MainIndex = obj.MainIndex + 2;


            % Twist
            haveUpdate = false;
            if obj.TwistIndex ~= length(message)

                  
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Twist.Twist.Linear.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.Twist.Twist.Linear.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.Twist.Twist.Linear .Z;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Twi";      


                haveUpdate = true;  
            end
            if haveUpdate
                obj.TwistIndex = length(message);
            end


            obj.MainIndex = obj.MainIndex + 1;
            
            %% extrapolation angular velocity
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/data');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            if obj.AngularVelocityIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.AngularVelocity.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.AngularVelocity.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.AngularVelocity.Z;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "AngularVelocity";
                
                haveUpdate = true;                
            end
            if haveUpdate
                obj.AngularVelocityIndex = length(message);
            end
            
            % new row for the next element to load
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation linear acceleration
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/data');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            if obj.LinearAccelerationIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.LinearAcceleration.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.LinearAcceleration.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.LinearAcceleration.Z;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "LinearAcceleration";
                
                haveUpdate = true;                
            end
            if haveUpdate
                obj.LinearAccelerationIndex = length(message);
            end
            
            % new row for the next element to load
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation state
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/state');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
            if obj.StatusIndex ~= length(message)
                
                obj.Data{obj.MainIndex,1} = zeros(3,length(message));
                for i=1:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.SystemStatus;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "State";
                
                haveUpdate = true;                
            end
            if haveUpdate
                obj.StatusIndex = length(message);
            end
            
            % new row for the next element to load
            obj.MainIndex = obj.MainIndex + 1;
            
            
            
            %% End of extrapolation
            obj.MainIndex = 1;
            
        end

    end
end

