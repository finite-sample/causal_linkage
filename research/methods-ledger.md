# Claims and reproducible evidence for the methods note

The main paper is `manuscript/paper.tex`; the earlier broad compendium is preserved
as `manuscript/background.tex`. The paper focuses on exact randomization sensitivity
over feasible record identities. Its contribution assessment is in
[the focused review](exact-method-priority.md).

| Claim | Population, estimand and assumptions | Producing code and evidence | Limit |
|---|---|---|---|
| P-value extrema reduce to attainable contrasts | Fixed finite population; complete randomization; full outcome bijection; absolute difference in means; Fisher sharp null | `R/information.R`; proof in `graph-information.md`; exhaustive linkage/assignment tests | General assignment and overlap do not preserve the same law |
| Maximum p plus containment failure bound is valid | Whole true mapping retained with probability at least 1-delta under each null population | Pointwise oracle domination proof; data-adaptive containment tests | Delta is supplied, not estimated; pairwise recall is insufficient |
| Identity breakdown locates first loss of rejection | Nested at-most-K identity sets; same graph, alpha and delta; rejection p<=alpha | `graph_breakdown_budget()`; exhaustive budget tests; `results/methods/breakdown.csv` | Identity-constrained version of established warning-accuracy logic |
| Binary accuracy-only comparator preserves donor ownership | Full complete graph; fixed accepted bijection, binary outcomes and at-most-K identity budget | `R/accuracy.R`; count-support proof; exhaustive permutation tests | Count interval need not be attainable for arbitrary candidate graphs |
| Candidate information can change robust conclusions | Controlled eight-unit population; same accepted map, accuracy budget and candidate degree | `scripts/graph-information.R`; every assignment saved in `results/graph-information/` | Constructed information sets do not establish real-world performance |
| Identifier restrictions add information beyond error counts | Synthetic identifiers and bounded corruption generated before assignment/outcomes; oracle-known K; full overlap | `scripts/identifier-validation.R`; per-replication inputs, results and wide summary in `results/identifier-validation/` | Synthetic support and privileged error budget; failures conservatively do not reject |
| Paper numbers come from analysis artifacts | Table rows, inline results, runtimes and failure count | `scripts/render-methods.R` reads CSVs and produces `results/methods/*.tex` | Source data and summaries must be regenerated when inputs change |
| Rajasthan illustrates candidate sensitivity | Assumed stratified lottery, fixed cohort and rectangular injection graph | `application/lottery.R`, `application/linkage-audit.R` | Feasible p witnesses, not this theorem's exact global endpoints; graph plausibility unvalidated |

The new identifier protocol follows inspection of the older controlled examples
and Rajasthan audit. It is prospective only with respect to its own final runs;
it is not a preregistration. Pilot seeds are separate and used to establish
computational feasibility. Runtime limits and unresolved cases are reported,
not silently removed from performance denominators.

Mechanical verification includes local tests/lint, an independent mathematical
review, a full paper build, numerical-source checks, bibliography checks and
rendered-page inspection. No source quota data are modified.
