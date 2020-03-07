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

function [accel_tree, pos_tree, pow_tree] = InitTrees(debugLog)
	accel_tree = tree('accel_tree');
	[accel_tree a_ang] = accel_tree.addnode(1, 'a_ang');
	[accel_tree a_lin] = accel_tree.addnode(1, 'a_lin');
	[accel_tree a_gps] = accel_tree.addnode(1, 'a_gps');
	[accel_tree v_ang] = accel_tree.addnode(a_ang, 'a_ang');
	[accel_tree v_lin] = accel_tree.addnode(a_lin, 'v_lin');
	[accel_tree v_gps] = accel_tree.addnode(a_gps, 'v_gps');

	pos_tree = tree('pos_tree');
	[pos_tree p_local] = pos_tree.addnode(1, 'p_local');
	[pos_tree p_gps] = pos_tree.addnode(1, 'p_gps');
	[pos_tree alt] = pos_tree.addnode(p_local, 'altitude');
	[pos_tree press] = pos_tree.addnode(alt, 'pressure');
	[pos_tree n_sat] = pos_tree.addnode(alt, 'n_sat');

	pow_tree = tree('pow_tree');
	[pow_tree pow] = pow_tree.addnode(1, 'power');
	[pow_tree curr] = pow_tree.addnode(pow, 'current');
	[pow_tree batt] = pow_tree.addnode(pow, 'battery');
	[pow_tree comp] = pow_tree.addnode(curr, 'compass');
	[pow_tree mag_field] = pow_tree.addnode(comp, 'v_lin');

	if (nargin > 0 && debugLog)
		disp(accel_tree.tostring);
		disp(pow_tree.tostring);
		disp(pow_tree.tostring);
	end

end
