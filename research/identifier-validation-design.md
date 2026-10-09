# Outcome-blind identifier validation: protocol

This protocol is written before running the simulation. It assesses whether the
candidate graph improves a worst-case Fisher test over an exact accuracy-only
comparator that conserves the donor pool. It is synthetic validation, not evidence
that real identifiers provide equally informative or truth-containing graphs.

## Fixed design

Use 40 and 80 units, each divided among ten known geographic groups (four or eight
units per group). Independently generate each true two-character identifier suffix
uniformly from a four-letter alphabet. Duplicate suffixes are allowed. An anchor
suffix is corrupted with probability .25 or .75 by changing exactly one randomly
chosen character to one of its three alternatives. Geographic identifiers remain
correct. Randomly permute donor rows. A candidate edge exists exactly when known
geography agrees and suffix Hamming distance is at most one. Under this stated
bounded corruption mechanism the true permutation is always in the graph. No
edges are inserted using the known truth.

Choose the accepted permutation by minimum total Hamming distance on this graph;
independent continuous tie costs of amplitude 1e-6 per edge break ties without
altering the integer-valued primary objective. This occurs before treatment and
outcome generation. Full overlap and one-to-one matching are explicit assumptions.

Randomize exactly half the units to treatment. Independently draw U uniformly on
[0,1] per unit. Set Y(0)=1{U<p0} and Y(1)=1{U<min(1,p0+effect)}. Baseline probabilities
are either .35 for all units or alternate .05/.65 across geographic groups. Effects
are 0, .25, and .5. Reuse the same identifiers, accepted map, assignment, and U
across effect values. Identifier construction never consults treatment or outcomes.

For each condition use 40 independent replicates: 2 sizes x 2 corruption rates x
2 baseline patterns x 3 effects x 40 = 960 evaluations. A preceding four-replicate
pilot per condition uses separate seeds, solely to assess runtime and execution.
Any reduction in final replication count must be reported; never choose thresholds
or conditions based on rejection rates.

## Comparators and privileged information

All tests are two-sided Fisher sharp-null tests under complete balanced
randomization, using absolute differences in means and alpha=.05. Binary outcomes
permit an exact hypergeometric reference law.

1. Oracle: the true donor permutation.
2. Graph robust: maximum p-value over graph-compatible bijections differing from
   the accepted map in at most K positions.
3. Accuracy only: maximum p-value over all bijections differing from that same
   accepted map in at most the same K positions.

K is the *oracle-known actual number of incorrect accepted identities*. This
privileged common input isolates the incremental information in the graph. It is
not an estimated or calibrated real-data error bound. The oracle true map belongs
to both comparison sets. Off-graph budget and containment penalty are zero by the
simulation mechanism, not by an empirical coverage estimate.

The accuracy-only computation is closed form. With m treated units, S donor
successes, and q0 accepted treated successes, achievable success counts are the
integer hypergeometric support intersected with q0 +/- floor(K/2). Moving a success
across arms requires at least two changed identities; disjoint cross-arm swaps
attain every count in that interval. Evaluate the exact hypergeometric tail at each
reachable count and return extremal values and attaining swap permutations.

## Outputs and checks

Save each seed, identifiers, full candidate graph, accepted/true maps, assignment,
U, potential outcomes, and extremal witness maps. Record all failures without
silently excluding them. Validate each witness's permutation, graph and identity
budget, contrast and reference p-value. Assert p_graph <= p_accuracy, p_graph >=
p_oracle and graph coefficient range contained in accuracy-only range.

Report per-condition marginal rejection rates with Wilson 95% intervals, paired
graph-minus-accuracy rejection differences with Monte Carlo standard errors,
coefficient-range widths, accepted accuracy, graph degrees, and median/p95 runtime.
At effect zero, finite-replicate rejection rates are noisy size diagnostics; no
claim of deterministic empirical size control follows from them. Theoretical
validity rests on randomization and true-map containment. Both baseline patterns
are reported regardless of whether graph information helps.

## Runtime amendment after the pilot began

The unlimited pilot stalled on the second n=80, corruption=.25, uniform-baseline
replicate (seed 10712002). Its partial checkpoint is retained in pilot-unlimited/.
Before final simulations, impose a three-second limit on each of the three MILP
calls. Any solver failure receives p=1 (nonrejection) and remains in all rejection
rate denominators. Report its status, diagnostic, total elapsed time, and the
condition's exact-completion fraction. Graph widths summarize completed solves
only, with that selection explicit. Accuracy-only calculations remain closed form.
The resource-limited implementation can lose to the accuracy-only comparator due
to its conservative computational fallback; mathematical set nesting is checked
only for completed optimizations. Final conditions, seeds, and replicate counts
remain unchanged. The failed runs remain in all reported rejection-rate denominators.
