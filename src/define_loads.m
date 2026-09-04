function F = define_loads(nNodes, loadNode, loadVector)
%DEFINE_LOADS Build the global 2D nodal load vector.
F = zeros(2 * nNodes, 1);
F(2 * loadNode - 1) = loadVector(1);
F(2 * loadNode) = loadVector(2);
end
