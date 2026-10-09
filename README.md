# Exact randomization inference with uncertain record identities

Does an experimental conclusion survive every linkage allowed by the candidate
records and an identity-error budget?

This research compendium answers that question for completely randomized
experiments whose assignment and outcome files cover the same units once. It
computes the minimum and maximum Fisher p-values over feasible one-to-one
linkages, returns the identities attaining them, and finds the smallest number
of changed accepted identities that removes rejection.

Read the [methods paper](manuscript/paper.pdf),
[proofs and interpretation](research/graph-information.md), and
[focused comparison with prior work](research/exact-method-priority.md).
The procedure specializes established matching-set and misclassification
sensitivity methods. Its contribution is the exact causal test over permitted
record identities, with an inspectable sensitivity result. Controlled examples establish that candidate information can change a decision.
The identifier experiment finds modest gains and substantial power loss; a
validated real-data application remains necessary.

## Method

Under the sharp no-effect null, every full permutation of donor outcomes has the
same complete-randomization reference law. The largest p-value therefore comes
from the smallest **attainable** absolute treatment contrast. An integer program
finds that contrast. Linear assignment endpoints give the smallest p-value.
A contrast interval containing zero need not contain an attainable zero.

The maximum p-value supports rejection that is robust to the stated identity
uncertainty. The minimum describes the most favorable allowed reconstruction;
selecting it after observing outcomes does not produce a valid robust test.
Both endpoints come with feasible linkages.

The test requires a candidate set and error budget containing the true linkage.
An optional `delta` adjusts for a supplied bound on whole-set containment failure;
the code does not estimate that bound from match scores. Two-valued outcomes use
an exact hypergeometric distribution. General outcomes enumerate treatment
assignments, subject to an explicit limit. All optimization uses normalized
outcomes so p-values do not depend on measurement units. Numerical calculations
still use floating-point tolerances; exactness describes the statistical target.

## Example

```r
source("R/core.R")
source("R/graph.R")
source("R/information.R")

z <- c(1, 1, 1, 1, 0, 0, 0, 0)
y <- z
accepted <- c(2L, 1L, 3:8)
groups <- c(1, 1, 2, 3, 2, 4, 3, 4)
graph <- outer(groups, groups, "==")

fit <- graph_information_test(y, z, graph, accepted, trusted_error_budget = 2)
fit[c("lower", "upper", "p_min", "p_max")]
fit$least_favorable_map

graph_breakdown_budget(y, z, graph, accepted, alpha = .05)
```

`graph_breakdown_budget()` returns the first identity budget at which the robust
test fails to reject, with an attaining linkage. The accepted map must itself be feasible. It returns zero when its
containment-adjusted p-value already fails to reject, and infinity when no graph-feasible map removes
rejection. This is the identity-constrained counterpart of existing breakdown
and warning-accuracy analyses.

## Reproduce

Requires R and the packages in `renv.lock`; the paper also requires LaTeX.

```r
install.packages("renv")
renv::restore()
```

```sh
make methods
```

This runs tests and lint, the exhaustive small-design comparison, the synthetic
identifier experiment, and the paper build. `make report` rebuilds the paper from
existing results. `solver_timeout` optionally caps each optimization in seconds;
zero means no limit. A timed-out solver raises an error and never reports an exact
optimum. The identifier experiment records unresolved cases and uses conservative
nonrejection for its operational comparison.

- [R/information.R](R/information.R): exact p-value extrema, witnesses, containment
  adjustment, and identity breakdown.
- [R/accuracy.R](R/accuracy.R): exact binary accuracy-only comparator preserving
  the donor pool and identity budget.
- [Identifier experiment](results/identifier-validation/report.md): candidates
  generated before assignments and outcomes, with paired comparisons and runtime
  diagnostics. Its error budget is oracle-known, not empirically calibrated.
- [Controlled design](results/graph-information/report.md): all treatment assignments
  for a small example with fixed accuracy and candidate counts.
- [Independent method audit](research/exact-method-audit.md): mathematical checks,
  the corrected scale-invariance defect, and scope boundaries.
- [Claim ledger](research/methods-ledger.md): claims, producing code, and checks.

## Supporting work

The [earlier compendium](manuscript/background.pdf) develops bias decompositions,
validation-sample corrections, general reconstruction bounds, and simulations.
Rebuild it with `make background`; the earlier simulation target is `make simulate`.
These results provide background rather than the main paper's contribution.

The [Rajasthan exercise](application/results/lottery/report.md) assumes the stated
reservation lottery and studies stratified assignments with extra donor records.
It evaluates feasible witnesses and Monte Carlo bounds, not the exact global
p-value endpoints proved for full bijections. Its
[candidate-set audit](application/results/linkage-stress-audit/report.md) finds
that dramatic small-budget changes depend on weak name alternatives; tighter
restrictions sharply reduce coefficient sensitivity. The source application is
read only. Reproduce with `make application lottery linkage-audit`, using
`QUOTA_PATH=../quota_spending` or another source path.

The exact method currently covers Fisher's sharp null, known treatment assignment,
and complete overlap. Weak-null average-effect inference, general covariate and
treatment reconstruction, and arbitrary blocked or partial-overlap designs require
additional work. Synthetic comparisons do not validate real candidate containment.
