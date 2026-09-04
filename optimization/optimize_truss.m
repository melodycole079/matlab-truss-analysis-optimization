function best = optimize_truss(nodes, members, E, F, constrainedDofs, yieldStrength, density, areaCandidates, minFOSRequired, maxDeflection)
%OPTIMIZE_TRUSS Search uniform member areas for minimum mass satisfying limits.
best = [];
for area = areaCandidates
    areas = area * ones(size(members,1), 1);
    result = analyze_truss(nodes, members, E, areas, F, constrainedDofs, yieldStrength, density);
    if result.minFOS >= minFOSRequired && result.maxDisplacement <= maxDeflection
        best = struct('area', area, 'analysis', result);
        return;
    end
end
end
