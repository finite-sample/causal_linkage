# Independent statistical audit of Rajasthan lottery linkage witnesses

Read-only audit, 2026-10-08. Original source and donor parquet files were read independently in Python. The audit left the source data unchanged. Reproduction script: [independent_refit.py](independent_refit.py), requiring NumPy, pandas, SciPy and a parquet reader. Numerical outputs: [results](quota_statistical_results.csv), [design](quota_statistical_design.csv), and [changed links](quota_statistical_changed.csv).

## Verified calculations

All six accepted/budget-43 maps reproduce their saved raw outcomes and weights, contain exactly the same 4,355 source identities, use each donor at most once, and consist solely of candidate edges satisfying source/target eligibility and distance <0.1. All four alternative maps change exactly 43 identities. Separate sparse least-squares regressions with the complete stratum dummy matrix reproduce the coefficients within 1e-7, independently of the original R weighting code.

Independent lottery generation uses fresh seed 91872026 and 19,999 direct random permutations of the observed treatment vector within every stratum, avoiding the original enumerated-subset sampler. Results:

| Year | Map | Coefficient | Independent MC p | Pointwise 95% MC interval | Exact null SD |
|---|---|---:|---:|---:|---:|
| 2005 | accepted | 0.035864 | .98355 | [.981689,.985267] | 1.690333 |
| 2005 | min43 | -5.449062 | .00120 | [.000729,.001725] | 1.692345 |
| 2005 | max43 | 5.037829 | .00280 | [.002072,.003578] | 1.685523 |
| 2010 | accepted | -1.952198 | .20920 | [.203541,.214864] | 1.566040 |
| 2010 | min43 | -7.095432 | .00005 | [0,.000184] | 1.606565 |
| 2010 | max43 | 3.983175 | .01245 | [.010913,.014032] | 1.568658 |

All are compatible with original reported Monte Carlo uncertainty. A p of .00005 is the plus-one floor with zero exceedances, not an estimated exact probability at that decimal value. Pointwise intervals here are audit checks, not substitutes for original simultaneous confidence intervals. The exact variance under the assumed conditional uniform lottery is sum_s m_s(n_s-m_s) S²_ys/n_s divided by D², where D=sum_s n_s p_s(1-p_s). Monte Carlo SDs match these exact SDs closely. No apparent numerical or permutation bug.

## Why 43 changes can do this

The coefficient change is exactly sum_i w_i(new outcome_i-old outcome_i). The relevant denominator is 824.351 (2005) / 904.810 (2010). There are 663 mixed-treatment strata each year, containing 3,830 and 3,919 informative anchors respectively. Average absolute weights of changed anchors are .00055–.000625.

The whole-sample outcome has median 34, mean 51.15, SD 58.69, 99th percentile 271.46 and maximum 874. Chosen changes have mean absolute outcome differences 195–239 projects—much larger than ordinary differences—and 40–42 of the 43 changes point in the same coefficient direction. Total absolute outcome reassignment is 8,380–10,267 projects. Multiplying ~200 by ~.0006 by 43 gives the observed ~5-project shift. The randomization SD remains about 1.6–1.7, explaining the small tail probabilities. Top five individual contributions account for 1.13–1.54 coefficient units, so no single-row computation error explains the result.

19–22 previously unused donors enter these maps. Thus donor uniqueness holds, but the sample outcome multiset need not be conserved. Overall outcome means change by only -.19 to -.68 projects; most coefficient movement comes from alignment of outcome differences with treatment residuals.

## Nontrivial substantive caveat: missing as zero

Newly assigned donors with all four annual outcome fields missing number 8 (2005 min), 6 (2005 max), 9 (2010 min), 6 (2010 max). Existing row-sum convention gives these donors outcome zero. Their identity changes contribute -1.398, +.647, -1.512, +.932 coefficient units respectively, compared with full shifts -5.485,+5.002,-5.143,+5.935. Some of the sensitivity therefore exploits the missing-as-zero assumption; much does not. All new zero outcomes (including observed zeros) count 17,15,15,13 respectively. A comparison retaining complete-outcome donors is a useful distinct reconstruction-set sensitivity, but simply dropping missing rows in existing optimized maps does not evaluate the same cohort or same experiment.

## Interpretation

Small p-values for maps selected using observed treatment/outcome to maximize contrast are not individually valid post-selection evidence against the causal null. They demonstrate that a user committed to one of those feasible maps would obtain that nominal p-value. The maximum over all feasible maps supplies the robust test if true-map containment and the assumed oracle randomization design hold. The accepted map already gives a large p, so robust rejection is unavailable even without searching for further large-p maps.

The restricted graph and budget could be defensible or implausibly permissive; arithmetic cannot resolve that. Especially important are outcome-blind identity plausibility of selected edges, the previously unused donor identities, and missingness interpretation. Studentization is not required for validity of this Fisher sharp-null test: the original unstudentized statistic is calibrated against its own distribution for each fixed reconstruction. This is not a weak-null/average-treatment-effect test.
