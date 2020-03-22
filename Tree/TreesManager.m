classdef TreesManager

	properties
		AccelTree
		PosTree
		PowTree

		GeneralTree
		GeneralTree_desc% tree only of its name

		accel_iterator
		pos_iterator
		pow_iterator
		gen_iterator

		use_map% bool
		name_map% map

	end

	methods

		% Constructor
		%
		%	Input
		%
		%	[optional] debugLog [bool]
		%		Tells wether or not print trees to console after creation
		function obj = TreesManager(debugLog)

			if (nargin == 0)
				[obj.AccelTree, obj.PosTree, obj.PowTree, obj.GeneralTree] = InitTrees();
			else
				[obj.AccelTree, obj.PosTree, obj.PowTree, obj.GeneralTree] = InitTrees(debugLog);
			end

			obj.GeneralTree_desc = obj.NodeTreeToNameTree(obj.GeneralTree);
			obj.accel_iterator = obj.AccelTree.breadthfirstiterator;
			obj.pos_iterator = obj.PosTree.breadthfirstiterator;
			obj.pow_iterator = obj.PowTree.breadthfirstiterator;
			obj.gen_iterator = obj.GeneralTree.breadthfirstiterator;

			obj = obj.UseMap(false);
		end

		function obj = UseMap(obj, whatToSet)

			if (nargin == 1)
				obj.use_map = true;
			else
				obj.use_map = whatToSet;
			end

		end

		% Set Name Map used to push data to trees
		function obj = SetNameMap(obj, map)
			obj.name_map = map;
			obj = obj.UseMap();
		end

		% Must populate trees from data parameter
		function obj = PushData(obj, data)

			persistent previndexes;

			props = data(:, 3);
            
			if (isempty(previndexes))
				previndexes = ones(length(props));
			end


			% loop through all props to set
			for i = 1:length(props)
				name = props{i};
				% use map?
				if obj.use_map

					if (~isKey(obj.name_map, name))
						% if we're using map, and it does not contain element, skip this for now
						continue;
					end

					name = obj.name_map(name);
				end

				j_len = data(i, 1);
				maxindex = length(j_len);

				for j = previndexes(i):maxindex
					l_data = data(j, [2 1]);
					obj.GeneralTree = PushDataToTreeNode(obj.GeneralTree, obj.GeneralTree_desc, name, l_data);
				end

				previndexes(i) = maxindex;
			end

		end


		function obj =  PushPeaksData(obj,peakdata)
			nodeName = peakdata{1,2};
			if obj.use_map
				nodeName = obj.name_map(nodeName);
			end

			originalTime = obj.GeneralTree.get(GetNodeIndex(obj.GeneralTree,nodeName)).time;
			obj.GeneralTree = PushPeakIndexToTreeNode(obj.GeneralTree, obj.GeneralTree_desc,nodeName,peakdata{1},originalTime);
		end

		function anomaly = SearchTree(obj, handler)
			anomaly = false;

			n = TreesManager.SearchTreeInternal(obj.GeneralTree, obj.gen_iterator, handler);

			if (~isempty(n))
				anomaly = true;
			end

		end

		% Reset all the data trees
		function obj = ResetAll(obj)
			obj.AccelTree = TreesManager.Reset(obj.AccelTree);
			obj.PosTree = TreesManager.Reset(obj.PosTree);
			obj.PowTree = TreesManager.Reset(obj.PowTree);
		end

		% Display trees content
		function disp(obj)
			disp(obj.AccelTree.tostring);
			disp(obj.PosTree.tostring);
			disp(obj.PowTree.tostring);
			disp(obj.GeneralTree.tostring);
		end

	end

	methods (Static)
        
        function node = SearchTreeInternal(tree, iterator, anomaly_find_handler)

			for i = iterator
				% get current node
				node = tree.get(i);
				%skip if empty
				if isempty(node) || ischar(node)
					continue;
				end

				if isempty(node.data)
					continue;
				end

				%apply search handler
				if (anomaly_find_handler(node))
					return;
				end

			end

        end
        
		% convert a mixed string/node tree to a string tree
		function na_tree = NodeTreeToNameTree(no_tree)
			na_tree = tree(no_tree);
			na_tree = na_tree.treefun(@TreesManager.ifNodeGetName);
		end

		%if obj is notde get its name, else keep the object
		function str = ifNodeGetName(obj)

			if isobject(obj)
				% Object with 'name' property -> get it
				if (isprop(obj, 'name'))
					str = obj.name;
					return;
				end

			end

			str = obj;
		end

		% end

		% methods (Static)

		function tree = Reset(tree)
			tree = tree(tree, 'clear');
		end

	end

end
