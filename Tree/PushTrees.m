function [accel_tree, pos_tree, pow_tree] = PushTrees(currMsgImu, msgOdom, debugLog)

	persistent accel_tree_d;
	persistent pos_tree_d;
	persistent pow_tree_d;

	persistent m_accel_tree;
	persistent m_pos_tree;
	persistent m_pow_tree;

	if isempty(m_accel_tree)
		[ accel_tree_d pos_tree_d pow_tree_d ] = InitTrees();
		m_accel_tree = tree(accel_tree_d, 'clear');
		m_pos_tree = tree(pos_tree_d, 'clear');
		m_pow_tree = tree(pow_tree_d, 'clear');
	end

	m_accel_tree = PushGenericData(accel_tree_d, m_accel_tree, 'a_lin', currMsgImu.LinearAcceleration);
	% m_accel_tree = PushGenericData(accel_tree_d, m_accel_tree, 'a_lin', currMsgImu.LinearAcceleration);
	% m_accel_tree = PushGenericData(accel_tree_d, m_accel_tree, 'a_lin', currMsgImu.LinearAcceleration);




	accel_tree = m_accel_tree;
	pos_tree = m_pos_tree;
	pow_tree = m_pow_tree;
	

	if (nargin > 2 && debugLog)
		disp(' ');
		disp([accel_tree_d.tostring m_accel_tree.tostring]);
		disp(' ');
		disp([pos_tree_d.tostring m_pos_tree.tostring]);
		disp(' ');
		disp([pow_tree_d.tostring m_pow_tree.tostring]);
	end
end
