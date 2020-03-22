%% Input
%
%	[optional] debugLog [bool]
%		Tells wether or not print trees to console after creation

%% Output
%
%	accel_tree		[tree]
%		trees starting from accelerations
%	pos_tree		[tree]
%		tree starting from positions
%	pow_tree		[tree]
%		tree starting from power

function [accel_tree, pos_tree, pow_tree general_tree] = InitTrees(debugLog)
	accel_tree = tree('accel_tree');
	[accel_tree a_ang] = accel_tree.addnode(1, node('a_ang'));
	[accel_tree a_lin] = accel_tree.addnode(1, node('a_lin'));
	[accel_tree a_gps] = accel_tree.addnode(1, node('a_gps'));
	[accel_tree v_ang] = accel_tree.addnode(a_ang, node('v_ang'));
	[accel_tree v_lin] = accel_tree.addnode(a_lin, node('v_lin'));
	[accel_tree v_gps] = accel_tree.addnode(a_gps, node('v_gps'));

	pos_tree = tree('pos_tree');
	[pos_tree p_local] = pos_tree.addnode(1, node('p_local'));
	[pos_tree p_gps] = pos_tree.addnode(1, node('p_gps'));
	[pos_tree alt] = pos_tree.addnode(p_local, node('altitude'));
	[pos_tree press] = pos_tree.addnode(alt, node('pressure'));
	[pos_tree n_sat] = pos_tree.addnode(alt, node('n_sat'));

	pow_tree = tree('pow_tree');
	[pow_tree pow] = pow_tree.addnode(1, node('power'));
	[pow_tree curr] = pow_tree.addnode(pow, node('current'));
	[pow_tree curr] = pow_tree.addnode(pow, node('voltage'));
	[pow_tree batt] = pow_tree.addnode(pow, node('battery'));
	[pow_tree comp] = pow_tree.addnode(curr, node('compass'));
	[pow_tree mag_field] = pow_tree.addnode(comp, node('v_lin'));

	general_tree = tree('general_tree');
	[general_tree entry_pt] = general_tree.addnode(1, 'entry_pt');
	% insert Accel Tree
	general_tree = general_tree.graft(entry_pt,accel_tree);
	% a_t_index = GetNodeIndex(general_tree, 'accel_tree');
	%insert Pos Tree
	general_tree = general_tree.graft(entry_pt,pos_tree);
	% a_t_index = GetNodeIndex(general_tree, 'accel_tree');
	general_tree = general_tree.graft(entry_pt,pow_tree);
	

	if (nargin > 0 && debugLog)
		disp(accel_tree.tostring);
		disp(pos_tree.tostring);
		disp(pow_tree.tostring);
		disp(general_tree.tostring);
	end

end
