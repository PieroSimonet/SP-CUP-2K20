function index = GetNodeIndex(tree, nodeName)
	% !!!!! WARNING !!!!! Now it works only making requests to the same tree!!!!
	persistent map

	if isempty(map)
		map = containers.Map;
	end

	if ~isKey(map, nodeName)
		% tree_d = TreesManager.NodeTreeToNameTree(tree);
		map(nodeName) = find(strcmpi(tree, nodeName));
	end

	index = map(nodeName);

end
