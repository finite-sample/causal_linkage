# Independent statistical and implementation review

Reviewed `R/core.R`, `R/graph.R`, `R/simulation.R`, `scripts/simulate.R`, the current theory/graph tests, and `manuscript/paper.tex`. This review independently rederived the principal results and ran additional exhaustive checks. It does not assess novelty beyond the manuscript's appropriately limited priority claims. The application audit was not repeated.

## Principal conclusions

The finite-population permutation expectation, validation correction and conservative variance expectation, and union-over-reconstructions coverage result are correct under their stated assumptions. I found no substantive error in the current simulation's field mappings or outcome support. The main numerical runs use the valid domains of these procedures.

Three input-contract defects should be repaired before presenting the routines as reusable research software. None changes the current simulation results. Their reproductions below describe the version initially reviewed; fixes may supersede them.

1. **Fractional maps pass the permutation guard.** `permutation_expectation(c(0,0), c(1,1), c(1.5,2.5))` returns `-1`. The guard coerces the map to integers for its permutation test but the body compares the original fractional values with row indices. These are not valid donor IDs. Reject nonfinite/noninteger maps before the permutation check; add a regression test.
2. **The treated-roster wrapper accepts an incompatible outside option.** `roster_bounds(c(0,10), matrix(c(TRUE,FALSE),1,2), outside=TRUE, support=c(0,10))` permits a roster member not to match into the complete outcome population. Its offset formula assumes all roster members do match and that controls are their complement. On the stated complete-roster graph the range is the singleton `-10`; the unsupported outside option widens it to `[-10,10]`. Reject any allowed outside option and cardinality restrictions other than full matching in this wrapper. A partial-roster estimator requires a separate derivation.
3. **Custom randomization support can exclude the observed assignment.** `sharp_null_p(c(0,1,2,3), c(1,1,0,0), rbind(c(1,0,1,0),c(0,1,0,1)))` returns zero. The observed assignment has no mass under that supplied design; this is not a valid randomization p-value for the observation. Require nonempty support, inclusion of the observed assignment, and unique support rows when treating the rows as equiprobable support. Document that arbitrary nonuniform designs require probabilities, not an unweighted row mean. Default complete-randomization calls are unaffected.

## Independent derivations and checks

**Permutation expectation.** Under complete assignment with fixed treated count, `E[w_i Z_i]=1/N` and `E[w_i Z_j]=-1/{N(N-1)}` for distinct units. Summing once per donor yields `(sum(F_i tau_i)-mean(tau))/(N-1)`. The heterogeneity/correctness covariance term is necessary. Independence of the permutation from assignment is necessary: a within-arm permutation violates that premise and instead preserves the contrast. The manuscript makes this distinction correctly. The formula is independent of treatment fraction, provided both arms exist.

**Validation variance.** I independently enumerated all assignments for `N=7`, `m=2`, and all validation subsets of size `k=2`, using baseline outcomes `(0,2,3,5,8,1,4)`, heterogeneous effects `(-1,2,0,3,1,2,5)`, outcome-sorted linked outcomes, and reversed linked treatment labels. Across the resulting assignment/validation distribution:

- Mean estimator minus finite-population ATE: `1.55e-15`.
- Mean estimated variance minus exact estimator variance: `0.5578231`.
- `S_tau^2/N`: `0.5578231`.

This checks sparse validation, unequal treatment allocation, treatment/outcome errors, and the pairwise inclusion factor. The code's `n_a * sum((y_a-mean(y_a))^2)` implements the sum of pairwise squared differences correctly, including the zero contribution when fewer than two same-arm units are validated. Sparse audits can yield unstable or even zero estimated variances; unbiased/conservative expectation does not prove normal-interval coverage. The manuscript already states this limitation.

**Graph programs.** I generated 30 feasible four-source/three-donor cases with random candidate graphs, negative and positive weights, outside support `[-1,2]`, cardinality `[1,3]`, off-graph budgets, and trusted links with violation budgets. Independent enumeration of every injective partial matching agreed with the integer program at both endpoints in all 30 cases. The distinction between general integer budgets and an ordinary assignment network is correctly stated in the manuscript.

**Coverage.** The union bound requires oracle validity and containment, not graph/assignment independence. The proof remains valid for assignment- or outcome-adaptive graphs because it is a pointwise domination argument on the containment event. I also enumerated all 70 assignments for `N=8,m=4` under a sharp null with outcomes `(0,1,2,4,6,9,10,12)`, constructing each graph adaptively by adding a swap between its first treated and first control unit while retaining truth. The graph-max test rejected on zero assignments at both 5% and 10%. This is an additional conservative example, not a proof of general validity; the manuscript's pointwise argument supplies the proof. Freezing a selected sample and applying a fictional assignment law would fail its premise, as the manuscript explains.

**Bounded-outcome causal interval.** Each treatment arm is a simple random sample from the appropriate fixed potential-outcome vector. The two-sided sampling-without-replacement Hoeffding bound with per-arm error probability alpha/2 yields the stated radius. The intersection with the logical ATE support is valid. Observed outcome range alone cannot justify the support; the manuscript correctly requires potential-outcome support.

## Simulation review

- For effects 0 and 1 in the driver, the generated potential outcomes lie in `[0,6]`: baseline outcomes lie in `[0.2,3.8]`; the largest added heterogeneous effect is 1.8. The bound is prespecified and covers unobserved potential outcomes too.
- The treatment-file case transposes candidate edges to assignment-file anchors. In the joint `(Z,Y)` case, unadjusted association is invariant under their common permutation, so its identity graph for that statistic is appropriate. Wrong covariates matter to adjusted estimation; the graph unadjusted contrast does not purport to solve that problem.
- Duplicate reuse is a deliberate misspecification of the naive algorithm, while feasible graph reconstruction continues to impose uniqueness. Missing true edges deliberately violate containment. The selection scenario's outside options permit unknown outcomes for excluded anchors and its validation estimator assumes audits can recover them. This is a strong validation-information assumption, stated in the manuscript.
- The identifiers branch actually produces false nearest-neighbor links despite only character corruption. The initial engineering version gave correct-link fractions from 0.8375 to 0.9375 in ten seeds; those numbers are a historical check, not a summary of the revised shared-prefix-family generator introduced after the first pilot. Its graph is not forced to contain truth. It allows outside options for all sources, making the resulting confidence sets conservative and preventing candidate failure alone from implying reconstruction failure.
- After the logged first-pilot revision, controlled runs draw confidence scores from Beta(8,2) for correct links in the initially generated permutation and Beta(3,4) for incorrect links, retaining scores above 0.8. I verified these distributions and the cutoff in the current code against `research/simulation-design.md`. This is a synthetic precision-oriented selection baseline, not a trained or calibrated operational classifier. The selection stress test overrides retention, while the identifier branch uses its observed string-distance score. The earlier independent-score description applied to the superseded first pilot.
- The attenuation comparator uses a working variance, estimates its denominator, and is deliberately run outside its homogeneous independent-permutation model. It should not be described as a generally valid corrected estimator. The manuscript already labels it approximate.
- Pilot and final seed ranges are disjoint at the stated 200/2,000 replications. The summary reports failure counts alongside coverage computed among successful intervals. Any nonzero failure rate needs that conditional denominator stated in interpretation; it cannot silently be counted as unconditional coverage.

## Remaining scope limitations

The result is a rigorously delimited compendium, not a completed new general method for causal record linkage. The observational nuisance-estimation extension, comparison with contemporary joint/mixture model estimators, and efficient large-graph sharp-null optimization remain unimplemented research extensions, and the manuscript says so. The initial nonidentification example established only ambiguity of the realized linked contrast. It has subsequently been replaced by the valid identical-observable-law construction reviewed below.

The three input guards above are the only demonstrated code defects from this pass. They do not undermine the proved results or the present valid-domain runs. No claim about statistical originality follows from finding the derivations correct.

## Resolution by implementing agent

The three input-contract defects were repaired: permutation indices must be integers;
`roster_bounds` no longer accepts outside/cardinality overrides; custom assignment
supports must contain the observed assignment and have unique rows. Regression tests
exercise each rejected input. These changes do not alter the reported experiments.

## Second pass: repairs and observational proposition

The three reported software defects are repaired. I reran the original fractional-map, unmatched-roster, and observed-assignment-exclusion reproductions; each now fails explicitly. I also checked duplicate assignment-support rows and attempted to pass a partial matching cardinality to the roster wrapper; both are rejected. Valid complete randomization still returns a positive exact p-value.

The added binary-confounder proposition is correct. Under the stated independent copying/replacement mechanism, `P(X=1|W=w)=1/2+q(w-1/2)` and the true measured-data propensity is `1/2+0.6q(w-1/2)`. The residual baseline contrast is `0.6 Var(X|W)/Var(Z|W)`, giving the stated excess `0.6(1-q^2)/(1-0.36q^2)`. This applies to the unnormalized inverse-propensity estimator used in the script; its finite-sample expectation is exactly the displayed population value because the true propensity is supplied.

For an independent implementation check, I formed the eight-cell joint `(X,Z,W)` probability table and directly standardized the conditional outcome contrasts, rather than reusing the inverse-propensity expression in the new unit test. At 101 copying probabilities from zero to one, the maximum discrepancy from the closed form was `4.44e-16`. I then reran all five 2,000-replication observational cells in memory, skipping only the script's final file write. All saved values in `results/observational.csv` reproduced to numerical tolerance.

The external-donor replacement interpretation and the distinction between copying probability and binary covariate agreement are both correctly stated. One wording refinement was suggested: the proposition establishes failure of ordinary measured-covariate adjustment, rather than unrestricted nonidentification. With a known invertible error kernel for `q>0`, additional measurement-error methods can sometimes recover latent-covariate identification. A title such as “Correct measured-data models need not remove confounding” states exactly what the result proves. This does not affect its formula or proof.


## Final pass: causal nonidentification with an unordered outcome file

The replacement proposition supplies the missing probability-law argument correctly. With two identified anchor units and exactly one randomized treatment, population P has both units' potential outcomes `(Y(0),Y(1))=(0,1)` and ATE 1; population Q has `(1,0)` and ATE −1. For either assignment, both populations produce the same unordered donor outcome file `{0,1}`. The identified assignment file has probabilities one-half on `(1,0)` and `(0,1)` in both populations. Uninformative donor identifiers and the complete candidate graph do not distinguish them. Thus the entire observable law agrees, not merely one realized sample, while the target differs.

I independently enumerated both assignments and compared the joint law of the identified assignment vector and sorted donor outcomes; the probability tables are identical. The explicit unordered-file assumption matters: stable informative donor identities could reveal additional assignment/outcome relationships across the hypothetical observable distribution. Sorting by outcome can make row mappings depend on assignment, so this construction does not invoke the fixed assignment-independent permutation theorem. Independent random ordering is also a valid representation of the unordered file. Candidate containment, full overlap, and randomized assignment therefore do not by themselves guarantee point identification in this observation model. The manuscript's new proposition and its stated scope are correct.
