# Literature and contribution map

Checked 2026-10-08. Primary papers, publisher pages, and author manuscripts were used.
This is a targeted comparison, not a systematic prevalence study of applied practice.
A search that did not locate a result does not establish its absence.

| Work and source | Estimand / files | Linkage and causal assumptions | Estimation / uncertainty | Implication for this project |
|---|---|---|---|---|
| [Wortman–Reiter, 2018](https://arxiv.org/abs/1709.03631), methods and bias cases | Additive effect; (X,T) separated from Y | Propensity subclasses; restrictions relating errors to covariates, treatment and potential outcomes | Starts with confident links; variance- and estimate-based link inclusion | Downstream inference already guides inclusion of uncertain links. Neither the causal application nor abandoning precision-only thresholds is new. |
| [Shan–Thomas–Gutman, 2021](https://pmc.ncbi.nlm.nih.gov/articles/PMC9222523/), assumptions and discussion | Treatment roster linked to covariates/outcomes | Strongly noninformative linkage plus causal ignorability | Two-stage multiple imputation; sensitivity to informative linkage | Treatment-membership error and explicit linkage sensitivity are already covered. |
| [Guha–Reiter–Mercatanti, 2022; preprint 2020](https://arxiv.org/abs/2002.09119), abstract/model | (X,T) in one file, Y in another; partial overlap | Joint bipartite identity and analysis model | Bayesian causal and linkage uncertainty | Jointly modeling outcomes and identity is prior work. It contradicts a universal claim that causal analysis variables are excluded from linkage. |
| [Guha–Reiter, 2024](https://www.sciencedirect.com/science/article/pii/S0378375823000514), model and simulations; [author manuscript mirror](https://par.nsf.gov/servlets/purl/10610290) | Covariates split; T,Y together | Regression-assisted linkage and causal assumptions | Bayesian links with propensity/regression causal strategies | Covariate linkage is already studied; uncertainty is not confined to outcome mismatch. |
| [Slawski, 2025 preprint](https://arxiv.org/html/2512.14492v1), §2.1–2.4, Propositions 1–2 | ATE; all three two-file X/T/Y layouts | A1 joint conditional independence of potential outcomes from mismatch and treatment given X; A2 mismatch independent of treatment given X; A3 auxiliary linkage variables conditionally unrelated to potential outcomes/treatment; A5 independence across incorrectly paired file fragments | Bias formulas; audit-based and latent-status estimating equations, mixture/EM corrections, asymptotic inference; misspecification discussion | Closest comparator. Broad X/T/Y formalization, correction and SEs cannot be claimed as new. Blocking can violate A5. The present focus retains the feasible graph and assignment law instead of observing only the merged file. |
| [Tahamont et al., 2021](https://doi.org/10.1007/s10940-020-09461-x), experimental analysis | Treatment effects in administrative outcomes | Experimental assignment with administrative linkage errors | Evaluates power loss and linkage practices | Experimental bias/power motivation is established. This draft does not attribute a universal attenuation theorem to the paper. |
| [Turkcapar–Krishnan, 2023](https://arxiv.org/html/2309.05178v1), §2.3, §3.1, Proposition 3.1 | Aggregate queries over linked files | Candidate containment and degree/cardinality constraints | Optimization of aggregate extrema | One-to-one coupling and assignment bounds precede this project. A range of realized causal estimators needs a separate causal coverage argument. |
| [Morucci–Noor-E-Alam–Rudin, 2022](https://doi.org/10.1287/ijds.2022.0020) | Treatment effects using acceptable treated/control matches | Causal matching restrictions | Optimize inferential quantities across pairings | Relevant robust-inference precedent. These pairs represent different people; identity linkage pairs records for the same person. |
| [Amorim et al., 2021](https://rss.onlinelibrary.wiley.com/doi/abs/10.1111/rssa.12689) | Regression with measurement-error validation | Two-phase probability sampling and model/design conditions | Validation allocation and design/model-based estimators | Validation design and two-phase correction are established; the audit difference estimator here is an adaptation. |
| [Kamat–Gutman, arXiv v2](https://arxiv.org/html/2406.14717v2), §1.2 and primary/secondary-analysis taxonomy | General linked-file inference | Strong/weak noninformative and informative mechanisms | Likelihood, Bayes, imputation and weighting | Use precise conditional independence statements rather than asserting that linkage quality is generally unrelated to outcomes. HTML metadata shows 2024; do not infer a 2026 journal year from search indexing. |
| [Jeffery–Franklin–Halevy, 2008](https://research.google/pubs/pay-as-you-go-user-feedback-for-dataspace-systems/) | Query quality under uncertain entity resolution | Model-based value of feedback | Review prioritization | Downstream-aware review is prior art. Worst-case candidate-graph width reduction is a distinct objective, not automatically a novel contribution. |
| [Hoeffding, 1963](https://doi.org/10.1080/01621459.1963.10500830), §6, Theorem 4; [paper](https://www.cs.rpi.edu/academics/courses/spring06/random/hoefding.pdf) | Means of bounded finite populations | Simple random sampling without replacement | Exponential tail inequalities | Supplies the conservative oracle interval used in graph causal coverage. The concentration inequality is not new. |

## Search scope and unresolved comparisons

Searches covered causal record linkage, candidate/assignment bounds, treatment
misclassification, uncertain covariates, informative linking, validation sampling,
randomization inference, and downstream review. The Slawski paper's bibliography and
the Kamat–Gutman taxonomy supplied additional leads. Exact-name selection is also
connected to the historical-record linking literature, e.g.
[Bailey et al.](https://pmc.ncbi.nlm.nih.gov/articles/PMC8294155/), which should inform
any application-specific validation study.

This compendium does not replicate the full Bayesian procedures or Slawski's EM
implementation. The executed comparator is a transparent attenuation model plus
standard two-phase validation estimators. Thus its simulations cannot establish
superiority over the closest full methods. A publication investment should depend on
that comparison, useful interval widths, and a validated application where constraints
supply information that the established models cannot obtain as reliably.

## Contribution status

**Established:** causal inference with linked X/T/Y; selection bias from confident
links; uncertainty propagation; assignment optimization for aggregates; sensitivity
to informative linkage; two-phase correction; unions of valid confidence sets.

**Derived and mechanically checked here, priority unresolved:** finite-population
permutation expectation with correctness/effect covariance; pair-inclusion variance
estimation for the validation difference estimator in a complete experiment.

**Implemented synthesis:** coherent field reconstructions; missing-edge and trusted-link
budgets; explicit outside options and cardinality; distinct estimator ranges and causal
sets; exact small-graph sharp-null testing; review-value diagnostics; a real pipeline
adapter preserving the candidate graph before nearest-neighbor collapse.

**Empirical findings:** generated application results and simulation results, within
their named populations and assumptions. They are not evidence of measured application
linkage bias without independent identities.

**Decision:** continue a narrow methods-and-application investigation. Do not present
the broad project as a new causal-linkage framework or claim a novel paper is established.
