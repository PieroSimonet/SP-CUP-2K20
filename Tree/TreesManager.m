classdef TreesManager
	
	properties
		AccelTree_desc
		PosTree_desc
		PowTree_desc
		
		AccelTree_data;
		PowTree_data;
		PosTree_data;

		accel_iterator;
		pos_iterator;
		pow_iterator;

		GeneralTree;
	end

	methods

		%% Constructor Input
		%
		%	[optional] debugLog [bool]
		%		Tells wether or not print trees to console after creation
		function obj = TreesManager(debugLog)
			if(nargin == 0)
				[ obj.AccelTree_desc, obj.PosTree_desc, obj.PowTree_desc obj.GeneralTree] = InitTrees()
			else
				[ obj.AccelTree_desc, obj.PosTree_desc, obj.PowTree_des obj.GeneralTreec] = InitTrees(debugLog)
			end

			obj.AccelTree_data = tree(obj.AccelTree_desc, 'clear');
			obj.PowTree_data = tree(obj.PosTree_desc, 'clear');
			obj.PosTree_data = tree(obj.PowTree_desc, 'clear');

			obj.accel_iterator = AccelTree_desc.breadthfirstiterator;
			obj.pos_iterator = PosTree_data.breadthfirstiterator;
			obj.pow_iterator = PowTree_data.breadthfirstiterator;

			
		end

		function node = SearchTree(iterator,search_handler)
			for i = iterator
				if(search_handler())
			end
		end
		
		% Reset all the data trees
		function ResetAll(obj)
			obj.AccelTree_desc = TreesManager.Reset(AccelTree_desc);
			obj.PosTree_desc = TreesManager.Reset(PosTree_desc);
			obj.PowTree_desc = TreesManager.Reset(PowTree_desc);
		end
		
	end

	methods (Static)

		function Reset(obj, tree)
			tree = tree(tree,'clear');
		end

	end
end