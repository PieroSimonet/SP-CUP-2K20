% Container Class representing a node

classdef node
	properties
		name
		time
		data
		anomalyPeakIndex
	end

	methods
		% Constructor
		function obj = node(m_name,m_time,m_data)
			if nargin == 1
				m_time = [];
				m_data = [];
			end
			
			if(strcmpi(m_name,'clear'))
				m_name = '';
			end

			obj.name = m_name;
			obj.time = m_time;
			obj.data = m_data;
		end
		
		% Push new Data into the node
		function obj = PushData(obj, time, data)
			obj.time = [ obj.time time];
			obj.data = [ obj.data data];
		end

		% Push anomaly data into the node
		function obj = SetAnomalyPeakIndex(obj, index)
			obj.anomalyPeakIndex = index;
		end
	end
end