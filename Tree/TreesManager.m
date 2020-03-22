classdef TreesManager

	properties
		AccelTree_desc
		PosTree_desc
		PowTree_desc
		GeneralTree

		AccelTree_data
		PowTree_data
		PosTree_data

		accel_iterator
		pos_iterator
		pow_iterator
		gen_iterator

	end

	methods

		%% Constructor Input
		%
		%	[optional] debugLog [bool]
		%		Tells wether or not print trees to console after creation
		function obj = TreesManager(debugLog)

			if (nargin == 0)
				[obj.AccelTree_desc, obj.PosTree_desc, obj.PowTree_desc obj.GeneralTree] = InitTrees();
			else
				[obj.AccelTree_desc, obj.PosTree_desc, obj.PowTree_des obj.GeneralTreec] = InitTrees(debugLog);
			end

			obj.AccelTree_data = tree(obj.AccelTree_desc, 'clear');
			obj.PowTree_data = tree(obj.PosTree_desc, 'clear');
			obj.PosTree_data = tree(obj.PowTree_desc, 'clear');

			obj.accel_iterator = obj.AccelTree_desc.breadthfirstiterator;
			obj.pos_iterator = obj.PosTree_data.breadthfirstiterator;
			obj.pow_iterator = obj.PowTree_data.breadthfirstiterator;
			obj.gen_iterator = obj.GeneralTree.breadthfirstiterator;

		end

		function trees = PushTrees(data)

		end

		function node = SearchTree(tree, iterator, search_handler)

			for i = iterator
				% get current node
				node = tree.get(i);
				%skip if empty
				if (isempty(node))
					continue;
				end

				%apply search handler
				if (search_handler(node))
					return;
				end

			end

		end

		% Reset all the data trees
		function obj = ResetAll(obj)
			obj.AccelTree_desc = TreesManager.Reset(obj.AccelTree_desc);
			obj.PosTree_desc = TreesManager.Reset(obj.PosTree_desc);
			obj.PowTree_desc = TreesManager.Reset(obj.PowTree_desc);
		end

		function disp(obj, tree)
			disp(obj.AccelTree_desc.tostring);
			disp(obj.PosTree_desc.tostring);
			disp(obj.PowTree_desc.tostring);
			disp(obj.GeneralTree.tostring);
		end
		
		function dispData(obj, tree)
			disp(obj.AccelTree_data.tostring);
			disp(obj.PosTree_data.tostring);
			disp(obj.PowTree_data.tostring);
			% disp(obj.GeneralTree.tostring);
		end

	end

	methods (Static)

		function Reset(obj, tree)
			tree = tree(tree, 'clear');
		end

	end
end