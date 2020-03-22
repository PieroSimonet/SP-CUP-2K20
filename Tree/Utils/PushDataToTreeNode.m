function tree = PushDataToTreeNode(tree,tree_d,nodeName,data)
	persistent map
	if isempty(map)
		map = containers.Map;
	end
	
	if ~isKey(map,nodeName)
		% tree_d = TreesManager.NodeTreeToNameTree(tree);
		map(nodeName) = GetNodeIndex(tree_d,nodeName);
    end
    
    node = tree.get(map(nodeName));
    node = node.PushData(data{1},data{2});
    
    tree = tree.set(map(nodeName),node); 
end
