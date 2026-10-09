# Simulation protocol

This protocol accompanies executable `scenario_registry()` and was written before the
200-replication pilot. Five-replication engineering checks preceded it. Existing quota
results and the closest literature were already inspected; this is not a preregistration.

The primary target is the finite-population ATE among 80 anchor units. Each replication
regenerates baseline covariates, bounded potential outcomes, complete assignment,
linkage corruption, and a simple random validation sample of half the anchors. The
registry varies which fields move together, why links fail, heterogeneity, treatment
allocation, and graph misspecification. Outcomes have prespecified support [0,6].
The primary contrast is one outcome unit; the null runs impose the sharp zero effect.

Pilot: 200 replications per cell, seed base 410000. Final: 2000 per cell, seed base
9000000. The two effect levels and all scenarios have disjoint seed ranges. Any changes
after examining the pilot must be recorded below and rerun. Final conclusions require
Monte Carlo standard errors; an apparent two-percentage-point coverage difference
is not decisive with only 200 replications.

The controlled graph includes the true edge and an accepted corrupted permutation,
plus random alternative edges. It isolates statistical mechanisms, not identifier
performance. The missing-edges scenario intentionally violates truth containment.
The identifiers scenario instead generates families of similar character names, corrupts suffix characters,
calculates Jaro distances, and constructs a threshold graph without forcing truth into
it. Its names are synthetic and are not calibrated to Indian place names. Candidate
recall and all-truth containment are different quantities.

The idealized exact subset in controlled runs has perfect precision by construction;
its selection can still change the target. It is not a claim that exact strings validate
identity. In the identifiers run, exactness is determined by observed string equality.
High-confidence filtering in controlled runs uses Beta(8,2) scores for correct links
and Beta(3,4) for incorrect links, with cutoff .8. These are synthetic score
distributions, not a trained calibrated classifier. The application separately reproduces its real
threshold pipeline. Fields recorded together move together. The duplicate scenario
intentionally permits a naive record-wise algorithm to reuse a donor; feasible graph
bounds still prohibit reuse.

Methods: oracle difference in means; naive linked contrast; selected high-confidence
and idealized exact subsets; interacted covariate-adjusted regression with HC2;
standard attenuation correction with estimated validation accuracy and delta-method
uncertainty; two-phase validation-only and difference estimators; graph bounds on the
oracle realized contrast and bounded-outcome causal confidence sets. Wald intervals
are approximations, including for the validation estimator whose variance estimator
has a finite-sample conservative expectation. The attenuation comparator's working
standard error does not establish validity under a dependent permutation. Its failure
outside the homogeneous assignment-independent model is an intended diagnostic.

Report bias, RMSE, empirical error SD, average reported SE, coverage, null rejection,
power, interval width, selected-target shift, precision, graph containment, oracle
contrast containment, runtime, and numerical failures. Graph sets have no point
estimate, so point failures for that method mean not applicable. Validation burden is
40 audited anchors per replication. `review_priority()` separately evaluates the
best and worst width reductions from resolving a candidate; it uses no invented
probabilities for reviewer answers. Point-estimate error SD includes population
regeneration and equals the SD of estimate minus that replication's target.

Application comparisons use both each method's cohort and their intersection.
Neither exact links nor the existing accepted links are treated as validation labels.
No application randomization test is run without a documented historical assignment
support. No thresholds are selected by their treatment-effect p-values.

## Changes after pilot

The first 200-replication pilot exposed two weak diagnostics: random confidence scores
did not model high precision, and independent random names were too easy to link.
Before final evaluation, confidence scores were changed to the Beta mixtures stated
above, and names to shared-prefix families with noisy suffixes. The pilot was rerun
in full with the same pilot seeds; the final seeds remain separate. These design
changes make mechanisms informative; they were not selected to improve any method’s bias or coverage.

Final reporting separates candidate-edge recall, true-map containment, and whether
the outcome reconstruction is covered using an outside option. Outside options can
contain the true outcome vector without including the actual identity edge. Accepted
link precision is also reported for the selected methods. These reporting additions
do not change the simulation design or numerical estimates.

The binary-confounder observational illustration was specified after the randomized
pilot. It checks a derived analytic expectation at five copying probabilities with
2,000 replications each, independent seed 19000001, and known measured-data
propensities. It is an illustration rather than a methods comparison.
