"""Figures for the uncertainty cone: Gram matrix → four-vector → Minkowski cone.

Every number is computed from the matrices T_d, P_d of the base repository:
T_d = adjacency / ρ_d with ρ_d = 2 cos(π/(d+1)), P_d = diag(−1 + 2j/(d−1)), and the
maximal-tension state ψ*_j ∝ (−i)^j sin((j+1)π/(d+1)) (speed 1). The four-vector of a pair is
v = ((‖x‖² + ‖y‖²)/2, Re⟪x,y⟫, Im⟪x,y⟫, (‖x‖² − ‖y‖²)/2) (`Cone.coneVector`).
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

from style import OUT, BLUE, ORANGE, GREEN, RED, VIOLET, MUTED, INK2, INK

C_INF = np.sqrt(np.pi**2 / 3 - 2)
VSTAR = {4: 0.927051, 5: 0.983875, 6: 0.971246}   # D44, docs/nrs3-speed-data.js of the base
RNG = np.random.default_rng(1929)


def ops(d):
    rho = 2 * np.cos(np.pi / (d + 1))
    T = (np.eye(d, k=1) + np.eye(d, k=-1)) / rho
    P = np.diag(-1 + 2 * np.arange(d) / (d - 1))
    return T.astype(complex), P.astype(complex)


def psi_star(d):
    v = np.array([(-1j) ** j * np.sin((j + 1) * np.pi / (d + 1)) for j in range(d)])
    return v / np.linalg.norm(v)


def fluct(A, psi):
    return A @ psi - (psi.conj() @ A @ psi).real * psi


def cone_vector(x, y):
    ip = x.conj() @ y
    a, b = np.vdot(x, x).real, np.vdot(y, y).real
    return np.array([(a + b) / 2, ip.real, ip.imag, (a - b) / 2])


def balanced(v):
    """Boost along v₃ to the frame v₃ = 0 and scale to v₀ = 1: (β₁, β₂)."""
    v0 = np.sqrt(v[0] ** 2 - v[3] ** 2)
    return v[1] / v0, v[2] / v0


def speed(T, P, psi, d):
    K = 1j * (T @ P - P @ T)
    return (d - 1) / 2 * (psi.conj() @ K @ psi).real


def C_nava(d):
    T, P = ops(d)
    s = psi_star(d)
    x, y = fluct(T, s), fluct(P, s)
    return np.linalg.norm(x) * np.linalg.norm(y) / abs(np.vdot(x, y))


def random_state(d, real=False):
    v = RNG.normal(size=d) + (0 if real else 1j * RNG.normal(size=d))
    return v / np.linalg.norm(v)


def cone_surface(ax, h=1.08, alpha=0.10):
    r = np.linspace(0, h, 30)
    t = np.linspace(0, 2 * np.pi, 90)
    R, TT = np.meshgrid(r, t)
    ax.plot_surface(R * np.cos(TT), R * np.sin(TT), R, color=BLUE, alpha=alpha, linewidth=0)
    ax.plot(h * np.cos(t), h * np.sin(t), h, color=BLUE, lw=0.8, alpha=0.6)


def style3d(ax):
    for a in (ax.xaxis, ax.yaxis, ax.zaxis):
        a.pane.set_facecolor((1, 1, 1, 0))
        a.pane.set_edgecolor("#e4e3df")
    ax.tick_params(colors=MUTED, labelsize=8)


def figure_cone_3d():
    fig = plt.figure(figsize=(7.6, 6.8), dpi=150)
    ax = fig.add_subplot(projection="3d")
    cone_surface(ax)
    d = 4
    T, P = ops(d)
    # every state of H_4 lies inside the cone; those in the band Ϙ(4) sit near ψ*
    for k in range(1600):
        if k % 2:
            s = random_state(d)
        else:
            s = psi_star(d) + 0.3 * RNG.random() * random_state(d)
            s /= np.linalg.norm(s)
        b1, b2 = balanced(cone_vector(fluct(T, s), fluct(P, s)))
        inband = abs(speed(T, P, s, d)) > VSTAR[4]
        ax.scatter(b1, b2, 1, s=4, color=ORANGE if inband else MUTED,
                   alpha=0.8 if inband else 0.3, depthshade=False)
    for dd, c, lab, off in [(2, RED, "d = 2, 3: on the rim (null)", 0.10),
                            (4, GREEN, "d = 4: β = 0.9916", -0.02),
                            (30, GREEN, "d = 30", -0.02)]:
        T2, P2 = ops(dd)
        s = psi_star(dd)
        b1, b2 = balanced(cone_vector(fluct(T2, s), fluct(P2, s)))
        ax.plot([0, b1], [0, b2], [0, 1], color=c, lw=1.8)
        ax.scatter(b1, b2, 1, color=c, s=30, depthshade=False)
    ax.plot([0, 0], [0, -1 / C_INF], [0, 1], color=VIOLET, lw=1.4, ls="--")
    ax.scatter(0, -1 / C_INF, 1, color=VIOLET, s=22, depthshade=False)
    ax.set_xlabel(r"$v_1/v_0'$  covariance")
    ax.set_ylabel(r"$v_2/v_0'$  commutator")
    ax.set_zlabel(r"$v_0'$")
    ax.set_xlim(-1.1, 1.1); ax.set_ylim(-1.1, 1.1); ax.set_zlim(0, 1.1)
    ax.view_init(elev=30, azim=-25)
    style3d(ax)
    ax.set_title("The uncertainty cone of $T_4 : P_4$ in the balanced frame $v_3 = 0$")
    leg = [Line2D([], [], color=RED, marker="o", lw=1.8, label="ψ* at d = 2, 3: on the rim, null"),
           Line2D([], [], color=GREEN, marker="o", lw=1.8,
                  label="ψ* at d = 4 (β = 0.9916) and d = 30: inside, timelike"),
           Line2D([], [], color=VIOLET, marker="o", lw=1.4, ls="--",
                  label=f"d → ∞: β = 1/C∞ = {1 / C_INF:.4f}, never reached"),
           Line2D([], [], color=ORANGE, marker="o", lw=0, label="states of $H_4$ in the band Ϙ(4)"),
           Line2D([], [], color=MUTED, marker="o", lw=0, label="other states of $H_4$: all inside")]
    ax.legend(handles=leg, loc="upper left", fontsize=8)
    fig.tight_layout()
    fig.savefig(OUT / "cone_3d.png")
    plt.close(fig)


def figure_speed():
    d = np.arange(2, 81)
    beta = np.array([1 / C_nava(k) for k in d])
    fig, ax = plt.subplots(figsize=(7.4, 4.2), dpi=150)
    ax.axhline(1, color=RED, lw=1, ls=":")
    ax.text(80, 1.004, "speed of light of the cone: β = 1", color=RED, ha="right", fontsize=9)
    ax.axhline(1 / C_INF, color=VIOLET, lw=1, ls="--")
    ax.text(80, 1 / C_INF - 0.012, f"limit 1/C∞ = {1 / C_INF:.4f}", color=VIOLET, ha="right",
            fontsize=9)
    ax.plot(d, beta, color=BLUE, lw=2, label=r"$\beta(d) = 1/C_{Nava}(d)$")
    ax.plot(d, beta**2, color=ORANGE, lw=1.4, ls="-.",
            label=r"$\beta^2$ = Mandelstam–Tamm ratio $\langle K\rangle^2/(4\,\mathrm{Var}\,T\,\mathrm{Var}\,P)$")
    ax.scatter([2, 3], [1, 1], color=RED, zorder=4, s=30)
    ax.scatter([4], [1 / C_nava(4)], color=GREEN, zorder=4, s=30)
    ax.annotate(f"d = 4: β = {1 / C_nava(4):.5f}", (4, 1 / C_nava(4)), xytext=(18, -22),
                textcoords="offset points", color=GREEN, fontsize=9,
                arrowprops=dict(arrowstyle="-", color=GREEN, lw=0.8))
    ax.set_xlabel("positions per axis $d$")
    ax.set_ylabel("speed of the uncertainty vector")
    ax.set_title("Null only at d = 2, 3; timelike from d = 4, never reaching the limit")
    ax.set_ylim(0.74, 1.03)
    ax.legend(fontsize=8.5, loc="lower left")
    fig.tight_layout()
    fig.savefig(OUT / "speed_by_dimension.png")
    plt.close(fig)


def figure_boost():
    d = 4
    T, P = ops(d)
    s = psi_star(d)
    x, y = fluct(T, s), fluct(P, s)
    v = cone_vector(x, y)
    m = np.sqrt(v[0] ** 2 - v[3] ** 2)
    fig, ax = plt.subplots(figsize=(7.6, 4.6), dpi=150)
    e = np.linspace(-1.6, 1.6, 300)
    ax.plot(m * np.sinh(e), m * np.cosh(e), color=BLUE, lw=2,
            label=r"$v_0^2 - v_3^2 = (\|x\|\,\|y\|)^2$: the orbit of the boosts")
    lim = m * np.cosh(1.6)
    ax.plot([-lim, lim], [lim, lim], alpha=0)
    ax.plot([0, -lim], [0, lim], color=RED, lw=1, ls=":")
    ax.plot([0, lim], [0, lim], color=RED, lw=1, ls=":", label="light lines $v_0 = \\pm v_3$")
    for lam, c in [(0.5, ORANGE), (1.0, GREEN), (2.0, VIOLET)]:
        xs, ys = lam * x, y / lam
        w = cone_vector(xs, ys)
        ax.scatter(w[3], w[0], color=c, s=40, zorder=4)
        ax.annotate(f"λ = {lam:g}" + ("  (the units of ψ*)" if lam == 1 else ""), (w[3], w[0]),
                    xytext=(10, -16 if lam == 1 else -4), textcoords="offset points", color=c,
                    fontsize=9)
    lb = np.sqrt(np.linalg.norm(y) / np.linalg.norm(x))
    w = cone_vector(lb * x, y / lb)
    ax.scatter(w[3], w[0], marker="*", color=INK, s=120, zorder=5)
    ax.annotate("balanced frame $v_3 = 0$,  $v_0 = \\|x\\|\\|y\\|$", (w[3], w[0]),
                xytext=(10, 14), textcoords="offset points", color=INK, fontsize=9)
    ax.set_xlabel(r"$v_3 = (\mathrm{Var}\,A - \mathrm{Var}\,B)/2$")
    ax.set_ylabel(r"$v_0 = (\mathrm{Var}\,A + \mathrm{Var}\,B)/2$")
    ax.set_title("Changing units, A → λA and B → B/λ, is a Lorentz boost")
    ax.set_aspect("equal")
    ax.set_xlim(-lim, lim)
    ax.set_ylim(0, lim * 1.02)
    ax.legend(fontsize=8.5, loc="lower center", bbox_to_anchor=(0.5, 0.0))
    fig.tight_layout()
    fig.savefig(OUT / "units_are_a_boost.png")
    plt.close(fig)


def figure_real_vs_complex():
    d = 6
    T, P = ops(d)
    fig, axs = plt.subplots(1, 2, figsize=(9.6, 4.6), dpi=150, sharey=True)
    t = np.linspace(0, 2 * np.pi, 300)
    for ax, real, title in [(axs[0], False, "$\\mathbb{C}^6$: the disc fills, the commutator axis is alive"),
                            (axs[1], True, "$\\mathbb{R}^6$: $v_2 = 0$, the commutator axis is lost")]:
        ax.plot(np.cos(t), np.sin(t), color=RED, lw=1, ls=":")
        pts = np.array([balanced(cone_vector(fluct(T, s), fluct(P, s)))
                        for s in (random_state(d, real) for _ in range(2500))])
        ax.scatter(pts[:, 0], pts[:, 1], s=3, color=MUTED if real else BLUE, alpha=0.5)
        if not real:
            s = psi_star(d)
            b = balanced(cone_vector(fluct(T, s), fluct(P, s)))
            ax.scatter(*b, color=GREEN, s=40, zorder=4)
            ax.annotate("ψ*", b, xytext=(8, 4), textcoords="offset points", color=GREEN)
        ax.set_title(title, fontsize=10.5)
        ax.set_aspect("equal")
        ax.set_xlabel(r"$v_1/v_0'$  covariance")
        ax.set_xlim(-1.08, 1.08); ax.set_ylim(-1.08, 1.08)
    axs[0].set_ylabel(r"$v_2/v_0'$  commutator")
    fig.suptitle("A slice of the cone at $v_0' = 1$: the rim is the speed of light", fontsize=12)
    fig.tight_layout()
    fig.savefig(OUT / "complex_vs_real.png")
    plt.close(fig)


def kron3(A, i, ds):
    mats = [np.eye(k) for k in ds]
    mats[i] = A
    return np.kron(np.kron(mats[0], mats[1]), mats[2])


def figure_band_cube():
    ds = (4, 4, 4)
    TT = [kron3(ops(k)[0], i, ds) for i, k in enumerate(ds)]
    PP = [kron3(ops(k)[1], i, ds) for i, k in enumerate(ds)]
    S = np.kron(np.kron(psi_star(4), psi_star(4)), psi_star(4))
    pts, n = [], 0
    while len(pts) < 700 and n < 40000:
        n += 1
        s = S + 0.12 * RNG.random() * random_state(64)
        s /= np.linalg.norm(s)
        sp = [abs(speed(TT[i], PP[i], s, ds[i])) for i in range(3)]
        if all(v > VSTAR[4] for v in sp):
            q = []
            for i in range(3):
                v = cone_vector(fluct(TT[i], s), fluct(PP[i], s))
                q.append(1 - (v[1] ** 2 + v[2] ** 2) / (v[0] ** 2 - v[3] ** 2))
            pts.append(q)
    pts = np.array(pts)
    fig = plt.figure(figsize=(7.2, 6.4), dpi=150)
    ax = fig.add_subplot(projection="3d")
    sc = ax.scatter(pts[:, 0], pts[:, 1], pts[:, 2], c=pts.min(axis=1), cmap="viridis", s=7)
    c4 = 1 - 1 / C_nava(4) ** 2
    ax.scatter([c4], [c4], [c4], color=RED, s=60, marker="*")
    ax.text(c4, c4, c4 * 1.08, "Ψ*", color=RED)
    ax.scatter([0], [0], [0], color=INK, s=30, marker="x")
    ax.text(0, 0, 0.004, "  saturation: never reached in the band", color=INK2, fontsize=8)
    ax.set_xlabel("$1-\\beta_x^2$"); ax.set_ylabel("$1-\\beta_y^2$"); ax.set_zlabel("$1-\\beta_z^2$")
    lo = 0
    ax.set_xlim(lo, None); ax.set_ylim(lo, None); ax.set_zlim(lo, None)
    style3d(ax)
    ax.view_init(elev=22, azim=40)
    cb = fig.colorbar(sc, ax=ax, shrink=0.6, pad=0.1)
    cb.set_label("smallest axis", color=INK2)
    ax.set_title(f"{len(pts)} states of the 4×4×4 cube in the band Ϙ(4) on x, y, z:\n"
                 "every axis strictly timelike, entangled states included", fontsize=10.5)
    fig.tight_layout()
    fig.savefig(OUT / "band_cube_3d.png")
    plt.close(fig)
    print("band cube: states", len(pts), "min", pts.min())


if __name__ == "__main__":
    OUT.mkdir(exist_ok=True)
    for k in (2, 3, 4, 10):
        print(k, C_nava(k), 1 / C_nava(k))
    figure_cone_3d()
    figure_speed()
    figure_boost()
    figure_real_vs_complex()
    figure_band_cube()
