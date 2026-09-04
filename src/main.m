%% MATLAB Truss Analysis & Optimization Tool
% Educational linear-elastic 2D truss solver using the direct stiffness method.

clc;
clear;
close all;
sourceFolder = fileparts(mfilename('fullpath'));
addpath(sourceFolder);
addpath(fullfile(sourceFolder, '..', 'optimization'));

fprintf('MATLAB Truss Analysis & Optimization Tool\n');
fprintf('Independent project exploring computational structural analysis.\n\n');

nodes = define_nodes();
members = define_members();
nNodes = size(nodes, 1);
nMembers = size(members, 1);

E = readPositive('Young''s modulus E (Pa) [200e9]: ', 200e9);
yieldStrength = readPositive('Yield strength (Pa) [250e6]: ', 250e6);
density = readPositive('Material density (kg/m^3) [7850]: ', 7850);
area = readPositive('Member cross-sectional area (m^2) [100e-6]: ', 100e-6);
loadMagnitude = readPositive('Downward load magnitude (N) [1000]: ', 1000);
loadNode = readInteger('Load node (1-3) [3]: ', 3, 1, nNodes);

F = define_loads(nNodes, loadNode, [0, -loadMagnitude]);
constrainedDofs = define_supports();
result = analyze_truss(nodes, members, E, area * ones(nMembers,1), F, ...
    constrainedDofs, yieldStrength, density);

fprintf('\n--- Truss Analysis Results ---\n');
fprintf('Maximum displacement:      %.4f mm\n', result.maxDisplacement * 1e3);
fprintf('Maximum tensile force:     %.3f kN\n', result.maxTension / 1e3);
fprintf('Maximum compressive force: %.3f kN\n', result.maxCompression / 1e3);
fprintf('Maximum stress:             %.3f MPa\n', result.maxStress / 1e6);
fprintf('Minimum factor of safety:   %.3f\n', result.minFOS);
fprintf('Critical member:            Member %d\n', result.criticalMember);
fprintf('Structural mass:            %.3f kg\n', result.totalMass);

fprintf('\nMember results:\n');
for m = 1:nMembers
    state = 'Tension';
    if result.member.force(m) < 0, state = 'Compression'; end
    fprintf('Member %d: %+.3f kN | %+.3f MPa | FOS %.3f | %s\n', ...
        m, result.member.force(m)/1e3, result.member.stress(m)/1e6, ...
        result.member.fos(m), state);
end

% Plot original and exaggerated deformed geometry.
deformationScale = 100;
deformedNodes = nodes + deformationScale * [result.u(1:2:end), result.u(2:2:end)];
figure('Color', 'w', 'Name', 'Truss Response');
hold on; box on; grid on; axis equal;
for m = 1:nMembers
    i = members(m,1); j = members(m,2);
    plot(nodes([i j],1), nodes([i j],2), '--', 'Color', [0.65 0.65 0.65], 'LineWidth', 1.2);
    color = [0.12 0.45 0.75];
    if result.member.force(m) < 0, color = [0.82 0.25 0.16]; end
    plot(deformedNodes([i j],1), deformedNodes([i j],2), '-', 'Color', color, 'LineWidth', 3);
    mid = (nodes(i,:) + nodes(j,:)) / 2;
    text(mid(1), mid(2), sprintf('  M%d', m), 'FontWeight', 'bold');
end
plot(nodes(:,1), nodes(:,2), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 7);
plot(deformedNodes(:,1), deformedNodes(:,2), 'ko', 'MarkerFaceColor', [0.95 0.70 0.15], 'MarkerSize', 7);
plot(nodes(1,1), nodes(1,2), '^', 'MarkerFaceColor', [0.20 0.20 0.20], 'MarkerSize', 9);
plot(nodes(2,1), nodes(2,2), '>', 'MarkerFaceColor', [0.20 0.20 0.20], 'MarkerSize', 9);
legend('Original geometry', 'Deformed geometry (exaggerated)', 'Nodes', 'Deformed nodes', ...
    'Location', 'best');
xlabel('x position (m)'); ylabel('y position (m)');
title('2D Truss: Tension (blue) and Compression (red)');

% Uniform-area optimization subject to FOS and displacement constraints.
areaCandidates = linspace(10e-6, 300e-6, 291);
best = optimize_truss(nodes, members, E, F, constrainedDofs, yieldStrength, density, ...
    areaCandidates, 2.0, 5e-3);
if isempty(best)
    fprintf('\nNo candidate area satisfied the optimization constraints.\n');
else
    fprintf('\n--- Lightweight Design Search ---\n');
    fprintf('Minimum uniform area:      %.2f mm^2\n', best.area * 1e6);
    fprintf('Optimized structural mass:  %.3f kg\n', best.analysis.totalMass);
    fprintf('Optimized maximum FOS:      %.3f\n', best.analysis.minFOS);
    fprintf('Optimized displacement:     %.4f mm\n', best.analysis.maxDisplacement * 1e3);
end

function value = readPositive(prompt, defaultValue)
    if nargin < 2, defaultValue = []; end
    while true
        value = input(prompt);
        if isempty(value) && ~isempty(defaultValue), value = defaultValue; return; end
        if isnumeric(value) && isscalar(value) && isfinite(value) && value > 0, return; end
        fprintf('Enter one finite number greater than zero.\n');
    end
end

function value = readInteger(prompt, defaultValue, lowerBound, upperBound)
    while true
        value = input(prompt);
        if isempty(value), value = defaultValue; return; end
        if isnumeric(value) && isscalar(value) && isfinite(value) && ...
                value == floor(value) && value >= lowerBound && value <= upperBound, return; end
        fprintf('Enter an integer between %d and %d.\n', lowerBound, upperBound);
    end
end
