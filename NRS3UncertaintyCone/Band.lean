/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import NRS3UncertaintyCone.Cone
public import NavaRobertsonCertificados.D49e_AxisDefectEntangled
public import NavaRobertsonCertificados.D49t_RobertsonDeterminantBandStrict

/-!
# The band: strictly inside the cone, for every state, in every direction

On the cube `dx × dy × dz` every axis carries its pair `(T, P)` and its uncertainty four-vector
(`Cone`). The band `Ϙ(d) = (v*(d), 1]` of `D44` is the range of speeds with forced defect. If
the speeds of a state on `x`, `y`, `z` lie in `Ϙ(dx)`, `Ϙ(dy)`, `Ϙ(dz)`:

* the four-vector of every axis is strictly timelike, whether or not the state is entangled
  across the axes (`D49e`);
* det|NRS³, Robertson 1934 for the six observables, is strict (`D49t`).

So inside the band the cone is strict on every axis and for the six observables together. Outside
the band the defect may vanish, but only trivially: Robertson reads `0 = 0` on position
eigenstates (`D47`) and on the mirror state, where nothing moves (`D49m`).

## Main results

- `UncertaintyCone.timelike_of_band` : in the band, the four-vectors of `x`, `y`, `z` are strictly
  timelike, for every unit state.
- `UncertaintyCone.robertson_det_strict_of_band` : in the band, `|det Ω| < det Σ` for the six
  observables of the cube.
-/

@[expose] public noncomputable section

open TransportPosition NearMaxTension GroupVelocity VelocityBand PathGraph3DNRS CauchyGram
open RobertsonDeterminant RobertsonDeterminant3D

namespace UncertaintyCone

variable {dx dy dz : ℕ}

/-- **Strictly timelike on every axis, for every state in the band.** -/
theorem timelike_of_band (hx : 2 ≤ dx) (hy : 2 ≤ dy) (hz : 2 ≤ dz) {Φ : H3D dx dy dz}
    (hΦ : ‖Φ‖ = 1) (hbx : |velocityX Φ| ∈ Ϙ dx) (hby : |velocityY Φ| ∈ Ϙ dy)
    (hbz : |velocityZ Φ| ∈ Ϙ dz) :
    0 < interval (coneVector (centeredG (TX dx dy dz) Φ) (centeredG (PX dx dy dz) Φ)) ∧
      0 < interval (coneVector (centeredG (TY dx dy dz) Φ) (centeredG (PY dx dy dz) Φ)) ∧
        0 < interval (coneVector (centeredG (TZ dx dy dz) Φ) (centeredG (PZ dx dy dz) Φ)) := by
  simp only [interval_eq_gramDefectC]
  exact ⟨AxisDefectEntangled.gramDefect_pos_of_band hx (eX dx dy dz) hΦ hbx,
    AxisDefectEntangled.gramDefect_pos_of_band hy (eY dx dy dz) hΦ hby,
    AxisDefectEntangled.gramDefect_pos_of_band hz (eZ dx dy dz) hΦ hbz⟩

/-- **det|NRS³ is strict in the band**, for the six observables of the cube. -/
theorem robertson_det_strict_of_band (hx : 2 ≤ dx) (hy : 2 ≤ dy) (hz : 2 ≤ dz)
    {Φ : H3D dx dy dz} (hΦ : ‖Φ‖ = 1) (hbx : |velocityX Φ| ∈ Ϙ dx)
    (hby : |velocityY Φ| ∈ Ϙ dy) (hbz : |velocityZ Φ| ∈ Ϙ dz) :
    |(imMatrix (pairs dx dy dz) Φ).det| < (covMatrix (pairs dx dy dz) Φ).det :=
  RobertsonDeterminantBandStrict.robertson_det_band_strict hx hy hz hΦ hbx hby hbz

end UncertaintyCone
