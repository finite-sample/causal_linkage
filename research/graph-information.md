# What candidate graphs tell us about causal contrasts

A linkage accuracy rate counts mistaken identities. A candidate graph also restricts
where each mistake can send an outcome or treatment label. Those restrictions can
identify a treatment contrast even when individual identities remain unresolved.
They can also leave considerable uncertainty. The relevant quantity is how feasible
identity changes align with the weights in the causal estimator and the values of
the fields being moved.

This note develops that information directly. It supplies proofs, an executable
randomization test, and a controlled comparison that keeps the accepted linkage,
its accuracy, and the number of candidates per record fixed. The existing
[assignment-bound literature](https://arxiv.org/html/2309.05178v1) and
[misclassification sensitivity literature](https://arxiv.org/pdf/2201.03111)
provide the optimization foundations.

## 1. Population, linkage, and target

There are N fixed experimental units with potential outcomes Y_i(0), Y_i(1).
Exactly m receive treatment under complete random assignment, with c = N - m
controls. The finite-population average treatment effect is

\[
\tau = N^{-1}\sum_i\{Y_i(1)-Y_i(0)\}.
\]

The anchor file contains the known assignment Z. The donor file contains exactly
one realized outcome for each experimental unit, with no extra or missing units.
Its outcomes are y_1,...,y_N. The unknown true linkage pi* is a bijection, and
Y_i = y_{pi*(i)}. This full-overlap assumption is substantive.

A graph G lists allowed anchor-donor pairs. An accepted linkage pi_0 is a proposed
bijection. An accuracy restriction says at most K accepted links are incorrect.
The analyst retains

\[
\mathcal M(G,K)=\{\pi:\pi\text{ is a bijection},\ (i,\pi(i))\in G\ \forall i,
\quad \sum_i1\{\pi(i)\ne\pi_0(i)\}\le K\}.
\]

The accuracy-only comparator retains the same donor pool, one-to-one restriction,
accepted linkage, and K, but replaces G with the complete bipartite graph.
It is therefore stronger than a comparator that freely invents replacement outcomes.
The graph analysis adds only candidate restrictions. K is an upper bound, not an
assertion that exactly K identities are wrong.

For a reconstruction pi, define

\[
T(\pi)=\sum_iw_i y_{\pi(i)},\qquad
w_i=Z_i/m-(1-Z_i)/c.
\]

The oracle T(pi*) is unbiased for tau over random assignment. Its feasible range
[L_G,U_G] contains the oracle statistic if pi* is feasible. It is an **estimate
range**, not an interval with specified coverage for tau.

More generally, all fixed linear weights can replace w. In a fixed-design OLS
regression, the weights are the appropriate row of (X'X)^{-1}X'. If linkage changes
the design matrix itself, those weights must be recomputed for each reconstruction.

## 2. Exactly what the graph adds

**Set inclusion.** For the same accepted linkage and budget,
M(G,K) is a subset of M(complete,K). Consequently L_G is at least L_rate and U_G
is at most U_rate. Any valid test that maximizes an oracle p-value over these sets
also satisfies p_G <= p_rate. The inequality can be strict. It need not be strict,
and two graphs with the same degrees need not be ordered by inclusion.

**Proof.** Every graph-feasible map satisfies the accuracy-only constraints.
Taking minima, maxima, or maximum p-values over a subset gives the stated
inequalities. This argument requires the same constraints in both comparisons.
A narrow graph that drops the true map does not establish a more informative
valid result.

**The effect of a swap.** If donors j and l can be exchanged between anchors i and k,
the contrast changes by

\[
(w_i-w_k)(y_l-y_j).
\]

This is zero if the anchors have the same contrast weight, or if the donor values
are equal. For the unadjusted treatment contrast, a within-arm exchange has zero
cost. A cross-arm exchange costs (1/m + 1/c) times the exchanged outcome difference,
up to sign. Accuracy and candidate counts do not record either alignment.

**All feasible cycles characterize zero width.** Consider a graph with at least
one perfect matching and no error budget or other side constraint. Fix any perfect
matching pi. An alternating cycle exchanges the assigned donors among distinct
anchors i_1,...,i_r, with new edges
(i_k, pi(i_{k+1})), indexing cyclically. Flipping the cycle remains a perfect
matching precisely when these new edges belong to the graph. Its contrast change is

\[
D_C=\sum_{k=1}^r w_{i_k}
\{y_{\pi(i_{k+1})}-y_{\pi(i_k)}\}.
\]

The feasible contrast has zero width if and only if D_C = 0 for every such
alternating cycle relative to the fixed matching.

**Proof.** If the width is zero, every feasible cycle flip preserves the contrast.
Conversely, compare any second perfect matching with pi. Their differing edges
decompose into disjoint alternating cycles. The difference between their contrasts
is the sum of those cycle changes and hence is zero. Edges that occur in no perfect
matching never enter the argument. A shared error budget can forbid single cycle
flips while allowing coordinated changes, so this characterization is stated for
the graph-only feasible set.

**Components separate the uncertainty.** With full bijections and no shared side
budget, each connected component with anchors must contain equally many anchors
and donors. Feasible maps can be chosen independently across components, so both
extrema and widths add across components. A component entirely within one treatment
arm contributes zero width: its contribution is its constant arm weight times the
fixed sum of its donor outcomes. A component whose donors all have the same value
also contributes zero width. These are sufficient conditions; the cycle criterion
also allows other cancellations and uniquely determined maps.

**Proof.** A perfect matching never crosses components. Its restriction uses every
donor in its component once. The global feasible set is the Cartesian product of
the component feasible sets, and the objective is their sum. Constant weights or
constant donor values then give the invariances above. A shared error budget
couples components and removes this Cartesian-product argument.

**A closed form for complete candidate blocks.** Suppose each component is complete
bipartite. Let component b contain n_b anchors, t_b treated anchors, and sorted
donor outcomes y_b(1) <= ... <= y_b(n_b). Its exact contribution to width is

\[
W_b=\left(\frac1m+\frac1c\right)
\left\{\sum_{r=n_b-t_b+1}^{n_b}y_{b(r)}
      -\sum_{r=1}^{t_b}y_{b(r)}\right\},
\]

with empty sums zero. The overall width is the sum of W_b, absent shared budgets.

**Proof.** The component contribution equals
(1/m + 1/c) times the sum of the t_b donors allocated to treated anchors,
minus the fixed donor total divided by c. Completeness allows any subset of size
t_b. The smallest and largest such sums attain the two extrema.

This expression combines treatment mixing, outcome dispersion, and donor
conservation. Counting ambiguous records alone discards all three.

## 3. The same accuracy can support different conclusions

Take eight units, four treated, with Z = y = (1,1,1,1,0,0,0,0).
The true linkage is identity. The accepted linkage exchanges units 1 and 2 and
leaves the rest correct: its identity accuracy is 75%, while its linked outcomes
happen to be correct. Both analyses impose at most two identity errors.

Both graphs give exactly two candidates to every anchor and donor. The first has
pair components {1,2}, {3,4}, {5,6}, {7,8}. The second has pair components
{1,2}, {3,5}, {4,7}, {6,8}. Every pair denotes the complete candidate block on
those two anchors and two donors. Both contain the true and accepted linkages.

| Information retained | Feasible contrast range | Maximum sharp-null p-value |
|:---|:---|---:|
| Accuracy budget and donor conservation | [0.5, 1] | 34/70 = 0.486 |
| Same budget plus first graph | [1, 1] | 2/70 = 0.029 |
| Same budget plus second graph | [0.5, 1] | 34/70 = 0.486 |

The first graph confines all ambiguity within treatment arms. The second permits
a cross-arm exchange that halves the contrast. There are 70 possible assignments
in the experiment; the following section specifies how the p-values account for
them. The graphs have 16 perfect matchings before the budget, and five each after
it; the accuracy-only set has 29. Even the number of admissible reconstructions
fails to summarize their causal relevance.

The values are reproduced in [the generated example](../results/graph-information/same-accuracy-example.csv).
The labels "near" and "far" in the code describe grouping relative to the chosen
baseline outcomes, not an estimated score or a method for learning valid graphs.

## 4. A randomization test that uses the graph

Test Fisher's sharp null H_0: Y_i(1) = Y_i(0) for every unit. This is stronger than
tau = 0 when individual effects vary. For any fixed reconstructed outcome vector,
use the absolute difference in means and the actual complete-randomization law.

Every bijection of a full donor pool has the same randomization distribution of
that statistic. To see this, permute the anchor labels by the bijection: a uniform
m-element treatment subset maps to another uniform m-element subset. The observed
statistic can change across linkages, but its reference distribution cannot.

Let H(s) = Pr_A(|T(A,y)| >= s) for a uniform size-m assignment A. Then

\[
p_{\max}=\max_{\pi\in\mathcal M(G,K)}H(|T(\pi)|)
=H\left(\min_{\pi\in\mathcal M(G,K)}|T(\pi)|\right).
\]

**Proof.** H is nonincreasing, and the finite nonempty feasible set attains its
minimum absolute contrast. That reconstruction attains the largest p-value.
The reference law uses all allowed experimental assignments, not assignments
conditioned on the observed candidate graph.

The opposite direction is also useful: the smallest feasible p-value is
H(max_pi |T(pi)|). The maximum absolute contrast is max(|L_G|, |U_G|), so one of
the linear endpoints attains it. The function now returns both p_min and p_max
and both attaining linkages. A small p_min shows that rejection is possible under
some linkage; it is not a valid p-value for rejection robust to identity uncertainty.
The delta adjustment is applied to p_max, the robust-test quantity.

The minimum is an integer program: use binary assignment variables x_ij,
row and column sums equal to one, graph and budget constraints, and a continuous
t >= 0. Minimize t subject to

\[
-t\le\sum_{ij}w_i y_j x_{ij}\le t.
\]

The attainable contrasts are discrete. A range [-2,2] might contain only -2 and 2;
replacing the minimum absolute contrast by the distance of the interval from zero
would lose information. The implementation solves for an attaining linkage and
checks its feasibility and objective value.

For binary outcomes with K_y ones, the number of ones allocated to treatment has
a Hypergeometric(N, K_y, m) distribution. Its finite support gives H directly.
For other outcomes the implementation enumerates complete-randomization assignments,
with an explicit size limit. It optimizes over linkages rather than enumerating
all of them. Integer optimization itself can still be expensive.

**Size with uncertain graph containment.** Suppose the entire reconstruction set,
including its accuracy restriction, contains pi* with probability at least 1-delta.
The probability is over assignment and any randomness in graph or budget formation,
under each null population for which the guarantee is asserted. Then

\[
p_{\mathrm{valid}}=\min\{1,p_{\max}+\delta\}
\]

is a valid p-value under the sharp null.

**Proof.** On the containment event, p_max >= p_oracle pointwise. For alpha < 1,
rejection at p_valid <= alpha implies p_oracle <= alpha-delta on that event.
If alpha < delta, rejection is impossible; otherwise its probability is at most
(alpha-delta) + delta = alpha, using oracle randomization validity and the
containment-failure bound. No independence between the graph and outcomes is used.
This is the usual maximization-over-a-confidence-set argument
([Berger and Boos](https://doi.org/10.1080/01621459.1994.10476836)).

The code accepts delta; it does not estimate it. A pairwise candidate recall of
95% is not 95% probability that the complete true matching is retained. If separate
bounds cover graph omissions and an erroneous accuracy budget, their sum gives a
joint failure bound by the union bound, without independence. Allowing a specified
number of off-graph edges is another sensitivity restriction; it does not by itself
establish a probability guarantee.

## 5. An exhaustive design illustration

The script fixes eight units, the same accepted transposition, and the two pair
graphs above. Set Y(0) = (0,0,0,0,1,1,1,1) and Y(1) = Y(0) + effect, for effects
0, 1, 2, and 4. Enumerate all 70 equally likely assignments. The true linkage is
identity in every case. These are controlled candidate sets chosen to expose
alignment with potential outcomes; no identifier-learning mechanism is claimed.
This design was developed after inspecting the worked example, not preregistered.

At effect zero, the first graph preserves the oracle's 2/70 rejection probability
at the 5% level. The accuracy-only analysis never rejects. The second graph also
never rejects. All meet the size bound. At effects 2 and 4, the oracle always
rejects, both graphs reject only 6/70 times, and accuracy-only never rejects.
The candidate information helps, but much experimental power remains unavailable.

At effect 1 even the oracle rejects just 1/70 times at 5%. This small exact test is
discrete, and its power need not rise at each effect value. The generated report
keeps that result. At 10%, the second graph can reject more often than the first;
there is no universal ordering between two graphs that are not nested.

[The generated report](../results/graph-information/report.md) and
[all assignment results](../results/graph-information/assignments.csv) retain the
full comparison. These are exact design probabilities, with no simulation error.
Range containment concerns the oracle realized estimate, not the average effect.

## 6. Treatment, covariates, and the next useful extension

If treatment labels live on donors and outcomes on anchors, the same full-bijection
contrast is sum_ij x_ij y_i {z_j/m - (1-z_j)/c}. A bijection conserves treatment
counts, and the graph restricts which outcomes can receive those labels. The
linear bounds transfer by transposing the setup. A causal test must still specify
the true assignment design and jointly reconstruct the relevant fields. The new
function specifically implements known anchor assignment and uncertain outcomes.

If covariates or several fields are uncertain, preserve their record-level
coherence: a feasible donor supplies its entire relevant row. Refit any estimator
whose weights depend on those fields. Separately optimizing treatment, outcome,
and covariate matches may create datasets that no feasible linkage can produce.
The common-null-law shortcut proved above is for the unadjusted contrast under
complete randomization. Missing donors, blocked assignment, or varying donor
subsets require additional work; the current function rejects unequal file sizes
and does not provide those designs as options.

For the Rajasthan application, the existing graph ranges already exploit donor
competition with fixed regression weights. The [lottery extension](../application/lottery-design.md) now assumes a stated
conditional assignment law, following the user's requested lottery assumption.
It evaluates feasible p-value witnesses with Monte Carlo intervals for the
rectangular, stratified application; it does not apply the full-bijection shortcut.
Reconstruction containment remains an explicit sensitivity assumption.

The next practical target is validation of the restrictions: which candidate
components can be resolved or expanded with a limited identity audit, and how much
that changes the causal range or worst-case p-value. The cycle formula explains
why local ambiguity scores can misallocate review effort. A record with many
candidates may be irrelevant to the contrast, while one cross-arm exchange can
determine the conclusion. Any probabilistic review allocation needs evidence about
identity uncertainty beyond the unweighted graph.

## Reproduce and inspect

Run `make graph-information` and `make check`. The implementation is
[R/information.R](../R/information.R); independent enumeration checks are in
[test-information.R](../tests/testthat/test-information.R). Tests cover signed and
binary outcomes, unequal arm sizes, graph omissions, error budgets, unattainable
zero contrasts, adaptive truth-containing graphs, component formulas, and invalid
inputs. Standard errors are not a substitute for maximizing over unidentified
linkages; this implementation reports robust sharp-null p-values and estimate
ranges, not a newly estimated linkage standard error.


## 7. Operational sensitivity output and numerical contracts

`graph_breakdown_budget()` reports the smallest at-most-K identity budget for
which the maximized (optionally containment-adjusted) p-value exceeds alpha.
Rejection is defined as p <= alpha. The accepted map must itself be feasible. It returns zero if its adjusted p-value
already fails to reject and infinity if no graph-feasible bijection removes rejection.
The feasible sets are nested, so binary search is exact; a finite positive output
includes a linkage attaining that budget. This is an identity-constrained form of
existing warning-accuracy analysis, not a separate novelty claim.

The exact binary accuracy-only comparator in `R/accuracy.R` retains the accepted
bijection, donor pool and identity-error budget while allowing all candidate
edges. Treated successes q can differ from their accepted count q0 by at most
floor(K/2), intersected with hypergeometric support. Each unit of difference
requires two changed identities and is attainable by a cross-arm opposite-value
swap. The formula need not hold on a restricted graph.

Outcome contrasts are normalized before optimization and reference-tail
comparison, then rescaled for reported estimates. This repairs a numerical
scale-invariance defect documented in [the method audit](exact-method-audit.md).
Two-valued outcomes use their exact hypergeometric law under any affine coding.
`solver_timeout` limits each solver call; a nonoptimal status raises an error,
never an exact endpoint. The identifier experiment reports timed-out or failed
cases and gives them a conservative nonrejection fallback.

The [main methods paper](../manuscript/paper.pdf) now develops this procedure.
The older general bias, variance and validation compendium is retained as
[background](../manuscript/background.pdf). The
[identifier-based validation protocol](identifier-validation-design.md) describes
synthetic candidates formed before assignment and outcomes, with a shared
oracle-known error budget and an exact donor-conserving accuracy comparator.
