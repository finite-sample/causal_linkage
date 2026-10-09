# Candidate graphs, contrast invariance, and a modest statistical contribution

## 1. Are the characterization results new mathematical theorems?

### Takeaway
The zero-width characterization is an instance of established constant-objective matching theory. Component additivity and complete-block width are elementary consequences of separability and ordering. Their useful contribution here is translating these facts into a precise account of which unresolved identities matter for a causal analysis.

### Cited Findings
- Ćustić and Klinz, *The constant objective value property for combinatorial optimization problems* (May 2014), printed p. 3, explicitly state that a linear assignment objective is constant across all permutations exactly when its cost matrix is a sum matrix, `c_ij = u_i + v_j`. They credit Berenguer's earlier admissible-transformation argument. Their transportation extension is Theorem 3.1, printed pp. 17–18. [Author preprint](https://optimization-online.org/wp-content/uploads/2014/05/4364.pdf)
- Roughgarden's Stanford CS261 Lecture 5, Theorem 2.2, printed p. 4, gives the usual criterion: a perfect matching minimizes cost iff it has no negative alternating cycle. The proof decomposes two perfect matchings' symmetric difference into disjoint alternating cycles. Apply the criterion to both cost and negative cost to recover the project's zero-cycle-cost criterion. [Course author's notes](https://theory.stanford.edu/~tim/w16/l/l5.pdf)
- Assignment integrality and the Birkhoff–von Neumann representation are stated in Peyré's *Optimal Transport for Machine Learners*, compact notes, §3.2 (Theorem 3.15 and Corollaries 3.16–3.17 in the PDF fetched October 8, 2026; numbering differs from search-engine caches). [Author's full notes](https://www.gpeyre.com/ot4ml/compact/CourseOT-compact.pdf)

### Inferences
**Direct affine-hull reduction (our derivation, not a newly located published theorem).** Let `E*` be exactly the edges appearing in at least one perfect matching. Delete other edges. Let `A` be the row-and-column incidence matrix on `E*`, and `P` the convex hull of feasible matching incidence vectors. Bipartite matching integrality gives

`P = {x >= 0 : Ax = 1}`.

Averaging all perfect matchings produces `x_bar > 0` on every coordinate of `E*`. Hence `aff(P) = {x : Ax = 1}`: every direction in `ker(A)` is feasible a sufficiently small positive and negative distance from `x_bar`. Consequently:

1. `c'x` is constant over feasible perfect matchings;
2. iff `c` annihilates `ker(A)`;
3. iff `c` belongs to `row(A)`;
4. iff there are potentials `a_i,b_j` with `c_ij = a_i + b_j` on `E*`.

Substitute `c_ij = w_i y_j`. This yields a certificate of contrast identification despite unresolved linkage: analysis-weight times donor-outcome must admit row-plus-column potentials on the usable edges. It is standard linear algebra on the assignment polytope. The causal interpretation is useful; the underlying equivalence is not original mathematics.

Pruning unusable edges matters: imposing potentials on every raw candidate edge may require irrelevant conditions. A unique matching always identifies the statistic despite the raw graph's appearance.

On a complete block the rank-one cost has this property iff all block weights are equal or all block outcomes are equal: the two-by-two cost difference is `(w_i-w_k)(y_j-y_l)`. For an unadjusted treatment contrast this means all anchors in one arm or constant donor outcomes. The width formula follows by allocating the largest versus smallest `t_b` outcomes to treatment. Widths add over components because their feasible sets form a Cartesian product. A shared error budget breaks this separability and changes the affine hull.

### Gaps
I did not locate the exact causal-weight formula or complete-block width written in a published causal paper. That does not support theorem priority because the reductions are direct. I did not inspect Berenguer's original paper, so cite Ćustić–Klinz for the actual statement.

## 2. Is an identified analysis despite unidentified identities already understood?

### Takeaway
Yes, both for database queries generally and in an important causal special case. The new work can supply a systematic, checkable causal characterization and controlled comparison; it cannot claim first discovery that incorrect individual links may leave analysis unchanged.

### Cited Findings
- Wortman and Reiter, *Simultaneous Record Linkage and Causal Inference with Propensity Score Subclassification*, §3.1, printed pp. 6–7, explicitly swap two treated individuals' outcomes within a subclass and obtain exactly the same difference-in-means estimate. They immediately note that regression adjustment changes unless covariates coincide. §3.2 then addresses cross-treatment mistakes. [Author preprint, full text inspected](https://arxiv.org/pdf/1709.03631)
- Turkcapar and Krishnan, *Quantifying Uncertainty in Aggregate Queries over Integrated Datasets* (2023), §§2.2–3.2, defines extremal query results over candidate-compatible matchings. Its §2.3.1 example shows recordwise intervals incorrectly varying a donor-conserved total; Proposition 3.1 handles weighted objectives. The introduction contrasts query uncertainty with precision and recall. Their displayed inequalities need qualifications for signed weights; the project's full-bijection equalities handle signed causal costs. [Primary full text](https://arxiv.org/html/2309.05178v1)
- Bienvenu, Cima, and Gutiérrez-Basulto, *LACE: A Logical Approach to Collective Entity Resolution*, §4.3, PDF p. 6, Definition 6, distinguishes possible answers across some entity resolutions from certain answers across all. It explicitly seeks useful query answers without choosing one true resolution. Its setting is logical merging and conjunctive queries, not randomized-study numerical contrasts. [Author-hosted paper](https://orca.cardiff.ac.uk/id/eprint/149114/1/main.pdf)
- Hua and Pei, *Aggregate Queries on Probabilistic Record Linkages*, EDBT 2012, pp. 360–371, models compatible possible worlds and aggregate distributions. §3.4 factorizes worlds over graph components; §6.2 combines aggregates by convolution. Its probabilistic assumptions differ from deterministic feasible-set analysis. [Proceedings full text](https://openproceedings.org/2012/conf/edbt/HuaP12.pdf)

### Inferences
The useful change in emphasis is from identifying people to identifying the statistic a causal design needs. The general principle has antecedents. The specific operational translation can still contribute: arbitrary usable edges give a necessary-and-sufficient invariance test; blocks give an exact width; the controlled example fixes accepted linkage, actual accuracy, candidate degrees, and even feasible-map counts while changing causal information.

That is more specific than different mistakes having different bias: identical scalar diagnostics leave the analyst's robust conclusion undetermined because feasible identity changes align differently with estimator weights and donor values. A method or note can make that implication precise and actionable even with classical mathematics.

Crucial wording: zero realized-statistic width identifies the oracle statistic conditional on the observed data and linkage restrictions. It does not identify the finite-population ATE from one realized assignment. Randomization supplies unbiasedness or the sharp-null reference law; missing potential outcomes remain missing. Invariance of a contrast does not automatically preserve every standard error or adjusted analysis.

### Gaps
No inspected primary text combined this exact graph characterization, equal-accuracy/equal-degree comparison, and design-based randomization calculation in one causal-linkage treatment. This is bounded search evidence, not universal absence. Broad Bayesian causal-linkage papers are not literal substitutes for the narrower result. Search results returning the user's own blog are not independent corroboration.

## 3. Is there a defensible contribution worth developing?

### Takeaway
**Yes, a focused statistical characterization and diagnostic contribution is defensible; a claim of new assignment theory is not.** A new optimization algorithm is not necessary for a useful short methodological note. The strongest current claim is the combined causal formulation and executable inference, with the characterization explaining why it works and when it cannot help.

### Cited Findings
- The local note actually supplies the characterization, width formula, controlled comparison, and an attaining-witness robust Fisher calculation. These are present results rather than prospective graph-calibration work. [Current project note](/Users/soodoku/Documents/GitHub/causal_linkage/research/graph-information.md)
- GUILD's Step 3 recommends record-level linkage indicators, threshold sensitivity, or all possible links for imputation. This establishes relevant practical context for a contrast-based diagnostic without asserting practitioners ignore linkage uncertainty. [GUILD guidance](https://pmc.ncbi.nlm.nih.gov/articles/PMC5896589/)

### Inferences
**Strongest surviving contribution statement:**

> We characterize when unresolved record identities leave a specified causal contrast unchanged and quantify their effect otherwise. Candidate compatibility and one-to-one conservation express linkage uncertainty in analysis units, identify its contributing components, and support an executable exact worst-case Fisher test with an attaining linkage. Identical linkage accuracy and ambiguity counts can therefore support different causal conclusions.

Attribute the foundations directly: classical assignment theory, existing within-subclass swap observations, candidate-query bounds, and maximization over a nuisance set. The contribution is their targeted causal formulation and demonstrated consequences. Do not claim first identification without identity, first graph bounds, or first harmless within-arm mistakes.

I recommend **continuing as a tightly scoped note**, with the thesis “which ambiguities matter for this causal analysis?” The weaker thesis “graphs contain more information than scalar accuracy” is already explicit in database literature and is insufficient alone.

The present toy example is thin empirical evidence because its zero-width side uses the known within-arm case. Illustrations should expose the actual generality: a longer alternating cycle, unusable edges making raw components misleading, and fixed-weight adjusted contrasts for which treatment blocking fails to protect the estimate. An application should identify which components determine its result, rather than only report global bounds. These requests establish value, not an artificial requirement for a new algorithm.

The row-plus-column potential certificate gives an economical improvement: replace an exponentially phrased all-cycle condition with a verifiable linear system on supported edges. This is explanatory and implementation progress explicitly grounded in standard mathematics.

Publication worthiness depends on whether this diagnostic and exact support-only inference teach readers something they could not obtain readily from existing treatments. The present formulation gives a credible case for a modest note; search cannot certify journal acceptance.

### Gaps
The graph's whole-matching containment assumption remains substantive and uncalibrated by the graph alone. That limits empirical validity, not the logical characterization. The note need not solve calibration, incomplete overlap, simultaneous X/T/Y errors, and optimal review before contributing its restricted result; unimplemented extensions also cannot count as present contributions.

Research scope: approximately ten batched web calls on October 8, 2026; primary full texts spanning assignment/transport, uncertain linked-data aggregates, logical entity resolution, propensity-based causal linkage, and practice guidance. No universal novelty or universal absence claim.
