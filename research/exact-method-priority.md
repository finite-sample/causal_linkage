# Exact identity-constrained randomization inference: focused priority review

Review date: 8 October 2026. Scope: `R/information.R` and the full-bijection, complete-randomization result in `research/graph-information.md`. This is a review of the specific method, not the broader linkage project or the Rajasthan illustration.

**Decision: narrow and test.** The method is a defensible, potentially useful specialization of established sensitivity-analysis tools. The inspected primary papers do not explicitly give this exact procedure. Its core reduction follows quickly from permutation invariance and monotonicity; it is not a new general optimization or validity principle. That is a reason to make the contribution precise and demonstrate its use, rather than abandon it or announce a major theorem.

The strongest contribution sentence is:

> We develop exact randomization sensitivity analysis over candidate-constrained record identities: under complete randomization and full overlap, the procedure computes the sharp-null p-value range over all allowed bijections and identity-error budgets, and returns the identities attaining its endpoints.

“Exact” refers to the stated randomization distribution and global optimization, subject to numerical solver tolerances. It does not mean the graph or error budget has established coverage, and it does not imply a polynomial-time algorithm.

## Closest predecessors and the actual difference

| Primary source | What it supplies | What this implementation adds |
|---|---|---|
| [Hall and Fienberg, *Valid Statistical Inference on Automatically Matched Files*, Sections 3–5](https://www.cs.cmu.edu/~rjhall/linkage.pdf) | Confidence sets of bipartite matchings described by constraints, then extrema of downstream statistics, including regression coefficients. Their permutation test concerns a hypothesized matching. | The experimental assignment law, sharp causal null, and common-reference reduction for a full outcome bijection. Their matching-set propagation principle already contains the broad strategy. |
| [Heng and Shaw, *Sensitivity Analysis for Binary Outcome Misclassification in Randomization Tests via Integer Programming*, Definition 1 and Section 4.1](https://arxiv.org/html/2201.03111v3) | Minimum outcome alterations needed to change a randomization-test decision, sensitive records, and additional linear restrictions. The displayed sharp-null optimization uses a chi-square critical value. [RIOM](https://github.com/siyuheng/RIOM) implements their framework. | An explicit identity matching matrix, donor conservation, candidate restrictions, and an identity rather than outcome-error budget, together with an exact fixed reference law. This is a constrained specialization of their sensitivity logic. |
| [Ota and Imaizumi, *Finite-Sample Inference for Sparsely Permuted Linear Regression*, Sections 4.1–4.3](https://arxiv.org/html/2601.14872v2) | Candidate permutation sets and unions of coefficient confidence regions under a Gaussian regression model, including permutation-set coverage. | A fixed finite population and randomness from experimental treatment assignment, with an absolute-contrast optimization. Inference without uniquely recovering identities is already present in their work. |

Targeted searches combining record linkage, candidate matchings, exact Fisher inference, worst-case p-values, and unknown outcome permutations did not locate an explicit earlier implementation of this entire construction. This is scoped evidence, not proof of priority. Papers on propensity-score matching optimize treatment–control design, a different matching object; they cannot be counted as duplicates merely because they use graphs and randomization inference.

## The nesting is explicit

Write \(X\) for a permutation matrix and let \(X_0\) be the accepted one. The current uncertainty set is

\[
\mathcal X(G,K)=\{X\in\{0,1\}^{N\times N}:X\mathbf1=X^\top\mathbf1=\mathbf1,
\ X_{ij}=0\text{ off }G,\quad N-\langle X,X_0\rangle\le K\}.
\]

Its reconstructed outcome vectors are \(\mathcal V(G,K)=\{Xy:X\in\mathcal X(G,K)\}\). This places the method within matching-set propagation. For binary outcomes, it also embeds within outcome-misclassification sensitivity by restricting the candidate corrected vectors to \(\mathcal V(G,K)\). In particular,

\[
\|Xy-X_0y\|_0\le N-\langle X,X_0\rangle,
\]

but equality need not hold: exchanges of equal-valued donors consume identity errors without altering outcomes. Generic outcome corrections also need not preserve the total number of successes or admit any donor-respecting matching. Thus replacing our set with an ordinary Hamming ball changes the scientific uncertainty model.

The full bijection preserves the outcome multiset. Under complete randomization, every reconstruction consequently has the same absolute-contrast tail function \(H\), giving

\[
\max_{X\in\mathcal X}p(X)=H\!\left(\min_{X\in\mathcal X}|w^\top Xy|\right),
\qquad
\min_{X\in\mathcal X}p(X)=H\!\left(\max\{|L|,|U|\}\right).
\]

The implementation matters because it enforces attainable identities. An interval for the contrast that contains zero need not contain an attainable zero. Nonetheless the displayed reduction itself is an elementary consequence of the common law; the matching formulation and an epigraph for absolute value are standard. The substantive addition is a fully specified identity-constrained causal procedure with witnesses and a usable sensitivity profile.

The containment correction is also inherited: maximizing valid p-values over a set containing the truth with probability at least \(1-\delta\), then adding \(\delta\), is the [Berger–Boos confidence-set argument](https://doi.org/10.1080/01621459.1994.10476836). The repository accepts the containment bound; it does not learn it.

## The useful next output: identity breakdown

For a baseline that rejects at level \(\alpha\), report

\[
K_{\mathrm{break}}=\min\{K:p_{\max}(G,K)>\alpha\},
\]

when rejection is defined as \(p\le\alpha\). Return infinity if no permitted reconstruction removes rejection. With a containment correction, replace \(p_{\max}\) by \(\min(1,p_{\max}+\delta)\). Other rejection conventions require the corresponding boundary change.

This asks how many accepted identities must change, while retaining the candidate restrictions, before the result ceases to reject. It is a useful inverse of the current budget profile, not an independent conceptual invention: it is the identity-constrained counterpart of Heng–Shaw warning accuracy. Search over budgets is valid because the sets are nested and \(p_{\max}\) is nondecreasing. A direct optimization can instead minimize identity changes subject to the exact test accepting. Preserve strictness at the discrete rejection boundary.

## A strong, cheap binary comparator

There is an exact closed form for the complete-graph comparator. Let \(q_0\) be treated successes under the accepted bijection, \(s=\sum_jy_j\), and

\[
a=\max(0,m-(N-s)),\qquad b=\min(m,s).
\]

With at most \(K\) identity changes, the attainable treated-success counts are precisely

\[
\max(a,q_0-\lfloor K/2\rfloor)\le q\le
\min(b,q_0+\lfloor K/2\rfloor),\qquad q\text{ integer}.
\]

Proof: changing treated successes by \(d\) requires at least \(|d|\) treated outcome changes and \(|d|\) opposite control changes, hence at least \(2|d|\) identity changes. Disjoint swaps of opposite outcomes across arms attain the bound whenever \(q\) is in the natural support. The exact hypergeometric law then evaluates every attainable count without matching optimization. This is our derivation of a baseline, not a searched claim of originality. Independent exhaustive enumeration verified the formula for all binary outcome vectors, arm sizes, and budgets with N = 2 through 6 (3,324 cases), comparing every permutation.

For arbitrary candidate graphs, intermediate counts can be unattainable. Equal-valued donors cannot simply be collapsed unless candidate incidence and identity costs are preserved. A scalability extension should exploit actual component structure or justified equivalence classes and verify the projected feasible set, rather than assume that outcome counts alone retain identity feasibility.

## What would justify doubling down

Center the repository and manuscript on this exact procedure. Give it the identity breakdown output and the complete-graph binary comparator. Then measure whether identifier-derived graphs materially improve robust decisions, relative to that comparator, at credible restrictions and realistic sample sizes. Use known identities for evaluation, while reporting candidate omissions separately. Report power, exact-test size, witness feasibility, and run time. The Rajasthan rectangular stratified analysis does not validate this particular theorem.

If that comparison is useful, the result merits a focused methods note and tool even though the reduction is short. If it only helps graphs engineered around treatment and outcomes, the defensible product is an implementation/tutorial. The missing evidence is practical gain from credible identity information; the current obstacle is not the absence of an entirely new mathematical principle.
