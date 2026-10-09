# Rajasthan application audit

The current Rajasthan MNREGA analysis is reproducible, but changing from fuzzy to exact names changes the analyzed population. On the common election-record cohort the two methods attach identical outcomes. Their coefficient differences therefore do not measure linkage error. This audit reproduces the 2005/2010 additive specification, reconstructs the complete geographically blocked candidate graph, and diagnoses missingness. It does not validate individual identities or certify the full reservation paper.

Run from the project root:

```sh
Rscript application/run.R ../quota_spending
Rscript application/bounds.R ../quota_spending
```

The adapter reads the source repository and writes only `application/results`. It requires `arrow`, `dplyr`, `stringdist`, `stringi`, `sandwich`, and `digest`; the bounds exercise also uses `lpSolve`. The source is not executed or modified. The application data are external inputs; this package does not redistribute the original election or expenditure panels. A source hash manifest and R session information accompany the results.

## Quantities and design

| Quantity | Unit and population | Treatment | Outcome | Interpretation |
|---|---|---|---|---|
| Reproduced main coefficients | Equally weighted linked Rajasthan GPs | Indicators for offices reserved for women in 2005 and 2010 | GP sum of completed projects, ongoing projects, or expenditure over 2011–2014 | Additive conditional linear projection; causal ITT interpretation needs the assignment and selection assumptions |
| Exact-name comparison | GPs retained by the exact-name procedure | Same indicators | Same outcomes | Method-specific selected population |
| Common-cohort comparison | Election records present under both procedures | Same indicators | Each procedure's attached outcome | Holds election-record composition fixed |
| Complete-four-year sensitivity | GPs with four nonmissing annual outcomes | Same indicators | Four-year sum | Changes missing-data handling and population; does not recover missing outcomes |

Reservation assignment is distinct from electing a woman. The two election indicators describe a treatment history. With heterogeneous history effects, the additive coefficients are not automatically population-average single-cycle effects. Equal assignment probabilities, independence of histories, or appropriate weighting/stratification must be established for the intended interpretation. Balance after linkage does not prove that selection or mislinkage is independent of potential outcomes.

The official [Rajasthan Panchayati Raj Election Rules, 1994, Rule 9](https://upload.indiacode.nic.in/showfile?actid=AC_RJ_83_1129_00001_00001_1563516015325&filename=election_rule_1994_eng_file.pdf&type=rule) specifies draws of lots for offices reserved for women. Its publicly indexed text confirms that general mechanism. The [Panchayati Raj Act, section 16](https://www.indiacode.nic.in/bitstream/123456789/18832/1/the_rajasthan_panchayati.pdf) distinguishes office reservations and contains amendments to the quota. The complete PDFs timed out during retrieval; the indexed official extracts were inspected. They do not provide the realized 2005 and 2010 draw rosters, probabilities, eligible sets, caste strata, reset rules, or local implementation. The existing manuscript itself reports different rounding and an exceptional district. The initial audit computed no application randomization p-values. The subsequent
[lottery extension](lottery-design.md) takes reservation lotteries as an explicit
assumption, following the user's instruction, and supplies a conditional
stratified assignment law for the retained cohort. Its results do not claim
historical validation of that assumed law.

## Reproduction and selection

All numerical comparisons are generated in [results/summary.md](results/summary.md) and the full 24-outcome [estimates.csv](results/estimates.csv). `se_ols` reproduces the current `lm` standard error. `se_hc2` illustrates conditional heteroskedasticity adjustment; neither includes uncertainty about linkage, eligibility, or the causal assignment mechanism.

The main table and the adapter have 4,355 fuzzy-linked GPs. The exact-name panel has 2,036. Their intersection contains 1,861; all 1,861 use the same target record. For total completed projects, the current 2005 coefficient is −0.025860 (OLS SE 1.880437), compared with −2.994499 (2.739805) in the exact cohort. Restricting both to the common cohort gives −2.992084 (2.901981) in each. The corresponding 2010 estimates are −0.870204, −0.231272, and 0.028278. Exact matches are neither a validation sample nor a superset/subset of accepted fuzzy matches: reciprocal collision filtering and geographic restrictions can remove exact-name matches too.

The fuzzy cohort's raw mean among GPs unreserved in both years is 52.36647 projects over four years. Its additive-model intercept is approximately 51.58; these are different quantities because the additive fit constrains the four history means. The unit is projects per retained GP over the period, not projects per resident or per year. The adapter provides the actual 00-history mean for every estimate. Expenditure outcomes retain the source's lakh-rupee unit.

The source manuscript currently states 4,654 GPs in its MNREGA sample description, while its displayed main table and current panel have 4,355. Its stated treatment-history counts also differ from the current panel. This is a verified prose/table mismatch, not evidence that the regression file is stale. The read-only audit leaves the manuscript unchanged.

[selection_flow.csv](results/selection_flow.csv) traces the denominator:

- The existing cross-election roster has 8,017 records. It already embodies an earlier election-to-election linkage and is not the full original election universe.
- The MNREGA block crosswalk retains 5,532. No further source-name duplicates are removed in this current extract.
- The Rajasthan R6 report has 14,303 target records. Intersecting R6 with R1, R3, and R5 leaves 12,797, even for outcomes sourced from R6. This couples inclusion to the availability of reports not directly needed for the completed-project outcome.
- There are 276,729 pairs within mapped district/block combinations before report-intersection eligibility and nearest-neighbor selection, 239,466 pairs under original endpoint eligibility, and 19,592 eligible edges under distance 0.1. Among sources with eligible candidates, 3,400 have multiple candidates under that cutoff.
- Applying the source pipeline's row-minimum, strict cutoff, source-tie deletion, and target-collision deletion reproduces all 4,355 saved pairs, with no extra or missing pair. The adapter asserts this identity.

[selection_by_assignment.csv](results/selection_by_assignment.csv) shows fuzzy retention between about 53.8% and 55.1% across the four assignment histories. Similar marginal retention rates do not establish potential-outcome-independent linkage or protect against within-group selection.

The graph is saved as [candidate_graph.parquet](results/candidate_graph.parquet). Each row has an election ID, MNREGA target ID, district/block key, Jaro distance (`method="jw", p=0`), and original source/target eligibility. There is no nearest-neighbor or distance truncation in that artifact. Blocking, the cross-election roster, and transliteration still restrict its support; it is not known to contain every true counterpart. It includes target records missing other reports, making that selection visible. Source records lacking a mapped block have no graph edges and remain in the selection denominator. Candidate existence is not proof of a counterpart, and raw endpoint names are not treated as independently verified identities.

## Missing outcomes and uncertainty

In the fuzzy panel, 39 GPs have all four annual observations missing for each of the 24 constructed outcome categories. The source's `rowSums(..., na.rm=TRUE)` converts these totals to zero. The exact panel has three such GPs. [outcome_missingness.csv](results/outcome_missingness.csv) and [missingness_by_assignment.csv](results/missingness_by_assignment.csv) retain these diagnostics.

Restricting to 4,316 fuzzy GPs with four observed years changes the total-project 2005 coefficient from −0.025860 to +0.125485, and the 2010 coefficient from −0.870204 to −0.717112. These are measured sensitivity changes. The adapter does not declare complete-case deletion a correction: whether missing annual values mean zero activity requires the collection/reporting protocol, and deletion can select on outcomes. A proper remedy preserves observation indicators and models, bounds, or validates the missing totals.

The current main specification uses conventional OLS standard errors; the reporting helper does not replace them with robust estimates. For total projects the HC2 values are 1.908604 and 1.779700, versus conventional 1.880437 and 1.780790. This conditional variance comparison leaves dependence induced by candidate competition and uncertain links unaddressed. A fixed-link bootstrap also would not recover these omitted components.

## Feasible-linkage sensitivity on the existing cohort

`bounds.R` holds the 4,355-GP fuzzy cohort and both reservation indicators fixed. It minimizes and maximizes each additive OLS coefficient over all injective complete assignments to eligible MNREGA targets within the original district/block and distance < 0.1 rule. Because the design matrix is fixed, each coefficient is a linear weighted sum of assigned outcomes. The assignment program decomposes over 157 blocks. It uses 15,603 candidate edges for this cohort and verifies integral solutions, one target per source, no target reuse, and endpoint objectives reconstructed from saved assignment witnesses.

For total completed projects, the resulting 2005 coefficient range is [−29.71507, 31.88550]; the 2010 range is [−30.23307, 31.18752]. The current estimates lie inside. [coefficient_reconstruction_bounds.csv](results/coefficient_reconstruction_bounds.csv) also reports the wider independent-record extrema, which permit target reuse, to quantify the tightening from injectivity. [coefficient_bound_witnesses.parquet](results/coefficient_bound_witnesses.parquet) records the actual feasible assignments attaining each endpoint. The two coefficients' marginal endpoints need not be attained by the same assignment.

These ranges are conditional reconstruction sensitivity, not causal intervals and not measured bias. They allow every candidate under the cutoff, so implausible but textually close alternatives can dominate. They preserve the current missing-as-zero convention. They force every selected GP to match, assume the eligible target pool contains its counterpart, condition on the prior election-history linkage, and exclude the unlinked election population. None of these assumptions has been validated here. An outside option, missing true edges, wrong treatment histories, a validated error budget, or a narrower outcome-complete target population defines a different exercise. The width is evidence that the accepted point estimate relies on stronger identity choices than the distance cutoff and one-to-one requirement alone.

## Pipeline map beyond the main slice

| Pipeline | Linkage/aggregation | Where uncertainty enters |
|---|---|---|
| Rajasthan election years | Already linked `elex_raj_05_10.parquet` | Both treatment-history alignment and sample inclusion before this adapter begins |
| Rajasthan election → MNREGA | Samiti/block crosswalk, district/block blocking, transliteration, row-minimum Jaro distance, cutoff, duplicate deletion | Outcome attachment, missing targets, and selected population |
| Uttar Pradesh election → MNREGA (`03b`) | District blocking and concatenated district/block/GP names; row minima, cutoff, source/target duplicate deletion | Same channels; entire candidate graph is not preserved by the source script |
| Elections → LGD (`00_linkage`, `04`) | Alias-aware GP candidate matching, row and column minima, reciprocal uniqueness and margins | Treatment histories attached to geographical groups; ambiguous identities affect covariate/outcome aggregation downstream |
| LGD → SHRUG (`04`) | Census village codes and many-to-many crosswalk checked before resolving a SHRID to one GP | Administrative-boundary and aggregation uncertainty; not a one-to-one matching of individual villages to election records |

The LGD path explicitly withholds unresolved geography and GPs without Census 2001 mapping. Its returned linkage table retains row-minimum candidates, so it cannot supply a complete feasible-link graph without rerunning distance construction. Current status counts for Rajasthan and UP are in `raj_lgd_status.csv` and `up_lgd_status.csv`; the statuses are procedural, not validated error labels. Rajasthan accepts 1,803 exact and 1,608 fuzzy election/LGD links; Uttar Pradesh accepts 2,084 exact and 6,930 fuzzy. A SHRID can represent multiple constituent villages: collapsing identities before checking constituent mappings would misstate the matching unit. The adapter inventories this path but does not rerun the SHRUG causal estimates or the separate UP fuzzy-RD design.

## Checks and next empirical requirements

| Check | Result and scope |
|---|---|
| Unit/denominator and exposure window | Four-year GP totals reproduced; raw 00 mean distinguished from fitted intercept; selection denominator traced to existing cross-election roster |
| Missing-as-zero | Measured and rerun under complete-four-year restriction; missingness by assignment saved |
| Join and row conservation | Source and target uniqueness asserted; all accepted pairs independently reconstructed |
| Provenance | Source SHA-256 manifest and session versions saved; main table values reproduced; stale prose count documented |
| Specification/estimand | Additive two-history projection reproduced; no automatic single-cycle population ATE claim |
| Inference | Conventional and HC2 SEs compared; actual lottery support and linkage uncertainty remain unresolved |
| EDA/skew | Zero totals and group baseline means recorded; no claim that count tails satisfy homoskedasticity |
| Design and measurement | Reservation vs officeholder separated; prior linkage, blocking, and boundary changes explicit |
| Outcome multiplicity | All 24 pre-existing constructed categories exported; no significance-based outcome selection |
| Validation | Exact names not treated as truth; independent validated links not supplied to this adapter |
| Full-paper provenance and all robustness branches | Outside this application's scoped reproduction; the paper's broad null/equivalence claims are not certified |

The [lottery sensitivity exercise](results/lottery/report.md) now proceeds under
an assumed conditional assignment law. Empirical validation of the design and
linkage would additionally use historical assignment records, independent checking
of candidate and excluded links, and outcome reporting metadata. Graph sensitivity can proceed without claiming measured bias, but must name the eligible population, overlap/cardinality assumptions, error budget, and outcome support. Feasible reconstruction extrema are ranges of the estimator, not causal confidence intervals. Existing candidate graphs make those assumptions inspectable; they do not supply them automatically.


## Lottery sensitivity extension

Under the specified lottery assumption, `make lottery` evaluates candidate-feasible
identity reconstructions with up to 4, 21, 43, 217, and 435 changes to accepted links.
It reports both directions of p-value sensitivity, with attaining witnesses and
simultaneous Monte Carlo intervals. These caps are sensitivity restrictions, not
estimates of actual linkage error. The stratum fixed-effect statistic differs from
the earlier unstratified additive coefficient; the [design note](lottery-design.md)
defines the estimand and selected-cohort exchangeability assumption.

The application uses a rectangular injection and may change stratum outcome pools,
so it evaluates each linkage's own lottery reference distribution. Its witness
bounds are not exact global p-value extrema. The [generated results](results/lottery/report.md)
retain both strong- and weak-evidence reconstructions rather than using the ambiguous
label “worst-case p-value” without a direction.
