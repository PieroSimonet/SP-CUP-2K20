classdef AnomalyDetection
   
    properties
        peaks
        index_peaks
        forest
        index_forest
    end
    
    methods
        
        % Constructor
        function anomaly = AnomalyDetection()
            anomaly.peaks = {};
            anomaly.index_peaks = 0;
            anomaly.forest = {};
            anomaly.index_forest = 0;
        end
        
        % Insert
        function anomaly = insert_peaks(anomaly, index_anomaly, data_type)
            anomaly.index_peaks = anomaly.index_peaks + 1;
            anomaly.peaks{anomaly.index_peaks,1} = index_anomaly;
            anomaly.peaks{anomaly.index_peaks,2} = data_type;
        end
        
        function anomaly = insert_forest(anomaly, index_anomaly, data_type)
            anomaly.index_forest = anomaly.index_forest + 1;
            anomaly.forest{anomaly.index_forest,1} = index_anomaly;
            anomaly.forest{anomaly.index_forest,2} = data_type;
        end
        
        function anomaly = update(anomaly, peak_anomaly, first_index_peak, forest_anomaly, position_anomaly, data_type)
            
            if ~isempty(peak_anomaly)
                if sum(peak_anomaly)>0
                    anomaly = anomaly.insert_peaks(find(peak_anomaly)+first_index_peak, data_type);
                end
            end
            
            if forest_anomaly
                anomaly = anomaly.insert_forest(position_anomaly, data_type);
            end
        end
        
        function anomaly = reset(anomaly)
            anomaly.peaks = {};
            anomaly.index_peaks = 0;
            anomaly.forest = {};
            anomaly.index_forest = 0;
        end
        
    end
    
end