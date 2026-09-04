function [u, reactions, K] = solve_displacements(nodes, members, E, areas, F, constrainedDofs)
%SOLVE_DISPLACEMENTS Solve K*u=F after applying support constraints.
K = assemble_global_matrix(nodes, members, E, areas);
allDofs = 1:size(K, 1);
freeDofs = setdiff(allDofs, constrainedDofs);
if rcond(K(freeDofs, freeDofs)) < 1e-12
    error('The truss is unstable or the stiffness matrix is ill-conditioned.');
end
u = zeros(size(F));
u(freeDofs) = K(freeDofs, freeDofs) \ F(freeDofs);
reactions = K * u - F;
end
