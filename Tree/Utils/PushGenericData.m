
function tree = PushGenericData(desc_tree, tree, fieldName, data)
	
	index = GetNodeIndex(desc_tree,fieldName);

	if isempty(tree.get(index));
		newField = data;
	else
		newField = [ tree.get(index) data ];
	end

	tree = tree.set(index, newField);

end