function constrainedDofs = define_supports()
%DEFINE_SUPPORTS Node 1 is pinned; node 2 is a vertical roller support.
% DOF ordering is [node1_x node1_y node2_x node2_y ...].
constrainedDofs = [1 2 4];
end
