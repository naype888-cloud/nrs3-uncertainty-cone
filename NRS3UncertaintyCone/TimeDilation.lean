/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import NRS3UncertaintyCone.Cone

/-!
# The time dilation of the uncertainty

Robertson–Schrödinger is the Cauchy–Schwarz inequality of two fluctuations; in the cone it is the
statement that the uncertainty vector is future causal. Between the two sits a right triangle:
the hypotenuse is `‖x‖ ‖y‖`, the angle `θ` between the fluctuations splits it into the pairing
`‖x‖ ‖y‖ cos θ` and the proper time `τ = √η(v, v) = ‖x‖ ‖y‖ sin θ`.

The proper time never exceeds the time component `v₀`: time dilation. At the maximal current
state `θ` is the NRS angle, so `τ = ‖x‖ ‖y‖ sin θ_NRS(d)`: zero exactly for `d = 2, 3`, where
the vector lies on the light cone, positive from `d = 4` on.

## Main results

- `UncertaintyCone.properTime_eq_mul_sin` : `τ = ‖x‖ ‖y‖ sin θ`.
- `UncertaintyCone.norm_inner_eq_mul_cos` : `‖⟪x, y⟫‖ = ‖x‖ ‖y‖ cos θ`.
- `UncertaintyCone.properTime_le_time` : `τ ≤ v₀`.
- `UncertaintyCone.properTime_maxCurrentState` : `τ = ‖x‖ ‖y‖ sin θ_NRS(d)`.
- `UncertaintyCone.properTime_maxCurrentState_pos` : `0 < τ` from `d = 4` on.
-/

@[expose] public noncomputable section

open NRSInequality TransportPosition SpectralExtremal Gnomon NRSAngle

namespace UncertaintyCone

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]

/-! ## 1. The right triangle -/

/-- The proper time of a four-vector, `τ = √η(v, v)`. -/
def properTime (v : Fin 4 → ℝ) : ℝ := √(interval v)

/-- The angle between two fluctuation vectors, `θ = arccos β`. -/
def angle (x y : H) : ℝ := Real.arccos (speed x y)

private lemma interval_eq (x y : H) :
    interval (coneVector x y) = (‖x‖ * ‖y‖) ^ 2 - ‖inner ℂ x y‖ ^ 2 := by
  rw [interval_eq_gramDefectC, CauchyGram.gramDefectC, CauchyGram.varianceC,
    CauchyGram.varianceC]
  ring

private lemma speed_mem (x y : H) (h : ‖x‖ * ‖y‖ ≠ 0) : 0 ≤ speed x y ∧ speed x y ≤ 1 := by
  have hp : 0 < ‖x‖ * ‖y‖ := lt_of_le_of_ne (by positivity) (Ne.symm h)
  refine ⟨by unfold speed; positivity, ?_⟩
  rw [speed, div_le_one hp]
  exact norm_inner_le_norm x y

/-- **The right triangle of the uncertainty.** `τ = ‖x‖ ‖y‖ sin θ`. -/
theorem properTime_eq_mul_sin (x y : H) :
    properTime (coneVector x y) = ‖x‖ * ‖y‖ * Real.sin (angle x y) := by
  rcases eq_or_ne (‖x‖ * ‖y‖) 0 with h | h
  · have hi : interval (coneVector x y) = 0 := by
      have := (mem_futureCone x y).2
      rw [interval_eq, h] at this ⊢
      nlinarith [norm_nonneg (inner ℂ x y)]
    rw [properTime, hi, h, Real.sqrt_zero, zero_mul]
  · have hs := speed_mem x y h
    rw [properTime, interval_eq_speed x y h, angle, Real.sin_arccos,
      Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq (by positivity)]

/-- The pairing is the other leg: `‖⟪x, y⟫‖ = ‖x‖ ‖y‖ cos θ`. -/
theorem norm_inner_eq_mul_cos (x y : H) :
    ‖inner ℂ x y‖ = ‖x‖ * ‖y‖ * Real.cos (angle x y) := by
  rcases eq_or_ne (‖x‖ * ‖y‖) 0 with h | h
  · rw [h, zero_mul]
    exact le_antisymm ((norm_inner_le_norm x y).trans h.le) (norm_nonneg _)
  · have hs := speed_mem x y h
    rw [angle, Real.cos_arccos (by linarith) hs.2, speed, mul_div_cancel₀ _ h]

/-! ## 2. Time dilation -/

/-- **Time dilation.** The proper time never exceeds the time component `v₀`. -/
theorem properTime_le_time (x y : H) : properTime (coneVector x y) ≤ coneVector x y 0 := by
  have h0 := (mem_futureCone x y).1
  rw [properTime, Real.sqrt_le_left h0]
  unfold interval
  nlinarith [sq_nonneg (coneVector x y 1), sq_nonneg (coneVector x y 2),
    sq_nonneg (coneVector x y 3)]

/-! ## 3. The NRS angle -/

variable {d : ℕ}

/-- **At the maximal current state, `τ = ‖x‖ ‖y‖ sin θ_NRS(d)`.** -/
theorem properTime_maxCurrentState (hd : 2 ≤ d) :
    properTime (coneVector (centered (TdOp d) (maxCurrentState d))
        (centered (PdOp d) (maxCurrentState d))) =
      ‖centered (TdOp d) (maxCurrentState d)‖ * ‖centered (PdOp d) (maxCurrentState d)‖ *
        Real.sin (angleNRS d) := by
  rw [properTime_eq_mul_sin, angle, speed_maxCurrentState hd, angleNRS_eq hd]

/-- **The excess is the first time.** From `d = 4` on the proper time is positive. -/
theorem properTime_maxCurrentState_pos (hd : 4 ≤ d) :
    0 < properTime (coneVector (centered (TdOp d) (maxCurrentState d))
        (centered (PdOp d) (maxCurrentState d))) :=
  Real.sqrt_pos.mpr (timelike_maxCurrentState hd)

end UncertaintyCone
