# Independent audit of exact graph-constrained randomization inference

Audit date: 2026-10-08. Scope: `R/information.R`, `R/graph.R`,
`R/core.R`, `research/graph-information.md`, and independent exhaustive checks.

The central reduction is correct. Under complete randomization with fixed arm
sizes and a full bijection of a fixed outcome pool, every reconstructed outcome
vector has the same absolute-difference-in-means null distribution. Its upper
tail is monotone, so minimizing the attainable absolute contrast exactly
maximizes the Fisher p-value. Maximizing the absolute contrast gives the minimum
p-value. Only the maximum supports rejection robust to every feasible identity.

The confidence-set argument for `min(1, p_max + delta)` is also correct.
Containment is a joint event for the complete matching and every budget
restriction. Marginal candidate recall cannot substitute for its probability.
The graph can depend on outcomes or assignment if the claimed containment bound
holds under every null population. No conditioning on that adaptive graph is
required for the stated unconditional guarantee.

These facts do not transfer automatically to blocked experiments or partial
linkages. Blocked randomization has a common null law if all allowed
permutations preserve the relevant experimental blocks; arbitrary cross-block
links can change it. Changing a donor subset can also change the null law.
The existing Rajasthan analysis correctly uses separate reference distributions.

The minimum absolute attainable contrast cannot be replaced by the distance
from zero to its interval hull: the hull can cross zero without an attainable
zero. The existing integer formulation preserves this distinction. Identical
outcome values do not make the donors interchangeable for identity budgets.

## Verified numerical defect and correction

Before this audit, the identity graph with eight outcomes
`(1,1,1,1,0,0,0,0)` and the same treatment vector returned `p_max=2/70`.
Multiplying all outcomes by `1e-10` returned `p_max=1`. An absolute tolerance
with a scale floor of one swallowed the entire null distribution. The same
issue affected `p_min`.

The corrected implementation centers and scales outcomes before every solver
call and reference-tail comparison, then restores original units for contrasts
and bounds. Constant outcomes return p-values of one. Any two distinct outcome
values now use the hypergeometric reference law, so rescaling binary outcomes
does not accidentally require assignment enumeration. A spread that exceeds
floating-point range fails explicitly with a rescaling instruction.

Tests now cover positive and negative factors from `1e-100` to `1e100`, large
representable location shifts, constants, and agreement with exhaustive
linkage calculations. The solver still uses floating-point arithmetic and a
normalized numerical tolerance; mathematical exactness describes the finite
optimization and randomization law, not arbitrary-precision computation.

## Minimum identity budget needed to lose rejection

Define

\[
K_\alpha=\min\{K:p_{\max}(G,K)+\delta>\alpha\},\qquad 0\le\alpha<1,
\]

with the p-value capped at one. The strict inequality corresponds to rejection
at `p <= alpha`. The feasible sets are nested in K, so the robust p-value is
nondecreasing. Binary search over integer budgets therefore returns the exact
first nonrejection budget, using the same tested inference routine.

`graph_breakdown_budget()` implements this search. It requires an accepted
bijection feasible under the graph and off-graph allowance. It returns zero if
the accepted linkage already fails to reject, infinity if every graph-feasible
linkage still rejects, and otherwise the smallest budget with an attaining
linkage. Its `changed` field counts the actual altered identities. This is a
minimum under the declared candidate restrictions, not an estimated number of
true linkage errors. At an infinite result the returned linkage attains the
largest p-value but does not establish nonrejection.

An exhaustive six-unit test checks the minimum over every permutation,
nonrejection at several alpha levels, equality at the rejection threshold,
infinite breakdown, delta adjustment, and the impossibility of changing
exactly one identity in a bijection. The breakdown summary is practically
useful; it is not by itself evidence of methodological originality.

## A compact binary special case that retains identity counts

For disjoint complete candidate blocks, suppose the accepted bijection respects
those blocks. Block b has n_b anchors, t_b treated anchors, s_b donor successes,
and q_b0 successes assigned to treatment by the accepted linkage. The attainable
success count q_b satisfies

\[
\max(0,t_b-(n_b-s_b))\le q_b\le\min(t_b,s_b).
\]

The minimum number of changed accepted identities required to attain q_b is
exactly `2 * abs(q_b-q_b0)`. Each unit change in treated success count needs
one treated and one control identity changed; swapping opposite-outcome donors
across those arms attains the lower bound. Other identities can stay accepted.
Thus a dynamic program over total treated successes and the sum of those block
costs gives an exact compact representation and can recover an actual donor
permutation. It does not replace identities by unconstrained binary labels.

This reduction requires complete blocks and a block-respecting accepted map.
For general candidate graphs, donors with equal outcomes can have different
neighborhoods, and the same outcome configuration can require different
identity costs or be infeasible. Aggregating solely by outcome discards those
restrictions. The current general assignment formulation remains appropriate.
The compact special case is a proposed extension, not implemented by this audit.

## Validation with identifiers rather than outcome-chosen graphs

A useful design fixes true identity, draws latent geographic groups and noisy
identifiers, and constructs candidate blocks from those identifiers before
random assignment. Potential outcomes can depend on latent geography, so the
graph is correlated with outcomes through pre-treatment information without
being selected to preserve an observed effect. Generate the accepted map using
identifiers only, and use its realized true identity error count solely as a
simulation benchmark for a shared budget.

Compare oracle, accepted-link, graph-constrained, and complete-graph tests at
the same K. Random assignment naturally places members of ambiguous components
in both arms. Vary identifier ambiguity and the association between geography
and outcomes, including no association and graph omissions. Truth-containing
graphs give pointwise containment; omission scenarios need a valid joint delta
bound or must be labeled sensitivity violations. Report size over assignments,
power, breakdown budgets, runtime, and Monte Carlo uncertainty. Do not choose
or retain candidate sets based on the observed treatment contrast.

Such a design can exhibit more power than the complete-graph comparator because
candidate restrictions prevent exchanges across heterogeneous geographic groups.
It need not do so: homogeneous outcomes, large budgets, or broad candidate blocks
can make the restrictions unhelpful. A null finding is informative and should
remain in the report.

## Runtime limits and binary integer objective

A validation pilot exposed a slow 80-unit binary problem. The binary objective
now minimizes the integer `abs(N*q - m*S)`, where q is the number of donor
successes allocated to treated anchors and S the fixed donor success total.
Multiplication by the positive outcome gap divided by `m*(N-m)` restores the
normalized absolute contrast. Assignment edges, donor identities, and error
budgets remain unchanged. The auxiliary absolute-value variable is integer.

The formulation also imposes the smallest absolute numerator across the full
hypergeometric support as a lower bound. This is valid for every constrained
linkage and prevents a long search for an unattainable zero when the donor total
and arm sizes make zero impossible. The pilot case's previously stalled effect
setting then solved in approximately 0.66 seconds; this is a diagnostic timing,
not a general runtime guarantee.

`graph_information_test()`, `graph_breakdown_budget()`, and `linkage_bounds()`
accept `solver_timeout`, a nonnegative integer number of seconds per solver
call. Zero retains unlimited search. The parameter is forwarded to every
optimization, and every nonzero solver status raises an error rather than
returning an unproved optimum. The official
[lpSolve manual](https://cran.r-project.org/web/packages/lpSolve/lpSolve.pdf)
defines the timeout in seconds. A whole test can make multiple solver calls,
so this is not an overall wall-clock deadline. If a simulation deliberately
assigns p=1 to a failed solve, it must record that conservative computational
fallback separately from successfully computed exact results.
