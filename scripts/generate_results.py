"""Generate reference figures using the same direct-stiffness model as MATLAB."""
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

OUT = Path(__file__).resolve().parents[1] / "results"
OUT.mkdir(exist_ok=True)
plt.rcParams.update({"font.size": 10.5, "axes.titlesize": 12, "figure.dpi": 140})
NODES = np.array([[0.0, 0.0], [2.0, 0.0], [1.0, 1.5]])
MEMBERS = np.array([[0, 1], [0, 2], [1, 2]])


def analyze(area=100e-6, load=1000.0, E=200e9, yield_strength=250e6, density=7850.0):
    n = len(NODES); ndof = 2 * n
    K = np.zeros((ndof, ndof)); lengths = []; cs = []
    for i, j in MEMBERS:
        dx, dy = NODES[j] - NODES[i]; length = np.hypot(dx, dy)
        c, s = dx / length, dy / length
        ke = E * area / length * np.array([[c*c,c*s,-c*c,-c*s],[c*s,s*s,-c*s,-s*s],[-c*c,-c*s,c*c,c*s],[-c*s,-s*s,c*s,s*s]])
        dofs = [2*i, 2*i+1, 2*j, 2*j+1]
        K[np.ix_(dofs, dofs)] += ke
        lengths.append(length); cs.append((c, s))
    F = np.zeros(ndof); F[5] = -load
    fixed = np.array([0, 1, 3]); free = np.setdiff1d(np.arange(ndof), fixed)
    u = np.zeros(ndof); u[free] = np.linalg.solve(K[np.ix_(free, free)], F[free])
    reactions = K @ u - F
    forces = []
    for m, (i, j) in enumerate(MEMBERS):
        c, s = cs[m]; ue = u[[2*i, 2*i+1, 2*j, 2*j+1]]
        forces.append(E * area / lengths[m] * np.array([-c, -s, c, s]) @ ue)
    forces = np.array(forces); stresses = forces / area
    displacement = np.hypot(u[::2], u[1::2])
    mass = density * area * np.sum(lengths)
    return {"u": u, "reactions": reactions, "forces": forces, "stresses": stresses,
            "displacement": displacement, "max_disp": displacement.max(),
            "min_fos": yield_strength / np.max(np.abs(stresses)), "mass": mass,
            "lengths": np.array(lengths), "K": K}


def save_structure():
    r = analyze(); scale = 100
    deformed = NODES + scale * r["u"].reshape(-1, 2)
    fig, ax = plt.subplots(figsize=(7.5, 5.0))
    for m, (i, j) in enumerate(MEMBERS):
        ax.plot(NODES[[i, j], 0], NODES[[i, j], 1], "--", color="#999", lw=1.2)
        color = "#D1493F" if r["forces"][m] < 0 else "#0B5CAD"
        ax.plot(deformed[[i, j], 0], deformed[[i, j], 1], color=color, lw=3)
        mid = (NODES[i] + NODES[j]) / 2
        ax.text(*mid, f" M{m+1}", weight="bold")
    ax.scatter(NODES[:, 0], NODES[:, 1], facecolors="white", edgecolors="black", s=55, label="Original nodes")
    ax.scatter(deformed[:, 0], deformed[:, 1], color="#F2B544", edgecolors="black", s=55, label="Deformed nodes")
    ax.set(xlabel="x position (m)", ylabel="y position (m)", title="2D Truss Response (deformation ×100, not to scale)")
    ax.grid(alpha=.25); ax.axis("equal"); ax.legend(); fig.tight_layout()
    fig.savefig(OUT / "truss_response.png", bbox_inches="tight"); plt.close(fig)


def save_stress():
    r = analyze(); fig, ax = plt.subplots(figsize=(7.5, 5.0))
    max_stress = max(abs(r["stresses"]))
    for m, (i, j) in enumerate(MEMBERS):
        color = "#D1493F" if r["forces"][m] < 0 else "#0B5CAD"
        width = 2 + 7 * abs(r["stresses"][m]) / max_stress
        ax.plot(NODES[[i, j], 0], NODES[[i, j], 1], color=color, lw=width)
        mid = (NODES[i] + NODES[j]) / 2
        state = "C" if r["forces"][m] < 0 else "T"
        ax.text(*mid, f" M{m+1}: {state}", weight="bold")
    ax.scatter(NODES[:, 0], NODES[:, 1], c="white", edgecolors="black", s=60, zorder=3)
    ax.set(xlabel="x position (m)", ylabel="y position (m)", title="Member Force State: Blue = Tension, Red = Compression")
    ax.grid(alpha=.25); ax.axis("equal"); fig.tight_layout()
    fig.savefig(OUT / "stress_map.png", bbox_inches="tight"); plt.close(fig)


def save_load_sensitivity():
    loads = np.array([500, 1000, 1500, 2000, 2500])
    displacements = np.array([analyze(load=p)["max_disp"] for p in loads]) * 1e3
    stresses = np.array([analyze(load=p)["stresses"] for p in loads]).max(axis=1) / 1e6
    fig, ax1 = plt.subplots(figsize=(7.5, 4.5)); ax2 = ax1.twinx()
    ax1.plot(loads, displacements, "o-", color="#8B4BB3", label="Displacement")
    ax2.plot(loads, stresses, "s--", color="#D1493F", label="Stress")
    ax1.set(xlabel="Applied load (N)", ylabel="Maximum displacement (mm)")
    ax2.set_ylabel("Maximum signed stress (MPa)", color="#D1493F")
    ax1.set_title("Load Sensitivity"); ax1.grid(alpha=.25); fig.tight_layout()
    fig.savefig(OUT / "load_sensitivity.png", bbox_inches="tight"); plt.close(fig)


def save_area_tradeoff():
    areas_mm2 = np.array([50, 75, 100, 150, 200])
    cases = [analyze(area=a * 1e-6) for a in areas_mm2]
    stress = np.array([max(abs(c["stresses"])) for c in cases]) / 1e6
    disp = np.array([c["max_disp"] for c in cases]) * 1e3
    mass = np.array([c["mass"] for c in cases])
    fig, ax = plt.subplots(figsize=(7.5, 4.5)); ax2 = ax.twinx()
    ax.plot(areas_mm2, stress, "o-", label="Stress (MPa)", color="#D1493F")
    ax.plot(areas_mm2, disp, "s-", label="Displacement (mm)", color="#8B4BB3")
    ax2.plot(areas_mm2, mass, "^-", label="Mass (kg)", color="#2F8F46")
    ax.set(xlabel="Uniform member area (mm²)", ylabel="Stress / displacement")
    ax2.set_ylabel("Structural mass (kg)"); ax.set_title("Cross-Sectional Area Trade-off"); ax.grid(alpha=.25)
    lines, labels = ax.get_legend_handles_labels(); lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines + lines2, labels + labels2, loc="center right"); fig.tight_layout()
    fig.savefig(OUT / "area_tradeoff.png", bbox_inches="tight"); plt.close(fig)


def save_optimization():
    candidates = np.arange(10, 301) * 1e-6
    feasible = []
    for area in candidates:
        r = analyze(area=area)
        feasible.append(r["min_fos"] >= 2.0 and r["max_disp"] <= 5e-3)
    feasible = np.array(feasible)
    selected = np.where(feasible)[0][0]
    best_area = candidates[selected]
    masses = np.array([analyze(area=a)["mass"] for a in candidates])
    fig, ax = plt.subplots(figsize=(7.5, 4.5))
    ax.plot(candidates * 1e6, masses, color="#2F8F46", lw=2)
    ax.axvline(best_area * 1e6, color="#D1493F", ls="--", label=f"Minimum feasible = {best_area*1e6:.0f} mm²")
    ax.set(xlabel="Uniform member area (mm²)", ylabel="Structural mass (kg)", title="Minimum-Mass Feasible Area Search")
    ax.grid(alpha=.25); ax.legend(); fig.tight_layout()
    fig.savefig(OUT / "optimization.png", bbox_inches="tight"); plt.close(fig)
    return best_area


if __name__ == "__main__":
    save_structure(); save_stress(); save_load_sensitivity(); save_area_tradeoff(); best = save_optimization()
    print(f"Generated truss figures; minimum feasible area = {best*1e6:.0f} mm^2")
