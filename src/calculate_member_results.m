function results = calculate_member_results(nodes, members, E, areas, u, yieldStrength, density)
%CALCULATE_MEMBER_RESULTS Compute axial response and structural mass.
nMembers = size(members, 1);
results = struct('length', zeros(nMembers,1), 'force', zeros(nMembers,1), ...
    'stress', zeros(nMembers,1), 'fos', zeros(nMembers,1), ...
    'mass', zeros(nMembers,1));
for m = 1:nMembers
    i = members(m,1); j = members(m,2);
    dx = nodes(j,1) - nodes(i,1); dy = nodes(j,2) - nodes(i,2);
    L = hypot(dx, dy); c = dx/L; s = dy/L;
    dofs = [2*i-1 2*i 2*j-1 2*j];
    ue = u(dofs);
    axialDeformation = [-c -s c s] * ue;
    force = E * areas(m) / L * axialDeformation;
    results.length(m) = L;
    results.force(m) = force;
    results.stress(m) = force / areas(m);
    results.fos(m) = yieldStrength / max(abs(force / areas(m)), eps);
    results.mass(m) = density * areas(m) * L;
end
results.totalMass = sum(results.mass);
end
