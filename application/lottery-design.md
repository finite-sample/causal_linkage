# Rajasthan lottery and linkage sensitivity

For this extension, reservation assignment in Rajasthan in 2005 and 2010 is assumed
to be a lottery, as requested. The analysis conditions on the selected cohort and
uses explicit exchangeability restrictions below. Historical verification is not
a prerequisite for these conditional results.

## Question, population, and outcome

The population is the 4,355 GPs in the existing fuzzy-linked Rajasthan panel.
For each election year, ask how the sharp-null randomization p-value changes when
eligible candidate identities change. The outcome is the sum of recorded completed
projects over 2011–2014, retaining the source's missing-as-zero policy. Prior
cross-election linkage and reservation labels are held fixed in this exercise.
The 39 all-years-missing records remain coded zero, consistently with the earlier
adapter. The estimand therefore concerns the recorded outcome, including its
reporting convention.

The candidate graph is the reconstructed distance-below-0.1, geographically blocked
graph on this cohort: 15,603 edges, 157 candidate blocks. Each source must receive
one eligible donor; donors may be used at most once. The pool is larger than the
cohort. A full counterpart for every retained GP and truth within the permitted
graph are sensitivity assumptions, not measured candidate recall.

## Assumed lottery and causal statistic

For year t, form strata by that year's district, Samiti, caste-reservation category,
and reservation status in the other election year. Conditional on each stratum's
observed treated count, all allocations within it are equally likely, independently
across strata. This assumes exchangeability within the selected cohort. For the
2005 analysis, conditioning on 2010 additionally asserts the relevant conditional
joint assignment law. It does not follow merely from calling each election a
lottery; it specifies the lottery model used here.

Let n_s and m_s denote the size and treated count in stratum s, p_s=m_s/n_s, and
D=sum_s n_s p_s(1-p_s). The analysis statistic is

\[
T(\pi)=D^{-1}\sum_i(Z_i-p_{s(i)})y_{\pi(i)}.
\]

It equals the treatment coefficient in an OLS regression with stratum fixed
effects. Equivalently it is a weighted average of within-stratum differences in
means, with normalized weights n_s p_s(1-p_s). Pure-treatment strata contribute
zero. Under this assignment model and correct identities it is unbiased for the
correspondingly weighted average treatment effect within the informative strata,
holding the other election assignment fixed. This target differs from the earlier
unstratified additive regression's coefficients and from an equally weighted ATE
across all 4,355 GPs.

The null tested for each year is Fisher's sharp null: changing that year's
reservation does not change any unit's measured outcome at its fixed other-year
assignment. It is not a weak average-zero null or a test of substantively negligible
effects. A large p-value does not establish a small effect.

## Both directions of sensitivity

For each feasible map pi, define p(pi) as the exact tail probability of
|T(A,pi)| >= |T(Z,pi)| under the assumed lottery. The quantities of interest are

\[
p_{\min}=\min_{\pi\in\mathcal M}p(\pi),\qquad
p_{\max}=\max_{\pi\in\mathcal M}p(\pi).
\]

A small minimum says that some permitted identity arrangement yields a small
p-value. A small maximum says every permitted arrangement does so. Only the latter
supports rejection robust to unknown identity. Conversely, finding one large-p
map shows rejection is not uniform across the candidate set. The largest p is
"worst" for rejecting no effect; the smallest p is "best" for that objective.
Neither direction demonstrates equivalence or negligible effects.

The full-bijection, complete-randomization shortcut from `R/information.R` does not
apply here. Changing the injection can change both the donor subset and the outcome
multisets within lottery strata. The application therefore evaluates the null
reference separately for each feasible map.

## Feasible witnesses and what is optimized

The application obtains exact minimum and maximum T by solving linear assignment
programs independently within candidate blocks. Integrality and full-map feasibility
are checked. The zero-cost/pure-stratum cases are retained. Those endpoints are
not assumed to minimize or maximize p.

A third alternative approximately minimizes |T| by switching entire alternating
components between the two endpoint injections. Their union decomposes into
components that can independently choose either matching without duplicating a
donor or omitting an anchor. A deterministic greedy search from both endpoints
returns a near-zero witness; no global optimality is claimed.

The sensitivity table also caps departures from the accepted linkage at 4, 21,
43, 217, and 435 identities, approximately 0.1%, 0.5%, 1%, 5%, and 10% of the cohort.
For each cap, the accepted map and each endpoint map define switchable components.
A binary knapsack program chooses components subject to the identity-change cap,
seeking the minimum or maximum statistic within that family. These maps obey the
full graph and the stated cap, but their search family is a subset of all feasible
budgeted maps. The results bound p extrema using feasible examples, not by claiming
the whole budgeted graph has been optimized. A further near-zero witness switches a subset of the already budget-feasible
components back to the accepted map, so it cannot exceed the cap. The accepted
mapping is also retained at every cap. Identity-change counts are not outcome-disagreement counts.

Witnesses depend on observed assignment and outcomes. Their individual p-values
are sensitivity diagnostics, not valid stand-alone post-selection causal tests.
The accepted mapping is a reference linkage, not independently validated truth.

## Monte Carlo evaluation and bounds on global extrema

Once all maps are selected, generate 19,999 independent lottery allocations per
year, with final seeds 80312026 + year saved in the table. Exploratory runs used
a different seed; final draws are regenerated after fixing the witness construction.
Assignments are shared across maps within year;
that dependence is allowed. For small strata, enumerate their treatment subsets
and sample subset indices uniformly. For larger strata, sample a uniform subset
directly. Strata are sampled independently. This generates the specified lottery
without enumerating the enormous joint assignment support.

For witness j, let C_j be the number of simulated absolute statistics at least as
large as its observed absolute statistic. Report (C_j+1)/(B+1) as the Monte Carlo
p-value, with B=19,999. Clopper–Pearson intervals computed from C_j successes in B
trials target the exact p(pi_j), not this smoothed estimate. Each interval uses
error .05/38, giving at least 95% simultaneous Monte Carlo coverage across the
38 witness probabilities in both years by the union bound. Shared draws need not
be independent across maps for that guarantee.

If these intervals are [L_j,U_j], then

\[
p_{\min}\in[0,\min_j U_j],\qquad
p_{\max}\in[\max_j L_j,1]
\]

on their joint coverage event. For a budget-specific bound, retain only witnesses
that actually satisfy that cap, including witnesses found in a larger-budget
search that ended up changing fewer identities. At budget zero, the accepted map is the only feasible map,
so both extrema receive its full Monte Carlo interval. These are bounds on the locations of the two extrema;
they are not the endpoints of an exactly computed p-value range. In particular,
[0,min U_j] is not a valid robust p-value. Robust rejection requires an upper
bound on p_max; the current witness analysis generally provides only the trivial
upper bound one. It can establish sensitivity and failure of uniform rejection.

The interval confidence refers only to numerical Monte Carlo uncertainty about
fixed-data tail probabilities. It is neither a treatment-effect confidence level
nor a probabilistic claim that the candidate set contains the truth.

## Reproduction and review

Run `make lottery QUOTA_PATH=../quota_spending`. Outputs in `application/results/lottery`
include every witness, its changed-identity count, observed statistic, simulated
null standard deviation, tail count, p-value, and Monte Carlo interval. Separate
tables preserve the lottery strata and bounds on the extrema at each error budget.
Input hashes and R session information record provenance.

The source quota repository is read only. No source manuscript or data are changed.
The independent design review checked the conditional lottery, overlap-weighted
estimand, symmetric-difference witness construction, Monte Carlo intervals, and
extrema-bound logic. Unit tests compare the statistic to an independent fixed-effect
regression, compare the sampler with a fully enumerated lottery, and check budget
and injection conservation.

## Candidate-set audit

The [43-link audit](results/linkage-stress-audit/report.md) independently reproduces
the coefficients and lottery p-values, but finds that shared geographic prefixes
let weak GP-name alternatives pass the original cutoff. Many changes replace exact
accepted names; some introduce missing outcomes coded as zero. Comparing tighter
name rules sharply narrows the coefficient ranges. Those rules preserve accepted
links for comparison and have not been calibrated for true-link coverage.
Run `make linkage-audit QUOTA_PATH=../quota_spending` after generating lottery outputs.
