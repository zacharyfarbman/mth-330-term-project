"""Checkpoint 2: compare equal percentage increases in volatility (sigma) and
risk aversion (lambda) and their effect on the preferred sale duration T*.

Run from the repository root:
    python3 zach/checkpoint-2-analysis.py

Outputs:
    - symbolic results and a comparison table printed to the terminal
    - zach/checkpoint-2-sensitivity.svg (figure used in checkpoint-2.typ)
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import sympy as sp

# ---------------------------------------------------------------------------
# 1. Symbolic derivation (SymPy)
# ---------------------------------------------------------------------------
t, T, Q, eta, sigma, lam = sp.symbols("t T Q eta sigma lambda", positive=True)

v = Q / T
x = Q * (1 - t / T)

impact = sp.integrate(eta * v**2, (t, 0, T))
risk = sp.integrate(lam * sigma**2 * x**2, (t, 0, T))
J = sp.simplify(impact + risk)

dJ = sp.diff(J, T)
d2J = sp.simplify(sp.diff(J, T, 2))
T_star = sp.solve(sp.Eq(dJ, 0), T)
assert len(T_star) == 1, T_star
T_star = sp.simplify(T_star[0])

# Elasticities: percentage change in T* per percentage change in each input.
elas_sigma = sp.simplify(sigma / T_star * sp.diff(T_star, sigma))
elas_lam = sp.simplify(lam / T_star * sp.diff(T_star, lam))

# Exact multiplier on T* after raising one input by a fraction p.
p = sp.symbols("p", positive=True)
mult_sigma = sp.simplify(T_star.subs(sigma, (1 + p) * sigma) / T_star)
mult_lam = sp.simplify(T_star.subs(lam, (1 + p) * lam) / T_star)

print("J(T)             =", J)
print("J'(T)            =", sp.simplify(dJ))
print("J''(T)           =", d2J)
print("T*               =", T_star)
print("limit T->0+ of J =", sp.limit(J, T, 0, "+"))
print("limit T->oo of J =", sp.limit(J, T, sp.oo))
print("elasticity sigma =", elas_sigma)
print("elasticity lam   =", elas_lam)
print("T* multiplier, sigma up by p:", mult_sigma)
print("T* multiplier, lam up by p:  ", mult_lam)

# ---------------------------------------------------------------------------
# 2. Illustrative (not market-fitted) inputs
# ---------------------------------------------------------------------------
base = {Q: 100_000, eta: 3e-5, sigma: 0.05, lam: 1e-5}
T_MIN, T_MAX = 5.0, 240.0

J_num = sp.lambdify((T, Q, eta, sigma, lam), J, "numpy")
grid = np.linspace(T_MIN, T_MAX, 470_001)  # step 0.0005 minutes


def best_duration(q, e, s, l):
    """Grid search over the allowed window, endpoints included."""
    values = J_num(grid, q, e, s, l)
    return grid[np.argmin(values)]


def formula_duration(e, s, l):
    unclipped = np.sqrt(3 * e / (l * s**2))
    return min(max(unclipped, T_MIN), T_MAX)


q0, e0, s0, l0 = (float(base[k]) for k in (Q, eta, sigma, lam))
T0 = formula_duration(e0, s0, l0)
print(f"\nBaseline T* = {T0:.4f} min (grid: {best_duration(q0, e0, s0, l0):.4f})")
print(f"Baseline J(T*) = ${J_num(T0, q0, e0, s0, l0):,.2f}")

print("\n increase | T* (sigma up) | change | T* (lambda up) | change")
rows = []
for pct in (10, 25, 50, 100):
    f = 1 + pct / 100
    Ts = formula_duration(e0, s0 * f, l0)
    Tl = formula_duration(e0, s0, l0 * f)
    # numerical check against the grid search
    assert abs(Ts - best_duration(q0, e0, s0 * f, l0)) < 1e-3
    assert abs(Tl - best_duration(q0, e0, s0, l0 * f)) < 1e-3
    rows.append((pct, Ts, Tl))
    print(
        f"   {pct:>4d}%  |  {Ts:9.2f}    | {100 * (Ts / T0 - 1):6.2f}% |"
        f"   {Tl:9.2f}    | {100 * (Tl / T0 - 1):6.2f}%"
    )

# Equivalent lambda increase that matches a given sigma increase.
print("\nlambda increase needed to match a sigma increase of p: (1+p)^2 - 1")
for pct in (10, 25, 50, 100):
    f = 1 + pct / 100
    print(f"   sigma +{pct}%  <=>  lambda +{100 * (f**2 - 1):.1f}%")

# ---------------------------------------------------------------------------
# 3. Figure
# ---------------------------------------------------------------------------
pcts = np.linspace(0, 100, 401)
fac = 1 + pcts / 100
T_sig = np.sqrt(3 * e0 / (l0 * (s0 * fac) ** 2))
T_lam = np.sqrt(3 * e0 / (l0 * fac * s0**2))

fig, ax = plt.subplots(figsize=(6.4, 3.6))
ax.plot(pcts, T_sig, color="#1f5fa8", lw=2, label=r"raise volatility $\sigma$ only")
ax.plot(pcts, T_lam, color="#c2571a", lw=2, ls="--", label=r"raise risk aversion $\lambda$ only")
for pct, Ts, Tl in rows:
    ax.plot(pct, Ts, "o", color="#1f5fa8", ms=4)
    ax.plot(pct, Tl, "s", color="#c2571a", ms=4)
ax.axhline(T0, color="0.6", lw=0.8, ls=":")
ax.text(1, T0 + 0.8, f"baseline T* = {T0:.0f} min", fontsize=8, color="0.35")
ax.set_xlabel("Percentage increase in the chosen input (%)")
ax.set_ylabel("Preferred duration T* (minutes)")
ax.set_xlim(0, 100)
ax.set_ylim(25, 65)
ax.grid(alpha=0.25)
ax.legend(frameon=False, fontsize=9)
ax.set_title("Equal percentage increases: effect on the preferred duration", fontsize=10)
fig.tight_layout()

out = Path(__file__).with_name("checkpoint-2-sensitivity.svg")
fig.savefig(out)
print(f"\nSaved figure to {out}")
