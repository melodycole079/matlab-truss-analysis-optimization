%% Simple triangular reference truss
% Run src/main.m for the complete interactive analysis.
nodes = [0.0 0.0; 2.0 0.0; 1.0 1.5];
members = [1 2; 1 3; 2 3];
% Node 1: pinned support. Node 2: vertical roller support.
% Apply the reference downward load at node 3.
