# Truss Theory and Direct Stiffness Method

This project models a pin-jointed, two-dimensional truss. Each member carries axial force only. The reference structure has three nodes and three members: a bottom chord and two diagonal members.

## Degrees of freedom

Each node has two translational degrees of freedom:

\[
\{u\} = [u_{1x},u_{1y},u_{2x},u_{2y},\ldots]^T
\]

Node 1 is pinned, so both translations are constrained. Node 2 is a roller, so its vertical translation is constrained. The top node receives a downward point load.

## Element stiffness matrix

For a member with length `Lₑ`, area `A`, Young's modulus `E`, and direction cosines `c` and `s`, the global-coordinate element stiffness matrix is:

\[
[k_e] = \frac{EA}{L_e}
\begin{bmatrix}
 c^2 & cs & -c^2 & -cs \\
 cs & s^2 & -cs & -s^2 \\
 -c^2 & -cs & c^2 & cs \\
 -cs & -s^2 & cs & s^2
\end{bmatrix}
\]

## Global system

Element matrices are assembled into the global stiffness matrix. The linear static system is:

\[
[K]\{u\} = \{F\}
\]

After removing constrained degrees of freedom, the free displacement vector is solved using MATLAB's linear-system operator. Reactions are recovered from:

\[
\{R\} = [K]\{u\} - \{F\}
\]

## Member force and stress

The axial member deformation is obtained by projecting the nodal displacements onto the member axis. The axial force is:

\[
N_e = \frac{EA}{L_e}[-c\;-s\;c\;s]\{u_e\}
\]

Positive force indicates tension and negative force indicates compression. Axial stress is:

\[
\sigma_e = \frac{N_e}{A}
\]

The member factor of safety is computed from the absolute stress:

\[
FOS_e = \frac{\sigma_y}{|\sigma_e|}
\]

## Structural mass and optimization

The structural mass is estimated using:

\[
m = \rho\sum_e A_eL_e
\]

The lightweight design search tests a range of uniform member areas and selects the first area that satisfies both:

\[
FOS_{min} \geq 2.0
\]

\[
\delta_{max} \leq 5\text{ mm}
\]

This is a one-variable grid search, not a general-purpose nonlinear optimizer.

## Assumptions and limitations

The solver assumes pin-jointed members, small displacements, linear elasticity, uniform member area, no self-weight, and static loading. It does not model buckling, joint slip, bending in members, three-dimensional behavior, or material plasticity. Results are educational and are not a structural design certification.

## References

[1]: https://en.wikipedia.org/wiki/Direct_stiffness_method "Direct stiffness method overview"
[2]: https://en.wikipedia.org/wiki/Truss "Truss structural model overview"
