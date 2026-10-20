// The closed axis of T³: the pair (T°_d, P_d) on the ring of d positions, and its uncertainty four-vector.
// T°_d = ring adjacency / 2 (spectral radius 1), P_d = centred position; with d = 3 these are
// ClosedThree.Tc = (J − I)/2 and P₃ = diag(−1, 0, 1) of Lean (nrs3-hopf).
(() => {
  function jacobi(M) {
    const n = M.length, A = M.map((r) => r.slice()), V = A.map((r, i) => r.map((_, j) => (i === j ? 1 : 0)));
    for (let sw = 0; sw < 60; sw++) {
      let off = 0;
      for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) off += A[i][j] ** 2;
      if (off < 1e-24) break;
      for (let p = 0; p < n; p++) for (let q = p + 1; q < n; q++) {
        if (Math.abs(A[p][q]) < 1e-300) continue;
        const th = (A[q][q] - A[p][p]) / (2 * A[p][q]), t = Math.sign(th || 1) / (Math.abs(th) + Math.sqrt(th * th + 1));
        const c = 1 / Math.sqrt(t * t + 1), s = t * c;
        for (let k = 0; k < n; k++) { const x = A[k][p], y = A[k][q]; A[k][p] = c * x - s * y; A[k][q] = s * x + c * y; }
        for (let k = 0; k < n; k++) { const x = A[p][k], y = A[q][k]; A[p][k] = c * x - s * y; A[q][k] = s * x + c * y; }
        for (let k = 0; k < n; k++) { const x = V[k][p], y = V[k][q]; V[k][p] = c * x - s * y; V[k][q] = s * x + c * y; }
      }
    }
    return { vals: A.map((r, i) => r[i]), V };
  }
  const pos = (d) => Array.from({ length: d }, (_, j) => (2 * (j + 1) - (d + 1)) / (d - 1));
  // the maximal current state: top eigenvector of K = i[T°, P] in its real form [[0, −B], [B, 0]]
  function maxCurrent(d) {
    const p = pos(d), M = Array.from({ length: 2 * d }, () => new Array(2 * d).fill(0));
    for (let j = 0; j < d; j++) for (const k of [(j + 1) % d, (j + d - 1) % d]) {
      const b = 0.5 * (p[k] - p[j]); M[j][k + d] -= b; M[j + d][k] += b;
    }
    const { vals, V } = jacobi(M);
    let top = 0; vals.forEach((v, i) => { if (v > vals[top]) top = i; });
    const re = [], im = [];
    for (let j = 0; j < d; j++) { re.push(V[j][top]); im.push(V[j + d][top]); }
    const nn = Math.hypot(...re, ...im);
    return { re: re.map((x) => x / nn), im: im.map((x) => x / nn) };
  }
  // the saturating state of the closed axis d = 3 (ClosedThreeBand.satState), tension 1, null
  function satState() {
    const k = 1 / (2 * Math.SQRT2);
    return { re: [k, 2 * k, k], im: [k, 0, -k] };
  }
  // Gram of the centred pair: a = ‖δT‖², b = ‖δP‖², ⟨δT, δP⟩ = ir + i·ii; v = (v0, v1, v2, v3) as in Cone.analyse
  function ringVector(d, s) {
    const p = pos(d), Tr = new Float64Array(d), Ti = new Float64Array(d);
    for (let j = 0; j < d; j++) {
      Tr[j] = (s.re[(j + d - 1) % d] + s.re[(j + 1) % d]) / 2;
      Ti[j] = (s.im[(j + d - 1) % d] + s.im[(j + 1) % d]) / 2;
    }
    let mT = 0, mP = 0;
    for (let j = 0; j < d; j++) { mT += s.re[j] * Tr[j] + s.im[j] * Ti[j]; mP += p[j] * (s.re[j] ** 2 + s.im[j] ** 2); }
    let a = 0, b = 0, ir = 0, ii = 0;
    for (let j = 0; j < d; j++) {
      const xr = Tr[j] - mT * s.re[j], xi = Ti[j] - mT * s.im[j], yr = (p[j] - mP) * s.re[j], yi = (p[j] - mP) * s.im[j];
      a += xr * xr + xi * xi; b += yr * yr + yi * yi; ir += xr * yr + xi * yi; ii += xr * yi - xi * yr;
    }
    return [(a + b) / 2, ir, ii, (a - b) / 2];
  }
  // eps < 0: the saturating state of d = 3; otherwise the maximal current state of the ring of d positions
  window.Cone.ringStart = (d, eps) => ringVector(d, eps < 0 ? satState() : maxCurrent(d));
})();
