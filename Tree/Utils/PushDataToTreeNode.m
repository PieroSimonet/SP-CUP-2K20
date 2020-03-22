function tree = PushDataToTreeNode(tree, tree_d, nodeName, data)
	
	% tree_d = TreesManager.NodeTreeToNameTree(tree);
    indx = GetNodeIndex(tree_d, nodeName);
	

	node = tree.get(indx);

	tree = tree.set(indx, node.PushData(data{1}, data{2}));
end
