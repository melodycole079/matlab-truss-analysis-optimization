"""Numerical smoke tests for the direct-stiffness truss model."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_results import analyze


def np_close(a, b, tol=1e-12):
    return abs(a - b) < tol


r = analyze()
assert np_close(r["reactions"][0] + r["reactions"][2], 0.0)
assert np_close(r["reactions"][1] + r["reactions"][3], 1000.0)
assert np_close(r["reactions"][1], 500.0)
assert np_close(r["reactions"][3], 500.0)
assert r["max_disp"] > 0
assert r["min_fos"] > 2
assert r["mass"] > 0
assert np_close(r["u"][0], 0.0)
assert np_close(r["u"][1], 0.0)
assert np_close(r["u"][3], 0.0)

# Linear elastic response: doubling the load doubles displacement and stress.
r2 = analyze(load=2000.0)
assert np_close(r2["max_disp"], 2 * r["max_disp"], 1e-12)
assert np_close(max(abs(r2["stresses"])), 2 * max(abs(r["stresses"])), 1e-6)

print("All truss-model checks passed.")
