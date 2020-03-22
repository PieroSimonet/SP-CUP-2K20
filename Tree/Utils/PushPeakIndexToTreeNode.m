function tree = PushPeakIndexToTreeNode(tree, tree_d, nodeName, peakIndex, originalTimeVector)

	% tree_d = TreesManager.NodeTreeToNameTree(tree);
	index = GetNodeIndex(tree_d, nodeName);

	node = tree.get(index);
    if(isempty(originalTimeVector) || isempty(node.time))
        return;
    end
	node = node.SetAnomalyPeakIndex(time_sinc(originalTimeVector, node.time, peakIndex));

	tree = tree.set(index, node);
end
