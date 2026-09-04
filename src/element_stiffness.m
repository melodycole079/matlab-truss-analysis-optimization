function ke = element_stiffness(x1, y1, x2, y2, E, A)
%ELEMENT_STIFFNESS Global-coordinate stiffness matrix for a 2D truss element.
dx = x2 - x1;
dy = y2 - y1;
L = hypot(dx, dy);
c = dx / L;
s = dy / L;
ke = (E * A / L) * [c^2 c*s -c^2 -c*s; ...
                     c*s s^2 -c*s -s^2; ...
                    -c^2 -c*s c^2 c*s; ...
                    -c*s -s^2 c*s s^2];
end
