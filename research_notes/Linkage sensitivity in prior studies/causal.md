# Causal inference sensitivity to record linkage

## Have causal studies actually changed linkage assumptions and shown resulting effects?

### Takeaway
Yes. The strongest close precedent is a real Meals on Wheels analysis that explicitly varies outcome-dependent linkage and candidate blocking. Its dramatic result also requires assumptions the authors judge implausible.

### Cited Findings
- **Shan, Thomas & Gutman (2021), Annals of Applied Statistics**, Sections 3.4, 5; Tables 4, 8. Linkage assigns treatment membership; posterior linkage draws and missing potential outcomes propagate uncertainty. Equation 25 multiplies identifier-based linkage likelihood ratios by an outcome-dependent factor favoring candidate pairs with death within 30 days. It does not fix the causal effect, but deliberately changes outcome-dependent linkage selection. Table 4 reports mortality ATT risk differences: Δ=1: **0.008 [−0.067, 0.083]**; Δ=50: **0.086 [0.002, 0.170]**; Δ=100: **0.549 [0.412, 0.686]** (95% intervals; proportions, not percentage points). Authors say the extreme parameter overrides identifying information, “despite major disagreements between the linking information,” and judge 50–100 implausible. Section 5.1's neutral Δ=0 statement appears erroneous: equation and table imply 1. Appendix D varies blocking on 4–7 ZIP digits: mortality estimates **0.005, 0.008, 0.010, 0.007**, all intervals crossing zero; tighter blocking widens intervals. [Primary full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC9222523/)

### Inferences
- This is a close precedent for both sensitivity and its plausibility qualification, but not a direct demonstration that changing a few independently plausible name matches overturns a study.

### Gaps
- No worst-case optimization over every feasible linkage, fixed Hamming-error budget, or randomization-p-value envelope is demonstrated by this paper.

## Do outcome-linkage studies show threshold sensitivity and explain why error location matters?

### Takeaway
Yes. Wortman and Reiter explicitly studied causal estimates and estimated variances across linkage thresholds, with mechanisms beyond overall accuracy.

### Cited Findings
- **Wortman & Reiter (2018), Statistics in Medicine**, Sections 3, 5, Figure 2, Table 2. Treatment/covariates occupy one file, outcomes another. Same-treatment, same-subclass outcome swaps can leave subclassification difference-in-means unchanged; regression adjustments need not be invariant. Cross-arm/cross-subclass errors have different consequences. Simulations use real name-error data with simulated treatments, covariates and outcomes. Figure 2 varies linkage threshold and plots distributions of effect and variance estimates: weak thresholds introduce bias; strongest thresholds discard information. In nonlinear scenario Table 2, perfect linkage yields mean estimate **48.1**, empirical variance **22.7**, average estimated variance **25.8**; minimum-estimated-variance rule yields **43.3**, **29.2**, **5.8**, respectively. Therefore smaller reported uncertainty can accompany worse bias and underestimation of actual sampling variability. Their simulations permit duplicate donor use, and cohort size changes with threshold; these are not fixed-cohort injective worst-case bounds. [Primary author manuscript](https://arxiv.org/html/1709.03631); [published DOI](https://doi.org/10.1002/sim.7911)

### Inferences
- Broad statements that causal consequences depend on which records are wrongly linked, or that strict matching trades bias against precision, already have direct antecedents.

### Gaps
- No real empirical causal significance reversal established here; the demonstration is simulation, with important linkage-independence assumptions.

## Have studies propagated linkage uncertainty in covariates, rather than outcomes alone?

### Takeaway
Yes. Covariate linkage and treatment-membership linkage have dedicated causal methods; describing all existing work as outcome-only or precision-only would be inaccurate.

### Cited Findings
- **Guha & Reiter (online 2023; issue 2024), Journal of Statistical Planning and Inference**, Table 1. Outcome, treatment, and some covariates appear in one file; other confounders in another. Joint regression-assisted Bayesian linkage imputes linked datasets for overlap-weight causal inference. At 50% file intersection and true effect 5, ordinary Bayesian linkage without analytical-variable feedback gives mean **3.84 (SD .49)**; regression-assisted linkage **4.92 (.43)**; perfect links **4.98 (.27)**. Their Italian debit-card illustration is **partly simulated linkage using real survey data**, not unidentified links in a wholly real observational linkage problem. Regression-adjusted Table 2 estimates (thousand Italian lire) are **181.61** with perfect links, **192.44** regression-assisted, **221.36** ordinary Bayesian linkage. These are posterior/multiple-imputation comparisons, not adversarial extrema. [Primary full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC11283754/); [published DOI](https://doi.org/10.1016/j.jspi.2023.07.004)

### Inferences
- Existing causal linkage research covers uncertainty entering treatment, outcomes, and covariates. An informative narrower question is what additional guarantees a validated feasible-set analysis provides relative to model averaging.

### Gaps
- The papers examined do not establish how often applied causal researchers perform these checks. Evidence of existence must not be presented as evidence of routine adoption.
