function tree = PushGenericData(desc_tree, tree, fieldName, data)
	
	persistent map
    if isempty(map)
		map = containers.Map;
	end
	
	if isempty(map(fieldName))
		map(fieldName) = GetNodeIndex(desc_tree,fieldName);
	end

	index = map(fieldName);

	if isempty(tree.get(index));
		newField = data;
	else
		newField = [ tree.get(index) data ];
	end

	tree = tree.set(index, newField);

end