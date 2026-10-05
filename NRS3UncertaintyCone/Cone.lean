/-
Copyright (c) 2026 Eduardo Nava-Hernandez. All rights reserved.
Released under the NRS Noncommercial License 1.0.0 as described in the file LICENSE.
Authors: Eduardo Nava-Hernandez
-/
module

public import NavaRobertsonIndependent.Mathematics.D1_CauchyGramInequality
public import NavaRobertsonIndependent.Mathematics.D37b_NRSAngle
public import Mathlib.LinearAlgebra.Matrix.Hermitian

/-!
# The uncertainty cone of the pair `T_d : P_d`

Two fluctuation vectors `x = (A − ⟨A⟩)ψ`, `y = (B − ⟨B⟩)ψ` of a complex inner product space have
the Hermitian Gram matrix `G = !![‖x‖², ⟪x, y⟫; ⟪y, x⟫, ‖y‖²]`. A Hermitian `2 × 2` matrix is
`v₀ 1 + v₁ σ₁ − v₂ σ₂ + v₃ σ₃` for one real four-vector `v`, and `det G = v₀² − v₁² − v₂² − v₃²`
is its Minkowski interval (van der Waerden 1929). Here

`v = ((‖x‖² + ‖y‖²)/2, Re ⟪x, y⟫, Im ⟪x, y⟫, (‖x‖² − ‖y‖²)/2)`,

so `v₁` is the covariance and `v₂` is half the commutator.

* Robertson–Schrödinger (`D1`) places `v` in the closed future cone; saturation is a null `v`, a
  positive Gram defect a timelike `v`.
* `A → λA`, `B → B/λ` keeps `[A, B]` and acts on `G` as `diag(λ, 1/λ) ∈ SL(2, ℂ)`: a boost along
  `v₃`. The interval, `v₁` and `v₂` do not change, which is why `C_Nava` carries no units.
* The boost reaches the frame `v₃ = 0`; there `v₀ = ‖x‖ ‖y‖` and the speed of `v` is
  `β = |⟪x, y⟫| / (‖x‖ ‖y‖) = cos θ_NRS` (`D37b`). At `ψ*`, `β = 1 / C_Nava(d)`: `v` is null iff
  `d = 2, 3` and timelike from `d = 4` on.

Over `ℝ` the inner product is real and `v₂ = 0`: the commutator axis is lost. The four
components are variances, covariance and commutator of the pair, not coordinates of events.

## Main results

- `UncertaintyCone.gramMatrix_eq` : `G` in the components of `v`.
- `UncertaintyCone.det_gramMatrix` : `det G = η(v, v)`.
- `UncertaintyCone.mem_futureCone` : `0 ≤ v₀` and `0 ≤ η(v, v)`.
- `UncertaintyCone.interval_eq_zero_iff` : `v` is null iff Cauchy–Schwarz is saturated.
- `UncertaintyCone.coneVector_smul`, `UncertaintyCone.boost_coeff` : the rescaling is a boost.
- `UncertaintyCone.balanced_frame` : a rescaling sets `v₃ = 0` and `v₀ = ‖x‖ ‖y‖`.
- `UncertaintyCone.interval_eq_speed` : `η(v, v) = (‖x‖ ‖y‖)² (1 − β²)`.
- `UncertaintyCone.speed_psiStar` : `β = 1 / C_Nava(d)` at `ψ*`.
- `UncertaintyCone.null_psiStar_iff`, `UncertaintyCone.timelike_psiStar` : null iff `d = 2, 3`,
  timelike for `d ≥ 4`.
-/

@[expose] public noncomputable section

open Matrix NRSInequality TransportPosition SpectralExtremal Gnomon

namespace UncertaintyCone

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]

/-! ## 1. The Gram matrix as a four-vector -/

/-- The Minkowski interval `η(v, v) = v₀² − v₁² − v₂² − v₃²`. -/
def interval (v : Fin 4 → ℝ) : ℝ := v 0 ^ 2 - v 1 ^ 2 - v 2 ^ 2 - v 3 ^ 2

/-- The Gram matrix of two vectors. -/
def gramMatrix (x y : H) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![((‖x‖ ^ 2 : ℝ) : ℂ), inner ℂ x y; inner ℂ y x, ((‖y‖ ^ 2 : ℝ) : ℂ)]

/-- The uncertainty four-vector of `x`, `y`. -/
def coneVector (x y : H) : Fin 4 → ℝ :=
  ![(‖x‖ ^ 2 + ‖y‖ ^ 2) / 2, (inner ℂ x y).re, (inner ℂ x y).im, (‖x‖ ^ 2 - ‖y‖ ^ 2) / 2]

@[simp] theorem coneVector_zero (x y : H) : coneVector x y 0 = (‖x‖ ^ 2 + ‖y‖ ^ 2) / 2 := rfl
@[simp] theorem coneVector_one (x y : H) : coneVector x y 1 = (inner ℂ x y).re := rfl
@[simp] theorem coneVector_two (x y : H) : coneVector x y 2 = (inner ℂ x y).im := rfl
@[simp] theorem coneVector_three (x y : H) : coneVector x y 3 = (‖x‖ ^ 2 - ‖y‖ ^ 2) / 2 := rfl

theorem gramMatrix_isHermitian (x y : H) : (gramMatrix x y).IsHermitian := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [gramMatrix]

/-- `G = v₀ 1 + v₁ σ₁ − v₂ σ₂ + v₃ σ₃`, written entrywise. -/
theorem gramMatrix_eq (x y : H) :
    gramMatrix x y =
      !![((coneVector x y 0 + coneVector x y 3 : ℝ) : ℂ),
          (coneVector x y 1 : ℂ) + (coneVector x y 2 : ℂ) * Complex.I;
        (coneVector x y 1 : ℂ) - (coneVector x y 2 : ℂ) * Complex.I,
          ((coneVector x y 0 - coneVector x y 3 : ℝ) : ℂ)] := by
  ext i j
  fin_cases i <;> fin_cases j <;> apply Complex.ext <;> simp [gramMatrix] <;>
    first | ring1 | exact inner_re_symm (𝕜 := ℂ) y x | simpa using inner_im_symm (𝕜 := ℂ) y x

/-- **The determinant is the interval.** -/
theorem det_gramMatrix (x y : H) :
    (gramMatrix x y).det = ((interval (coneVector x y) : ℝ) : ℂ) := by
  rw [gramMatrix_eq, det_fin_two_of, interval]
  push_cast
  linear_combination (coneVector x y 2 : ℂ) ^ 2 * Complex.I_sq

/-- The interval is the Gram defect of `D1`. -/
theorem interval_eq_gramDefectC (x y : H) :
    interval (coneVector x y) = CauchyGram.gramDefectC x y := by
  simp only [interval, coneVector_zero, coneVector_one, coneVector_two, coneVector_three,
    CauchyGram.gramDefectC, CauchyGram.varianceC, Complex.sq_norm, Complex.normSq_apply]
  ring

/-! ## 2. Robertson–Schrödinger is the future cone -/

/-- **Robertson–Schrödinger.** The uncertainty vector lies in the closed future cone. -/
theorem mem_futureCone (x y : H) : 0 ≤ coneVector x y 0 ∧ 0 ≤ interval (coneVector x y) := by
  refine ⟨by rw [coneVector_zero]; positivity, ?_⟩
  rw [interval_eq_gramDefectC]
  exact CauchyGram.gramDefectC_nonneg x y

/-- **Saturation is null.** -/
theorem interval_eq_zero_iff (x y : H) :
    interval (coneVector x y) = 0 ↔ ‖inner ℂ x y‖ = ‖x‖ * ‖y‖ := by
  rw [interval_eq_gramDefectC]
  exact CauchyGram.gramDefectC_eq_zero_iff x y

/-! ## 3. Units are a boost -/

/-- The coefficients `c = (λ² + λ⁻²)/2`, `s = (λ² − λ⁻²)/2` satisfy `c² − s² = 1`. -/
theorem boost_coeff {l : ℝ} (hl : l ≠ 0) :
    ((l ^ 2 + l⁻¹ ^ 2) / 2) ^ 2 - ((l ^ 2 - l⁻¹ ^ 2) / 2) ^ 2 = 1 := by
  field_simp
  ring

theorem inner_smul_inv (x y : H) {l : ℝ} (hl : l ≠ 0) :
    inner ℂ ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) = inner ℂ x y := by
  rw [inner_smul_left, inner_smul_right, Complex.conj_ofReal, ← mul_assoc,
    Complex.ofReal_inv, mul_inv_cancel₀ (by exact_mod_cast hl), one_mul]

theorem norm_smul_sq (x : H) (l : ℝ) : ‖(l : ℂ) • x‖ ^ 2 = l ^ 2 * ‖x‖ ^ 2 := by
  rw [norm_smul, Complex.norm_real, Real.norm_eq_abs, mul_pow, sq_abs]

/-- **`A → λA`, `B → B/λ` is a boost along `v₃`**, with `c`, `s` as in `boost_coeff`; `v₁` and
`v₂` do not change. -/
theorem coneVector_smul (x y : H) {l : ℝ} (hl : l ≠ 0) :
    coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 0 =
        (l ^ 2 + l⁻¹ ^ 2) / 2 * coneVector x y 0 + (l ^ 2 - l⁻¹ ^ 2) / 2 * coneVector x y 3 ∧
      coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 1 = coneVector x y 1 ∧
      coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 2 = coneVector x y 2 ∧
      coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 3 =
        (l ^ 2 - l⁻¹ ^ 2) / 2 * coneVector x y 0 + (l ^ 2 + l⁻¹ ^ 2) / 2 * coneVector x y 3 := by
  simp only [coneVector_zero, coneVector_one, coneVector_two, coneVector_three, norm_smul_sq,
    inner_smul_inv x y hl]
  refine ⟨?_, trivial, trivial, ?_⟩ <;> ring

/-- The interval does not change under the boost. -/
theorem interval_smul (x y : H) {l : ℝ} (hl : l ≠ 0) :
    interval (coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y)) = interval (coneVector x y) := by
  obtain ⟨h0, h1, h2, h3⟩ := coneVector_smul x y hl
  rw [interval, interval, h0, h1, h2, h3]
  linear_combination (coneVector x y 0 ^ 2 - coneVector x y 3 ^ 2) * boost_coeff hl

/-- **The balanced frame.** With `λ² = ‖y‖ / ‖x‖`, `v₃ = 0` and `v₀ = ‖x‖ ‖y‖`. -/
theorem balanced_frame (x y : H) (hx : x ≠ 0) (hy : y ≠ 0) :
    let l := √(‖y‖ / ‖x‖)
    coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 3 = 0 ∧
      coneVector ((l : ℂ) • x) (((l⁻¹ : ℝ) : ℂ) • y) 0 = ‖x‖ * ‖y‖ := by
  intro l
  have hx' : 0 < ‖x‖ := norm_pos_iff.mpr hx
  have hy' : 0 < ‖y‖ := norm_pos_iff.mpr hy
  have hl2 : l ^ 2 = ‖y‖ / ‖x‖ := Real.sq_sqrt (by positivity)
  have hli : l⁻¹ ^ 2 = ‖x‖ / ‖y‖ := by rw [inv_pow, hl2, inv_div]
  rw [coneVector_three, coneVector_zero, norm_smul_sq, norm_smul_sq, hl2, hli]
  constructor <;> field_simp <;> ring

/-! ## 4. The speed of the uncertainty vector -/

/-- The speed in the balanced frame, `β = |⟪x, y⟫| / (‖x‖ ‖y‖)`. -/
def speed (x y : H) : ℝ := ‖inner ℂ x y‖ / (‖x‖ * ‖y‖)

/-- `η(v, v) = (‖x‖ ‖y‖)² (1 − β²)`. -/
theorem interval_eq_speed (x y : H) (h : ‖x‖ * ‖y‖ ≠ 0) :
    interval (coneVector x y) = (‖x‖ * ‖y‖) ^ 2 * (1 - speed x y ^ 2) := by
  rw [interval_eq_gramDefectC, CauchyGram.gramDefectC, CauchyGram.varianceC, CauchyGram.varianceC,
    speed, div_pow, mul_sub, mul_one, mul_div_cancel₀ _ (pow_ne_zero 2 h)]
  ring

/-! ## 5. At the maximal-tension state -/

variable {d : ℕ}

/-- **The speed at `ψ*` is `1 / C_Nava(d)`.** -/
theorem speed_psiStar (hd : 2 ≤ d) :
    speed (centered (TdOp d) (psiStar d)) (centered (PdOp d) (psiStar d)) =
      1 / CoherenceConstant d :=
  NRSAngle.cos_angleNRS hd

theorem norm_mul_norm_psiStar_ne_zero (hd : 2 ≤ d) :
    ‖centered (TdOp d) (psiStar d)‖ * ‖centered (PdOp d) (psiStar d)‖ ≠ 0 := by
  intro h0
  have h := speed_psiStar hd
  rw [speed, h0, div_zero] at h
  have hC := NRSAngle.CoherenceConstant_ge_one hd
  have : 0 < 1 / CoherenceConstant d := by positivity
  linarith

/-- **Null iff `d = 2, 3`.** -/
theorem null_psiStar_iff (hd : 2 ≤ d) :
    interval (coneVector (centered (TdOp d) (psiStar d)) (centered (PdOp d) (psiStar d))) = 0 ↔
      d = 2 ∨ d = 3 := by
  have hC := NRSAngle.CoherenceConstant_ge_one hd
  have hn := norm_mul_norm_psiStar_ne_zero hd
  rw [interval_eq_speed _ _ hn, speed_psiStar hd, ← CoherenceConstant_eq_one_iff d hd]
  constructor
  · intro h
    have h1 := (mul_eq_zero.mp h).resolve_left (pow_ne_zero 2 hn)
    rw [div_pow, one_pow, sub_eq_zero, eq_comm, div_eq_one_iff_eq (by positivity)] at h1
    nlinarith
  · intro h
    rw [h]
    ring

/-- **Timelike from `d = 4` on.** -/
theorem timelike_psiStar (hd : 4 ≤ d) :
    0 < interval (coneVector (centered (TdOp d) (psiStar d)) (centered (PdOp d) (psiStar d))) := by
  have hC := one_lt_CoherenceConstant_of_four_le d hd
  have hn := norm_mul_norm_psiStar_ne_zero (d := d) (by omega)
  rw [interval_eq_speed _ _ hn, speed_psiStar (by omega)]
  have : (1 / CoherenceConstant d) ^ 2 < 1 := by
    rw [div_pow, one_pow, div_lt_one (by positivity)]
    nlinarith
  have : 0 < (‖centered (TdOp d) (psiStar d)‖ * ‖centered (PdOp d) (psiStar d)‖) ^ 2 := by
    positivity
  nlinarith

end UncertaintyCone
