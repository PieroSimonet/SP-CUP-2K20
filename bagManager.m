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
        AltitudineIndex
        PressureIndex
        TemperatureIndex
        GpsVelIndex
        LastTimeDone
    end
    
    methods
        function obj = bagManager(FilePath)
            %TIMEMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.BagFile = ros.Bag.parse(FilePath);
            obj.StartTime = obj.BagFile.StartTime;
            obj.EndTime = obj.BagFile.EndTime;
            obj.CurrentTime = obj.StartTime + 0.51;
            obj.MainIndex = 1;
            obj.VoltageIndex = 1;
            obj.OdomIndex = 1;
            obj.VelocityIndex = 2;
            obj.AngularVelocityIndex = 1;
            obj.LinearAccelerationIndex = 1;
            obj.StatusIndex = 1;
            obj.TwistIndex = 1;
            obj.AltitudineIndex = 1;
            obj.PressureIndex = 1;
            obj.TemperatureIndex = 1;
            obj.GpsVelIndex = 1;
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

                for i=obj.VoltageIndex:length(message)
                    obj.Data{obj.MainIndex,1}(i) = message{i}.Voltage;
                    obj.Data{obj.MainIndex + 1,1}(i) = message{i}.Current;
                    obj.Data{obj.MainIndex + 2,1}(i) = message{i}.Current * message{i}.Voltage;
                    
                    haveUpdate = true;
                end
                
                
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


            
            % update numer of elements
            if haveUpdate
                obj.VoltageIndex = length(message);
                % new row for the next element to load
            end

            obj.MainIndex = obj.MainIndex + 3;

            %% extrapolation position
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/local_position/odom');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
                for i=obj.OdomIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Pose.Pose.Position.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.Pose.Pose.Position.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.Pose.Pose.Position.Z;
                    haveUpdate = true; 
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Pos";                
                       
                
                oldTime = 0;
                % calculate the velocity
                for i = obj.VelocityIndex:length(message)
                    tmpTime = obj.Data{obj.MainIndex,2}(i) - obj.Data{obj.MainIndex,2}(i-1);
                    obj.Data{obj.MainIndex + 1,1}(1,i - 1) = (obj.Data{obj.MainIndex,1}(1,i) - obj.Data{obj.MainIndex,1}(1,i-1))/tmpTime;
                    obj.Data{obj.MainIndex + 1,1}(2,i - 1) = (obj.Data{obj.MainIndex,1}(2,i) - obj.Data{obj.MainIndex,1}(2,i-1))/tmpTime;
                    obj.Data{obj.MainIndex + 1,1}(3,i - 1) = (obj.Data{obj.MainIndex,1}(3,i) - obj.Data{obj.MainIndex,1}(3,i-1))/tmpTime;
                    tmpTime = oldTime + tmpTime;
                    obj.Data{obj.MainIndex + 1 ,2}(i - 1) = tmpTime;
                end

                obj.Data{obj.MainIndex + 1,3} = "Vel";        

            
            if haveUpdate
                obj.OdomIndex = length(message);
                obj.VelocityIndex = length(message) - 1 ;
                if obj.VelocityIndex < 2
                    obj.VelocityIndex = 2;
                end
            end

            
            obj.MainIndex = obj.MainIndex + 2;
            
            % Twist
            haveUpdate = false;
            
                for i=obj.TwistIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Twist.Twist.Linear.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.Twist.Twist.Linear.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.Twist.Twist.Linear.Z;
                    
                    haveUpdate = true;  
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Twi";      


            
            if haveUpdate
                obj.TwistIndex = length(message);
            end

            
            obj.MainIndex = obj.MainIndex + 1;
            
            %% extrapolation angular velocity
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/data');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            

                for i=obj.AngularVelocityIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.AngularVelocity.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.AngularVelocity.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.AngularVelocity.Z;
                    haveUpdate = true; 
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "AngularVelocity";
                
                
            if haveUpdate
                obj.AngularVelocityIndex = length(message);
            end
                        
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation linear acceleration
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/data');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
                for i=obj.LinearAccelerationIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.LinearAcceleration.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.LinearAcceleration.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.LinearAcceleration.Z;
                    haveUpdate = true;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "LinearAcceleration";
                
                haveUpdate = true;                
            
            if haveUpdate
                obj.LinearAccelerationIndex = length(message);
            end
            obj.MainIndex = obj.MainIndex + 1;
            
            %% extrapolation state
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/state');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;
            
        
                for i=obj.StatusIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.SystemStatus;
                    haveUpdate = true;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "State";
                
                                
             
            if haveUpdate
                obj.StatusIndex = length(message);
            end
            
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation gpsVel
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/global_position/raw/gps_vel');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;

                for i=obj.GpsVelIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Twist.Linear.X;
                    obj.Data{obj.MainIndex,1}(2,i) = message{i}.Twist.Linear.Y;
                    obj.Data{obj.MainIndex,1}(3,i) = message{i}.Twist.Linear.Z;
                    haveUpdate = true; 
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "v_gps";                
                       

            
            if haveUpdate
                obj.GpsVelIndex = length(message);
            end

            
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation Altitudine
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/global_position/rel_alt');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;

           
                for i=obj.AltitudineIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Data;
                    haveUpdate = true; 
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "altitude";                
                       
            if haveUpdate
                obj.AltitudineIndex = length(message);
            end

            
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation Pressure
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/static_pressure');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;

                for i=obj.PressureIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.FluidPressure;
                    haveUpdate = true;
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "pressure";                
                        

            
            if haveUpdate
                obj.PressureIndex = length(message);
            end

            
            obj.MainIndex = obj.MainIndex + 1;

            %% extrapolation Temperature
            bagTmp = select(obj.BagFile, 'Time', [obj.StartTime obj.CurrentTime], 'Topic', '/mavros/imu/temperature_baro');
            message = readMessages(bagTmp,'DataFormat','struct');
            t = bagTmp.MessageList.Time;
            haveUpdate = false;

                for i=obj.TemperatureIndex:length(message)
                    obj.Data{obj.MainIndex,1}(1,i) = message{i}.Temperature_;
                    haveUpdate = true; 
                end
                
                % obj.Dat{obj.MainIndex,2} - time vector (row vector)
                obj.Data{obj.MainIndex,2} = t'-obj.StartTime;
                % obj.Data{obj.MainIndex,3} - data_type
                obj.Data{obj.MainIndex,3} = "Temperature";                
                       

            
            if haveUpdate
                obj.TemperatureIndex = length(message);
            end
            
            obj.MainIndex = obj.MainIndex + 1;
 
                   
            %% End of extrapolation
            obj.MainIndex = 1;
            
        end

    end
end

