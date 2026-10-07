/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import NRS3UncertaintyCone.TimeDilation

/-!
# The round trip of the uncertainty

Reversing the direction of the second fluctuation, `y ↦ -y`, reflects the uncertainty vector:
`v₁` and `v₂` change sign, `v₀` and `v₃` do not, and the proper time is the same both ways.
The way there and the way back together have `v₁ = v₂ = 0`: no net covariance, no net commutator.
Yet their proper time is at least twice that of one way. The round trip pays twice; coming back
to the start does not undo it.

## Main results

- `UncertaintyCone.properTime_neg` : going and coming back have the same proper time.
- `UncertaintyCone.round_trip_one`, `UncertaintyCone.round_trip_two` : no net `v₁`, no net `v₂`.
- `UncertaintyCone.two_mul_properTime_le_round_trip` : the round trip carries at least `2 τ`.
- `UncertaintyCone.round_trip_maxCurrentState_pos` : positive from `d = 4` on.
-/

@[expose] public noncomputable section

open NRSInequality TransportPosition SpectralExtremal Gnomon NRSAngle

namespace UncertaintyCone

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]

lemma coneVector_neg (x y : H) :
    coneVector x (-y) = ![coneVector x y 0, -coneVector x y 1, -coneVector x y 2,
      coneVector x y 3] := by
  ext i
  fin_cases i <;> simp [coneVector]

/-- **Going and coming back have the same proper time.** -/
theorem properTime_neg (x y : H) :
    properTime (coneVector x (-y)) = properTime (coneVector x y) := by
  rw [coneVector_neg, properTime, properTime, interval, interval]
  simp

/-- The way there and back has no net `v₁`. -/
theorem round_trip_one (x y : H) : (coneVector x y + coneVector x (-y)) 1 = 0 := by
  rw [Pi.add_apply, coneVector_neg]
  simp

/-- The way there and back has no net `v₂`. -/
theorem round_trip_two (x y : H) : (coneVector x y + coneVector x (-y)) 2 = 0 := by
  rw [Pi.add_apply, coneVector_neg]
  simp

/-- **The round trip pays twice.** -/
theorem two_mul_properTime_le_round_trip (x y : H) :
    2 * properTime (coneVector x y) ≤ properTime (coneVector x y + coneVector x (-y)) := by
  have h0 := (mem_futureCone x y).2
  have hs : interval (coneVector x y + coneVector x (-y)) =
      4 * (coneVector x y 0 ^ 2 - coneVector x y 3 ^ 2) := by
    rw [interval, coneVector_neg]
    simp only [Pi.add_apply]
    simp
    ring
  rw [properTime, properTime, hs, show (2 : ℝ) = √4 by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)],
    ← Real.sqrt_mul (by norm_num)]
  apply Real.sqrt_le_sqrt
  unfold interval at h0 ⊢
  nlinarith [sq_nonneg (coneVector x y 1), sq_nonneg (coneVector x y 2)]

variable {d : ℕ}

/-- **The round trip of `T_d : P_d`.** From `d = 4` on it carries positive proper time. -/
theorem round_trip_maxCurrentState_pos (hd : 4 ≤ d) :
    0 < properTime (coneVector (centered (TdOp d) (maxCurrentState d))
        (centered (PdOp d) (maxCurrentState d)) +
      coneVector (centered (TdOp d) (maxCurrentState d))
        (-centered (PdOp d) (maxCurrentState d))) := by
  have h := two_mul_properTime_le_round_trip (centered (TdOp d) (maxCurrentState d))
    (centered (PdOp d) (maxCurrentState d))
  have hp := properTime_maxCurrentState_pos hd
  linarith

end UncertaintyCone
