function K = assemble_global_matrix(nodes, members, E, areas)
%ASSEMBLE_GLOBAL_MATRIX Assemble the global stiffness matrix.
nNodes = size(nodes, 1);
K = zeros(2 * nNodes);
for m = 1:size(members, 1)
    i = members(m, 1);
    j = members(m, 2);
    ke = element_stiffness(nodes(i,1), nodes(i,2), nodes(j,1), nodes(j,2), E, areas(m));
    dofs = [2*i-1 2*i 2*j-1 2*j];
    K(dofs, dofs) = K(dofs, dofs) + ke;
end
end
